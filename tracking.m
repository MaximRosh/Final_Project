function [ status ] = tracking( inputVidPath, outputVidPath, manualSelection, ROI )

inputVid   = vision.VideoFileReader(inputVidPath, 'ImageColorSpace', 'RGB','VideoOutputDataType', 'uint8');

video_info = aviinfo(inputPath);
frame_rate = video_info.FramesPerSecond;
video_Comp = 'DV Video Encoder'; %'MJPEG Compressor'; %'None (uncompressed)';%'DV Video Encoder'; %'MJPEG Compressor'; % video_info.VideoCompression; %
video_quality = video_info.Quality;
number_of_frames = video_info.NumFrames;

outputVid   = vision.VideoFileWriter(outputVidPath,'FrameRate', frame_rate,'Quality',video_quality,'VideoCompressor',video_Comp);
initFrame = step(inputVid);
[rows, cols, ~] = size(initFrame);

% Select ROI
if manualSelection ~= 0
    
    f = figure('name', 'Please select object rectangle', 'NumberTitle', 'off');
    imshow(initFrame);
    h = imrect;
    position = wait(h);
    if isempty(position)
        close(f);
        errordlg('No object selected!');
        status = 1;
        return;
    end
    close(f);
else
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
end

halfWidth  = position(3) / 2;
halfHeight = position(4) / 2;
cX = position(1) + halfWidth;
cY = position(2) + halfHeight;

% Initial Settings
N = 100;
initS = [cX         % x center
    cY         % y center
    halfWidth  % half width
    halfHeight % half height
    0          % velocity x
    0   ];     % velocity y

% CREATE INITIAL PARTICLE MATRIX 'S' (SIZE 6xN)
S = predictParticles(repmat(initS, 1, N));

% COMPUTE NORMALIZED HISTOGRAM
q = compNormHist(initFrame, initS);

W = compNormWeights(initFrame, S, q);
C = cumsum(W);

shapeInserter = ...
    vision.ShapeInserter('BorderColor', 'Custom', ...
    'CustomBorderColor', [255 0 0]);

f = 1;
waitBar = waitbar(0, sprintf('Frame processed: %d / %d', f, number_of_frames), ...
    'Name', 'Tracking ...');

for i = 2:number_of_frames
    prevS = S;
    
    newFrame = step(inputVid);
    
    % SAMPLE THE CURRENT PARTICLE FILTERS
    nextTagS = sampleParticles(prevS, C);
    
    % PREDICT THE NEXT PARTICLE FILTERS
    nextS = predictParticles(nextTagS);
    
    % COMPUTE NORMALIZED WEIGHTS (W) AND PREDICTOR CDFS (C)
    W = compNormWeights(newFrame, nextS, q);
    C = cumsum(W);
    
    % SAMPLE NEW PARTICLES FROM THE NEW CDF'S
    S = sampleParticles(nextS, C);
    
    % CREATE DETECTOR PLOTS
    %         if (mod(i, 10)==0)
    %             showParticles(newFrame, S, W, i);
    %         end
    
    % Draw tracking rectangle
    hW  = S(3, 1);
    hH  = S(4, 1);
    cX  = S(1, :) * W';
    cY  = S(2, :) * W';
    
    x   = int16(round(max(cX - hW, 1)));
    w   = int16(round(min(hW * 2, cols - x)));
    y   = int16(round(max(cY - hH, 1)));
    h   = int16(round(min(hH * 2, rows - y)));
    
    trackFrame = step(shapeInserter, newFrame, [x, y, w, h]);
    step(outputVid, trackFrame);
    
    % Update progress bar
    f = f + 1;
    waitbar(f / number_of_frames, waitBar, ...
        sprintf('Frame processed: %d / %d', f, number_of_frames));
end

close(waitBar);
release(outputVid);
release(inputVid);

status = 0;
end
