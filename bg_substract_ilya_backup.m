function [ status ] = bg_substract_ilya( inputPath, OutPath, BGth, winSize, Debug )

    inputVid    = VideoReader(inputPath);
    fRate       = inputVid.FrameRate;
    fNumber     = inputVid.NumberOfFrames;

    outVid      = vision.VideoFileWriter([OutPath 'extracted.avi'], 'FrameRate', fRate);
                                         %'VideoCompressor', 'MJPEG Compressor');
    outMaskVid  = vision.VideoFileWriter([OutPath 'binary.avi'], 'FrameRate', fRate);
                                          %'VideoCompressor', 'MJPEG Compressor');
                                
    initFrame   = read(inputVid, 1);
    [m, n, ~]   = size(initFrame);
    
    % Counter containing the number of pixels lower than median
	lb = repmat(uint8(0), [m, n]);
    
    % Histogram (based on time window)
    histMat = repmat(uint8(0), [m, n, 256]);

    % Median  matrix
    medianMat = repmat(uint8(0), [m, n]);

    % Image sized grid
    [xx, yy] = meshgrid(1:n, 1:m);
     
    if ((winSize + 1) / 2) >= fNumber
        fprintf('input  is too small! (minimum number of frames: %d\n', ...
                (winSize + 1) / 2);
        status = 1;
        return;
    end

    % Last winSize frames for each pixel
    framesWindowMat = repmat(uint8(0), [m, n, winSize]);
    
    h = waitbar(0, sprintf('Frame processed: %d / %d', 0, (winSize + 1)/2), ...
               'Name', 'Background substraction initialization ...');
               
    for t = 1:(winSize + 1)/2
        
        newFrameHSV     = rgb2hsv(read(inputVid, t));
        newFrameValue   = uint8(newFrameHSV(:, :, 3) * 255);

        framesWindowMat(:, :, t) = newFrameValue;
        
        % Map intensity values to linear index
        intensityMat = double(newFrameValue + 1);
        idx = sub2ind([m, n, 256], yy(:), xx(:), intensityMat(:));

        if t == 1
            histMat(idx) = histMat(idx) + 1;
        else
            % Mirror padding for first half window pixels
            histMat(idx) = histMat(idx) + 2;
        end
        
        waitbar(t / (winSize + 1)/2, h, ...
                sprintf('Frame processed: %d / %d', t, (winSize + 1)/2));
    end
    
    close(h);
    
    tmpMat = framesWindowMat;

    % Create mirror reflection
    framesWindowMat(:, :, 1:(winSize + 1)/2) = ...
            flipdim(framesWindowMat(:, :, 1:(winSize + 1)/2), 3); 
    
    framesWindowMat(:, :, ((winSize + 1)/2 + 1):end) = ...
            tmpMat(:, :, 2:(winSize + 1)/2);

    medianMat = median(framesWindowMat, 3);

    % Collect num of pixels smaller than median value
    for i = 1 : m*n
        lb(i) = sum(histMat(yy(i), xx(i), 1:medianMat(i) - 1));
    end
    
    h = waitbar(0, sprintf('Frame processed: %d / %d', 0, fNumber), ...
                   'Name', 'Background substraction ...');
          
    % Substract BG
    for f = 1:fNumber
        
        ticID = tic;
        
        curFrame        = read(inputVid, f);
        curFrameHSV     = rgb2hsv(curFrame);
        curFrameValue   = uint8(curFrameHSV(:, :, 3) * 255);

        if f > 1
            % Update median
            if (f + (winSize -1)/2 <= fNumber) 
                newFrame = read(inputVid, f + (winSize - 1)/2);
            else
                % Read in reverse order from the end
                mirrorIdx = fNumber - mod(f + (winSize - 1)/2, fNumber);
                newFrame = read(inputVid, mirrorIdx);
            end

            newFrameHSV = rgb2hsv(newFrame);
            newFrameValue = uint8(newFrameHSV(:, :, 3) * 255);

            % Histogram update
            intensityMat = double(newFrameValue + 1);
            idx = sub2ind([m, n, 256], yy(:), xx(:), intensityMat(:));
            histMat(idx) = histMat(idx) + 1;

            % Remove last element and update histogram
            lastFrameValue = double(framesWindowMat(:, :, 1));
            idx = sub2ind([m, n, 256], yy(:), xx(:), lastFrameValue(:) + 1);
            histMat(idx) = histMat(idx) - 1;

            % Update number of pixels below median
            mask = (lastFrameValue > medianMat) & (newFrameValue < medianMat);
                lb = lb + uint8(mask);
            mask = (lastFrameValue == medianMat) & (newFrameValue < medianMat);
                lb = lb + uint8(mask);
            mask = (lastFrameValue < medianMat) & (newFrameValue > medianMat);
                lb = lb - uint8(mask);
            mask = (lastFrameValue < medianMat) & (newFrameValue == medianMat);
                lb = lb - uint8(mask);
                
            % Calculate median
            th = (winSize - 1) / 2;   
            for i = 1:m
                for j = 1:n
                    %lower median
                    while lb(i, j) > th
                        medianMat(i, j) = medianMat(i, j) - 1;        
                        lb(i,j) = lb(i, j) - histMat(i, j, medianMat(i, j) + 1);
                    end
                    %higher median
                    while (medianMat(i, j) < 256) && (lb(i, j) + histMat(i, j, medianMat(i, j) + 1)) <= th
                        lb(i, j) = lb(i, j) + histMat(i, j, medianMat(i, j) + 1);
                        medianMat(i, j) = medianMat(i, j) + 1;
                        while (medianMat(i, j) < 256) && (histMat(i, j, medianMat(i, j) + 1) == 0)
                            medianMat(i, j) = medianMat(i, j) + 1;
                        end
                    end
                end
            end

            % Update frame window
            framesWindowMat = circshift(framesWindowMat, [0, 0, -1]);
            framesWindowMat(:, :, winSize) = newFrameValue;
        end

        diff = (abs(medianMat - curFrameValue) > BGth);

        fgMask = getFgMask_ilya(diff);

        curFrameNoBG = repmat(uint8(fgMask), [1 1 3]).* curFrame;

        step(outVid, curFrameNoBG);
        step(outMaskVid, fgMask * 255);
        
        if Debug && mod(f, 10) == 0
            imwrite(diff * 255, sprintf('../output/frames/diff_f_%d.jpg', f));
            imwrite(fgMask * 255, sprintf('../output/frames/mask_f_%d.jpg', f));
        end
        
        frameTime = toc(ticID);
        
        % Update waitbar
        waitbar(f / fNumber, h, ...
                sprintf('Frame processed: %d / %d (%.2f [sec])', ...
                        f, fNumber, frameTime));

    end

    release(outMaskVid);
    release(outVid);

    close(h);
    
    status = 0;
end

