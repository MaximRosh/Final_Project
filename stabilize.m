function [ status ] = stabilize( video_in_path, video_out_path, pixel_to_crop, max_corner_distance)
warning('off')
min_num_of_points = 3;
status = 0;
input_video = vision.VideoFileReader(video_in_path, 'ImageColorSpace', 'RGB');
video_info = aviinfo(video_in_path);
frame_rate = video_info.FramesPerSecond;
video_Comp = 'None (uncompressed)';%'DV Video Encoder'; %'MJPEG Compressor'; % video_info.VideoCompression; %
video_quality = video_info.Quality;
number_of_frames = video_info.NumFrames;
stabilized_vid = vision.VideoFileWriter([video_out_path 'stabilized.avi'], 'FrameRate', frame_rate,'Quality',video_quality,'VideoCompressor',video_Comp);

cur_frame = step(input_video);
cur_frame_value = rgb2gray(cur_frame);
% Detec and Extract features from first frame
first_frame_points = detectSURFFeatures(cur_frame_value);
[first_frame_features, first_frame_points] = extractHOGFeatures(cur_frame_value, first_frame_points);
% Accumulated affine transformation:
H = eye(3);
g_transformer = vision.GeometricTransformer('BackgroundFillValue',255); % 'ROIShape' ,'Polygon ROI'
g_estimator = vision.GeometricTransformEstimator;
% Progress bar
h = waitbar(0, sprintf('Frame processed: %d / %d', 1, number_of_frames), 'Name', 'Stabilizing video ...');
for f = 2 : number_of_frames
    warp_frame_background = cur_frame;
    prev_frame_value = cur_frame_value;
    cur_frame = step(input_video);
    cur_frame_value = rgb2gray(cur_frame);
    % Detect points of interest (corners)
    prev_points = detectSURFFeatures(prev_frame_value);
    cur_points = detectSURFFeatures(cur_frame_value);
    % Extract HOG descriptors for the corners
    [prev_features, prev_points] = extractHOGFeatures(prev_frame_value, prev_points);
    [cur_features, cur_points] = extractHOGFeatures(cur_frame_value, cur_points);
    % Match features to base frame
    index_pairs = matchFeatures(first_frame_features, cur_features);
    first_frame_match_points = first_frame_points(index_pairs(:, 1), :);
    cur_match_points = cur_points(index_pairs(:, 2), :);
    % Filter far points from base frame
    near_points = [];
    count = 0;
    tresh = max_corner_distance;
    while length(near_points) < 15 && count < 10
        dists = sqrt(sum((first_frame_match_points.Location - cur_match_points.Location).^2, 2));
        near_points = find(dists < tresh);
        tresh  = tresh * 1.5;
        count = count + 1;
    end
    new_match_points  = cur_match_points(near_points(:, 1), :);
    % Match new filtered features to previous ones
    [new_features, new_points] = extractHOGFeatures(cur_frame_value, new_match_points);
    index_pairs = matchFeatures(prev_features, new_features);
    prev_match_points = prev_points(index_pairs(:, 1), :);
    new_match_points  = new_points(index_pairs(:, 2), :);
    if size(index_pairs, 1) >= min_num_of_points
        % Calculate affine transformation
        try
            temp_H = step(g_estimator, new_match_points.Location, prev_match_points.Location);
        catch
            fprintf('Unable to estimate affine transformation\n');
            status = 1;
            break;
        end
        temp_H = horzcat(temp_H, [0; 0; 1]);
        H = temp_H * H;
        try
            warp_frame = step(g_transformer, cur_frame, H);
        catch
            fprintf('Unable to warp frame back\n');
            status = 1;
            break;
        end
    else
        fprintf('Not enough points for affine transformation\n');
        warp_frame = cur_frame;
    end
    warp_frame(warp_frame > 185) = warp_frame_background(warp_frame > 185);
    step(stabilized_vid, warp_frame(pixel_to_crop:end-pixel_to_crop/2,pixel_to_crop:end-pixel_to_crop/2, :));
    % Update waitbar
    waitbar(f / number_of_frames, h, sprintf('Frame processed: %d / %d', f, number_of_frames));
end
close(h);
% Save stabilized RGB video
release(stabilized_vid);
% Close input video
release(input_video);
end