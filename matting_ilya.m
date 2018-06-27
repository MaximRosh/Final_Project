function [status] = matting_ilya(stableVidPath, binaryVidPath, mattedVidPath, bgImageName)

    binaryVid   = vision.VideoFileReader(binaryVidPath, ...
                                         'ImageColorSpace', 'intensity', ...
                                         'VideoOutputDataType', 'uint8');

    nFrames     = VideoReader(binaryVidPath).NumberOfFrames;
    fRate       = binaryVid.info.VideoFrameRate;

    stableVid   = vision.VideoFileReader(stableVidPath, ...
                                         'ImageColorSpace', 'RGB', ...
                                         'VideoOutputDataType', 'uint8');
                                     
    mattedVid   = vision.VideoFileWriter(mattedVidPath, ...
                                         'FrameRate', fRate);

    bgImage     = im2double(imread(bgImageName));

    h   = VideoReader(stableVidPath).Height;
    w   = VideoReader(stableVidPath).Width;
    
    bgImage = imresize(bgImage, [h, w]);

    i = 1;
    hBar = waitbar(0, '', 'Name', 'Video Matting...');
    BarOuterPosition = get(hBar, 'OuterPosition');
    set(hBar, 'OuterPosition', ...
        [BarOuterPosition(1), BarOuterPosition(2), ...
         BarOuterPosition(3),BarOuterPosition(4) * 1.2]);

    status  = 0;
    idxs    = uint32(1:(h * w));
    pdfMap_F_given_X = zeros(h, w);
    pdfMap_B_given_X = zeros(h, w);
    
    while (~isDone(binaryVid) && ~isDone(stableVid))

        waitbar(i / nFrames, hBar, ...
                sprintf('Frame processed: %d / %d', i, nFrames));
            
        
    %% Scribbles from binary mask and Distance maps calculation  

        % Read current frame and current binary mask
        curMask       = im2bw(step(binaryVid));
        curFrame      = im2double(step(stableVid));
        curFrameHSV   = rgb2hsv(curFrame);
        curFrameVal   = im2uint8(curFrameHSV(:, :, 3));  

        % Get scribbles poins using the binary mask Create trimap using the binary mask
        maskFG     = logical(imerode(curMask,strel('disk',5)));
        maskBG     = logical(~imdilate(curMask,strel('disk',5)));
        maskNB     = logical(~maskBG.* ~maskFG); 

        % check is mask is valid
        if (sum(sum(maskFG))) < 10
            continue;
        end

        % Foreground/Background likelihood 
        [~, P_C_given_F, ~, ~] = kde(curFrameVal(maskFG),256,0,255);
        [~, P_C_given_B, ~, ~] = kde(curFrameVal(maskBG),256,0,255);

        P_C_given_F = P_C_given_F ./ (P_C_given_F + P_C_given_B);
        P_C_given_F(P_C_given_F < eps) = 0;
        
        P_C_given_B = 1 - P_C_given_F ;
        P_C_given_B(P_C_given_B < eps)  = 0;

        % Compute Discrete Weighted Geodesic Distance
        pdfMap_F_given_X(idxs) = P_C_given_F(curFrameVal(idxs) + 1);   
        [Gx_F, Gy_F]    = gradient(pdfMap_F_given_X);
        Gmag_F          = sqrt(Gx_F.^2 + Gy_F.^2);

        pdfMap_B_given_X(idxs) = P_C_given_B(curFrameVal(idxs) + 1);  
        [Gx_B, Gy_B]    = gradient(pdfMap_B_given_X);
        Gmag_B          = sqrt(Gx_B.^2 + Gy_B.^2);

        D_F = graydist(Gmag_F, maskFG, 'cityblock');
        D_B = graydist(Gmag_B, maskBG, 'cityblock'); 


    %% Create Trimap
    
        Vf          = D_F <= D_B;
        Fboundary   = bwperim(Vf);
        maskNB      = logical(imdilate(Fboundary, strel('disk', 8)));  
        
        trimap          = im2double(Vf);
        trimap(maskNB)  = 0.5;
        
        maskFG      = (trimap == 1);
        maskBG      = (trimap == 0);

    %% Create Alpha map
    
        [~, P_C_given_F, ~, ~] = kde(curFrameVal(maskFG), 256, 0, 255);
        [~, P_C_given_B, ~, ~] = kde(curFrameVal(maskBG), 256, 0, 255);

        P_F_given_X = P_C_given_F ./ (P_C_given_F + P_C_given_B);
        P_B_given_X = 1 - P_F_given_X;

        pdfMap_F_given_X(idxs) = P_F_given_X(curFrameVal(idxs) + 1);
        [Gx_F, Gy_F] = gradient(pdfMap_F_given_X);
        Gmag_F = sqrt(Gx_F.^2 + Gy_F.^2);

        pdfMap_B_given_X(idxs) = P_B_given_X(curFrameVal(idxs) + 1);
        [Gx_B, Gy_B] = gradient(pdfMap_B_given_X);
        Gmag_B = sqrt(Gx_B.^2 + Gy_B.^2);

        D_F = graydist(Gmag_F, maskFG, 'cityblock');
        D_B = graydist(Gmag_B, maskBG, 'cityblock');
        
        D_F(maskFG) = 0;
        D_B(maskBG) = 0;

        D_F(D_F == 0) = eps; D_B(D_B == 0) = eps;
        W_F = pdfMap_F_given_X.*(D_F.^-1);
        W_B = pdfMap_B_given_X.*(D_B.^-1);

        W_F(W_F == inf) = 1;
        W_B(W_B == inf) = 1;
        alpha = W_F./(W_F + W_B);    


        curFrameMatted = repmat(alpha, [1 1 3]).* curFrame + ...
                         repmat(1 - alpha, [1 1 3]).* bgImage;

        step(mattedVid, curFrameMatted);

        i = i +1;

    end
    
    delete(hBar);

    release(mattedVid);
    release(binaryVid);
    release(stableVid);

end