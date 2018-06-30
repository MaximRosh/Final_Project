function [ status ] = tracking2( input_vidPath, output_vidPath, manualSelection, ROI )
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

% % Select ROI
% if manualSelection ~= 0
%     
%     f = figure('name', 'Please select object rectangle', 'NumberTitle', 'off');
%     imshow(init_frame);
%     h = imrect;
%     position = wait(h);
%     if isempty(position)
%         close(f);
%         errordlg('No object selected!');
%         status = 1;
%         return;
%     end
%     close(f);
% else
    position = ROI;
    if position(1) > cols
        fprintf('Invalid X coordinate specified\n');
        status = 1;
        return;
    elseif position(1) + position(3) > cols
        position(3) = cols - position(1);
    end
    
    if position(2) > rows
        fprintf('Invalid Y coordinate specified\n');
        status = 1;
        return;
    elseif position(2) + position(4) > rows
        position(4) = rows - position(2);
    end
% end

half_width  = position(3) / 2;
half_height = position(4) / 2;
x_center = position(1) + half_width;
y_center = position(2) + half_height;

% Initial Settings
N = 100;
init_S = [x_center; y_center;  half_width ; half_height; 0 ;0];    % x_center ;y_center ;half_width; half_height; velocity_x; velocity_y

% CREATE INITIAL PARTICLE MATRIX 'S' (SIZE 6xN)
S = predictParticles(repmat(init_S, 1, N));

% COMPUTE NORMALIZED HISTOGRAM
q = compNormHist(init_frame, init_S);

W = compNormWeights(init_frame, S, q);
C = cumsum(W);

shape_inserter = vision.ShapeInserter('BorderColor', 'Custom', 'CustomBorderColor', [255 0 0]);

f = 1;
waitBar = waitbar(0, sprintf('Frame processed: %d / %d', f, number_of_frames), 'Name', 'Tracking ...');

for i = 2:number_of_frames
    prev_S = S;
    
    new_frame = step(inputVid);
    
    % SAMPLE THE CURRENT PARTICLE FILTERS
    next_tag_S = sampleParticles(prev_S, C);
    
    % PREDICT THE NEXT PARTICLE FILTERS
    next_S = predictParticles(next_tag_S);
    
    % COMPUTE NORMALIZED WEIGHTS (W) AND PREDICTOR CDFS (C)
    W = compNormWeights(new_frame, next_S, q);
    C = cumsum(W);
    
    % SAMPLE NEW PARTICLES FROM THE NEW CDF'S
    S = sampleParticles(next_S, C);
    
    % CREATE DETECTOR PLOTS
    %         if (mod(i, 10)==0)
    %             showParticles(newFrame, S, W, i);
    %         end
    
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
