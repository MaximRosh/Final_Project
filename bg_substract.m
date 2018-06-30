function [ status ] = bg_substract( inputPath, OutPath, bg_thresh, win_size, Debug )
warning('off')
%     inputVid    = VideoReader(inputPath);
inputVid = vision.VideoFileReader(inputPath, 'ImageColorSpace', 'RGB');
% frame_rate       = inputVid.FrameRate;
% number_of_frames     = inputVid.NumberOfFrames;

video_info = aviinfo(inputPath);
frame_rate = video_info.FramesPerSecond;
video_Comp = 'None (uncompressed)'; %'MJPEG Compressor'; %'None (uncompressed)';%'DV Video Encoder'; %'MJPEG Compressor'; % video_info.VideoCompression; %
video_quality = video_info.Quality;
number_of_frames = video_info.NumFrames;

outVid      = vision.VideoFileWriter([OutPath 'extracted.avi'], 'FrameRate', frame_rate,'Quality',video_quality,'VideoCompressor',video_Comp);
%'VideoCompressor', 'MJPEG Compressor');
outMaskVid  = vision.VideoFileWriter([OutPath 'binary.avi'], 'FrameRate', frame_rate,'Quality',video_quality,'VideoCompressor',video_Comp);
%'VideoCompressor', 'MJPEG Compressor');

%     initFrame   = read(inputVid, 1);
initFrame   = step(inputVid);
[m, n, d]   = size(initFrame);

% start read from firts frame
reset(inputVid)
h = waitbar(0, sprintf('Frame processed: %d / %d', 0, round((win_size + 1)/2)),'Name', 'Background substraction initialization ...');

% save video as matrix
count_f = 1;
vid_matrix = single(zeros(m, n,d,number_of_frames));
while count_f < number_of_frames
    vid_matrix(:,:,:,count_f) = single(step(inputVid));
    count_f = count_f + 1;
end

% Counter containing the number of pixels lower than median
low_median = repmat(single(0), [m, n]);

% Histogram (based on time window)
hist_mat = repmat(single(0), [m, n, 256]);

% Median  matrix
median_mat = repmat(single(0), [m, n]);

% Image sized grid
[xx, yy] = meshgrid(1:n, 1:m);

if round((win_size + 1) / 2) >= number_of_frames
    fprintf('input  is too small! (minimum number of frames: %d\n',round((win_size + 1) / 2));
    status = 1;
    return;
end

% Last win_size frames for each pixel
frames_window_mat = repmat(single(0), [m, n, win_size]);

for t = 1:round((win_size + 1)/2)
    new_frame_hsv     = rgb2hsv(vid_matrix(:,:,:,t));
    
    new_frame_value   = single(new_frame_hsv(:, :, 3) * 255); % single
    
    frames_window_mat(:, :, t) = new_frame_value;
    
    % Map intensity values to linear index
    intensity_mat = single(new_frame_value + 1); %double
    idx = sub2ind([m, n, 256], yy(:), xx(:), intensity_mat(:));
    
    if t == 1
        hist_mat(idx) = hist_mat(idx) + 1;
    else
        % Mirror padding for first half window pixels
        hist_mat(idx) = hist_mat(idx) + 2;
    end
    
    waitbar(t / round((win_size + 1)/2), h,sprintf('Frame processed: %d / %d', t, round((win_size + 1)/2)));
end
close(h);
tmp_mat = frames_window_mat;

% Create mirror reflection
frames_window_mat(:, :, 1:round((win_size + 1)/2)) = flipdim(frames_window_mat(:, :, 1:round((win_size + 1)/2)), 3);

frames_window_mat(:, :, (round((win_size + 1)/2) + 1):end) = tmp_mat(:, :, 2:round((win_size + 1)/2));

median_mat = median(frames_window_mat, 3);

% Collect num of pixels smaller than median value
for i = 1 : m*n
    low_median(i) = sum(hist_mat(yy(i), xx(i), 1:median_mat(i) - 1));
end

h = waitbar(0, sprintf('Frame processed: %d / %d', 0, number_of_frames),'Name', 'Background substraction ...');


