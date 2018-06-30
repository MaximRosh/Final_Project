function [status] = matting(stable_vidPath, binary_vidPath, matted_vidPath, bg_imageName)
warning('off')
binary_vid   = vision.VideoFileReader(binary_vidPath, 'ImageColorSpace', 'intensity', 'VideoOutputDataType', 'uint8');
stable_vid   = vision.VideoFileReader(stable_vidPath, 'ImageColorSpace', 'RGB', 'VideoOutputDataType', 'uint8');
video_info = aviinfo(stable_vidPath);
frame_rate = video_info.FramesPerSecond;
video_Comp = 'None (uncompressed)'; %'MJPEG Compressor'; %'None (uncompressed)';%'DV Video Encoder'; %'MJPEG Compressor'; % video_info.VideoCompression; %
video_quality = video_info.Quality;
number_of_frames = video_info.NumFrames;

matted_vid   = vision.VideoFileWriter(matted_vidPath, 'FrameRate', frame_rate, 'Quality',video_quality,'VideoCompressor',video_Comp);
bg_image     = im2double(imread(bg_imageName));

h   = VideoReader(stable_vidPath).Height;
w   = VideoReader(stable_vidPath).Width;
bg_image = imresize(bg_image, [h, w]);
i = 1;
h_bar = waitbar(0, '', 'Name', 'Video Matting...');
BarOuterPosition = get(h_bar, 'OuterPosition');
set(h_bar, 'OuterPosition',[BarOuterPosition(1), BarOuterPosition(2),BarOuterPosition(3),BarOuterPosition(4) * 1.2]);
status  = 0;
idxs    = uint32(1:(h * w));
map_f_given_x = zeros(h, w);
map_b_given_x = zeros(h, w);
trimp_vid = 13;
count_f = 1;
% To start as matting video
while count_f < trimp_vid + 1
    step(stable_vid);
    count_f = count_f + 1;
end
% Matting
while (~isDone(binary_vid) && ~isDone(stable_vid))
    waitbar(i / (number_of_frames-trimp_vid), h_bar,sprintf('Frame processed: %d / %d', i, (number_of_frames-trimp_vid)));
    %% Scribbles from binary mask and Distance maps calculation
    % Read current frame and current binary mask
    cur_mask       = im2bw(step(binary_vid));
    cur_frame      = im2double(step(stable_vid));
    cur_frameHSV   = rgb2hsv(cur_frame);
    cur_frameVal   = im2uint8(cur_frameHSV(:, :, 3));
    % Get scribbles poins using the binary mask Create trimap using the binary mask
    mask_fg     = logical(imerode(cur_mask,strel('disk',5)));
    mask_bg     = logical(~imdilate(cur_mask,strel('disk',5)));
    mask_nb     = logical(~mask_bg.* ~mask_fg);
    % check is mask is valid
    if (sum(sum(mask_fg))) < 10
        continue;
    end
    % Foreground/Background likelihood
    [~, given_f, ~, ~] = kde(cur_frameVal(mask_fg),256,0,255);
    [~, given_b, ~, ~] = kde(cur_frameVal(mask_bg),256,0,255);
    given_f = given_f ./ (given_f + given_b);
    given_f(given_f < eps) = 0;
    given_b = 1 - given_f ;
    given_b(given_b < eps)  = 0;
    % Compute Discrete Weighted Geodesic Distance
    map_f_given_x(idxs) = given_f(cur_frameVal(idxs) + 1);
    [gx_f, gy_f]    = gradient(map_f_given_x);
    gmag_f          = sqrt(gx_f.^2 + gy_f.^2);
    map_b_given_x(idxs) = given_b(cur_frameVal(idxs) + 1);
    [gx_b, gy_b]    = gradient(map_b_given_x);
    gmag_b          = sqrt(gx_b.^2 + gy_b.^2);
    d_f = graydist(gmag_f, mask_fg, 'cityblock');
    d_b = graydist(gmag_b, mask_bg, 'cityblock');
    %% Create Trimap
    v_f          = d_f <= d_b;
    f_boundary   = bwperim(v_f);
    mask_nb      = logical(imdilate(f_boundary, strel('disk', 8)));
    
    trimap          = im2double(v_f);
    trimap(mask_nb)  = 0.5;
    
    mask_fg      = (trimap == 1);
    mask_bg      = (trimap == 0);
    %% Create Alpha map
    [~, given_f, ~, ~] = kde(cur_frameVal(mask_fg), 256, 0, 255);
    [~, given_b, ~, ~] = kde(cur_frameVal(mask_bg), 256, 0, 255);
    f_given_x = given_f ./ (given_f + given_b);
    b_given_x = 1 - f_given_x;
    map_f_given_x(idxs) = f_given_x(cur_frameVal(idxs) + 1);
    [gx_f, gy_f] = gradient(map_f_given_x);
    gmag_f = sqrt(gx_f.^2 + gy_f.^2);
    map_b_given_x(idxs) = b_given_x(cur_frameVal(idxs) + 1);
    [gx_b, gy_b] = gradient(map_b_given_x);
    gmag_b = sqrt(gx_b.^2 + gy_b.^2);
    d_f = graydist(gmag_f, mask_fg, 'cityblock');
    d_b = graydist(gmag_b, mask_bg, 'cityblock');
    d_f(mask_fg) = 0;
    d_b(mask_bg) = 0;
    d_f(d_f == 0) = eps; d_b(d_b == 0) = eps;
    w_f = map_f_given_x.*(d_f.^-1);
    w_b = map_b_given_x.*(d_b.^-1);
    w_f(w_f == inf) = 1;
    w_b(w_b == inf) = 1;
    alpha = w_f./(w_f + w_b);
    cur_frame_matted = repmat(alpha, [1 1 3]).* cur_frame + repmat(1 - alpha, [1 1 3]).* bg_image;
    step(matted_vid, cur_frame_matted);
    i = i +1;
end
delete(h_bar);
release(matted_vid);
release(binary_vid);
release(stable_vid);
end