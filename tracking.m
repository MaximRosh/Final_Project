function [ status ] = tracking( input_vidPath, output_vidPath, ROI,N)
warning('off')
inputVid   = vision.VideoFileReader(input_vidPath, 'ImageColorSpace', 'RGB','VideoOutputDataType', 'uint8');
video_info = aviinfo(input_vidPath);
frame_rate = video_info.FramesPerSecond;
video_Comp = 'None (uncompressed)'; %'MJPEG Compressor'; %'None (uncompressed)';%'DV Video Encoder'; %'MJPEG Compressor'; % video_info.VideoCompression; %
video_quality = video_info.Quality;
number_of_frames = video_info.NumFrames;

output_vid   = vision.VideoFileWriter(output_vidPath,'FrameRate', frame_rate,'Quality',video_quality,'VideoCompressor',video_Comp);

init_frame = step(inputVid);
[rows, cols, ~] = size(init_frame);
% get ROI coordinats
if ROI(1) > cols
    fprintf('Invalid X coordinate specified\n');
    status = 1;
    return;
elseif ROI(1) + ROI(3) > cols
    ROI(3) = cols - ROI(1);
end
if ROI(2) > rows
    fprintf('Invalid Y coordinate specified\n');
    status = 1;
    return;
elseif ROI(2) + ROI(4) > rows
    ROI(4) = rows - ROI(2);
end
half_width  = ROI(3) / 2;
half_height = ROI(4) / 2;
x_center = ROI(1) + half_width;
y_center = ROI(2) + half_height;
% Initial Settings
% N = 100;
init_S = [x_center; y_center;  half_width ; half_height; 0 ;0];    % x_center ;y_center ;half_width; half_height; velocity_x; velocity_y
% Create initial particle matrix 'S' from (size 6xN) as in homework N =100
S = predictParticles(repmat(init_S, 1, N));
% Compute normalized histogram
q = compNormHist(init_frame, init_S);
W = compNormWeights(init_frame, S, q);
C = cumsum(W);
shape_inserter = vision.ShapeInserter('BorderColor', 'Custom', 'CustomBorderColor', [255 0 0]);
f = 1;
waitBar = waitbar(0, sprintf('Frame processed: %d / %d', f, number_of_frames), 'Name', 'Tracking ...');
for i = 2:number_of_frames
    prev_S = S;
    new_frame = step(inputVid);
    % Sample the current particle filters
    next_tag_S = sampleParticles(prev_S, C);
    % Predict the next particle filter
    next_S = predictParticles(next_tag_S);
    % Compute normalized weights (W) and predictor CDFS (C)
    W = compNormWeights(new_frame, next_S, q);
    C = cumsum(W);
    % Sample new particle from the new CDF'S
    S = sampleParticles(next_S, C);
    % Draw tracking rectangle
    h_W  = S(3, 1);
    h_H  = S(4, 1);
    x_center  = S(1, :) * W';
    y_center  = S(2, :) * W';
    x   = int16(round(max(x_center - h_W, 1)));
    w   = int16(round(min(h_W * 2, cols - x)));
    y   = int16(round(max(y_center - h_H, 1)));
    h   = int16(round(min(h_H * 2, rows - y)));
    track_frame = step(shape_inserter, new_frame, [x, y, w, h]);
    step(output_vid, track_frame);
    % Update progress bar
    f = f + 1;
    waitbar(f / number_of_frames, waitBar, sprintf('Frame processed: %d / %d', f, number_of_frames));
end
close(waitBar);
release(output_vid);
release(inputVid);
status = 0;
end