% Substract BG
% prev_fg_mask = vid_matrix(:,:,1,1)));
% curFrame        = vid_matrix(:,:,:,1);
% curFrameHSV     = rgb2hsv(curFrame);
% prev_fg_mask   = single(curFrameHSV(:, :, 1) * 255);
for f = 16:number_of_frames
    
    
    
    %     curFrame        = read(inputVid, f);
    curFrame        = vid_matrix(:,:,:,f);
    curFrameHSV     = rgb2hsv(curFrame);
    curFrameValue   = single(curFrameHSV(:, :, 3) * 255);
    %     median_mat = median(curFrame, 3);
    
    if f > 1
        % Update median
        if (f + round((win_size -1)/2) <= number_of_frames)
            newFrame = vid_matrix(:,:,:, f + round((win_size - 1)/2));
        else
            % Read in reverse order from the end
            mirrorIdx = number_of_frames - mod(f + round((win_size - 1)/2), number_of_frames);
            newFrame = vid_matrix(:,:,:, mirrorIdx);
        end
        
        new_frame_hsv = rgb2hsv(newFrame);
        new_frame_value = single(new_frame_hsv(:, :, 3) * 255); % (:, :, 1) 
        
        % Histogram update
        intensity_mat = double(new_frame_value + 1);
        idx = sub2ind([m, n, 256], yy(:), xx(:), intensity_mat(:));
        hist_mat(idx) = hist_mat(idx) + 1;
        
        % Remove last element and update histogram
        lastFrameValue = single(frames_window_mat(:, :, 1));
        idx = sub2ind([m, n, 256], yy(:), xx(:), lastFrameValue(:) + 1);
        hist_mat(idx) = hist_mat(idx) - 1;
        
        % Update number of pixels below median
        mask = (lastFrameValue > median_mat) & (new_frame_value < median_mat);
        low_median = low_median + single(mask);
        mask = (lastFrameValue == median_mat) & (new_frame_value < median_mat);
        low_median = low_median + single(mask);
        mask = (lastFrameValue < median_mat) & (new_frame_value > median_mat);
        low_median = low_median - single(mask);
        mask = (lastFrameValue < median_mat) & (new_frame_value == median_mat);
        low_median = low_median - single(mask);
        
        % Calculate median
        thresh = round((win_size - 1) / 2);
        for i = 1:m
            for j = 1:n
                %lower median
                while low_median(i, j) > thresh
                    median_mat(i, j) = median_mat(i, j) - 1;
                    low_median(i,j) = low_median(i, j) - hist_mat(i, j, median_mat(i, j) + 1);
                end
                %higher median
                while (median_mat(i, j) < 255) && (low_median(i, j) + hist_mat(i, j, median_mat(i, j) + 1)) <= thresh
                    low_median(i, j) = low_median(i, j) + hist_mat(i, j, median_mat(i, j) + 1);
                    median_mat(i, j) = median_mat(i, j) + 1;
                    while (median_mat(i, j) < 255) && (hist_mat(i, j, median_mat(i, j) + 1) == 0)
                        median_mat(i, j) = median_mat(i, j) + 1;
                    end
                end
            end
        end
        
        % Update frame window
        frames_window_mat = circshift(frames_window_mat, [0, 0, -1]);
        frames_window_mat(:, :, win_size) = new_frame_value;
    end
    
    diff = (abs(median_mat - curFrameValue) >bg_thresh); %
    %     fg_mask = diff;
    %     fg_mask = (fg_mask == 0);
    
    
    %     fg_mask = getFgMask(diff);
    
    %     tt = bwmorph(abs(median_mat - curFrameValue),'close');
    % Morphologic monipulations
    fg_mask_tmp = imdilate(diff, strel('disk', 5));
    fg_mask_tmp = imfill(fg_mask_tmp,'holes');
    fg_mask_tmp = imclose(fg_mask_tmp,strel('disk',10));
    fg_mask_tmp = imfill(fg_mask_tmp,'holes');
    fg_mask_tmp = imerode(fg_mask_tmp, strel('disk', 4));
    fg_mask_tmp = imclose(fg_mask_tmp,strel('disk',2));
%     fg_mask_tmp = bwmorph(fg_mask_tmp, 'bridge', 1000);
    fg_mask_tmp = bwareafilt(fg_mask_tmp,1);
    fg_mask = imfill(fg_mask_tmp, 'holes');
    curFrameNoBG = repmat(single(fg_mask), [1 1 3]).* (curFrame);
%     regions = regionprops(fg_mask_tmp, 'Area', 'PixelIdxList', 'BoundingBox');
%     [~,indx] = sort([regions.Area],'descend');
%     mask = false(size(fg_mask_tmp));
%     if length(indx) > 1
%         regions = regions(indx(1:2));
%         if regions(1).PixelIdxList(1:length(regions(2).PixelIdxList)) < regions(2).PixelIdxList
%             mask(regions(1).PixelIdxList) = true;
%             mask(regions(2).PixelIdxList) = true;
%         else
%             mask(regions(1).PixelIdxList) = true;
%         end
%     else
%         mask(regions.PixelIdxList) = true;
%     end

%     curFrameNoBG = repmat(single(fg_mask), [1 1 3]).* (curFrame);
    %     prev_fg_mask = fg_mask;
    if and(f>13 ,f<number_of_frames -2)
        step(outVid, curFrameNoBG);
        step(outMaskVid, fg_mask * 255);
    end
    
    %     if Debug && mod(f, 10) == 0
    %         imwrite(diff * 255, sprintf(mask'../output/frames/diff_f_%d.jpg', f));
    %         imwrite(fgMask * 255, sprintf('../output/frames/mask_f_%d.jpg', f));
    %     end
    
    
    
    % Update waitbar
    waitbar(f / number_of_frames, h, sprintf('Frame processed: %d / %d',f, number_of_frames));
    
end

release(outMaskVid);
release(outVid);
release(inputVid);
close(h);

status = 0;
end

