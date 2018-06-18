% filename = 'shaky_car.avi';
filename ='C:\Users\Maximus\Desktop\Toar_Sheni\Video Processing - 2018\FinalProject\Input\INPUT.avi';
hVideoSrc = vision.VideoFileReader(filename, 'ImageColorSpace', 'RGB');

fRate         = VideoReader(filename).FrameRate;
nFrames       = VideoReader(filename).NumberOfFrames;

stabilizedVid    = vision.VideoFileWriter(OutPath, ...
    'FrameRate', fRate);
% Step 1. Read Frames from a Movie File

imgA = rgb2gray(step(hVideoSrc)); % Read first frame into imgA
imgB = rgb2gray(step(hVideoSrc)); % Read second frame into imgB

% Step 2. Collect Salient Points from Each Frame

% ptThresh = 0.1;
% pointsA = detectFASTFeatures(imgA, 'MinContrast', ptThresh);
% pointsB = detectFASTFeatures(imgB, 'MinContrast', ptThresh);

pointsA = detectHarrisFeatures(imgA);
pointsB = detectHarrisFeatures(imgB);

% Step 3. Select Correspondences Between Points
% Extract Fast Retina Keypoint (FREAK) descriptors for the corners
[featuresA, pointsA] = extractFeatures(imgA, pointsA);
[featuresB, pointsB] = extractFeatures(imgB, pointsB);
% Match features which were found in the current and the previous frames. 
indexPairs = matchFeatures(featuresA, featuresB);
pointsA = pointsA(indexPairs(:, 1), :);
pointsB = pointsB(indexPairs(:, 2), :);

% Step 4. Estimating Transform from Noisy Correspondences

[tform, pointsBm, pointsAm] = estimateGeometricTransform(pointsB, pointsA, 'affine');
imgBp = imwarp(imgB, tform, 'OutputView', imref2d(size(imgB)));
pointsBmp = transformPointsForward(tform, pointsBm.Location);

% Step 5. Transform Approximation and Smoothing

% Extract scale and rotation part sub-matrix.
H = tform.T;
R = H(1:2,1:2);
% Compute theta from mean of two possible arctangents
theta = mean([atan2(R(2),R(1)) atan2(-R(3),R(4))]);
% Compute scale from mean of two stable mean calculations
scale = mean(R([1 4])/cos(theta));
% Translation remains the same:
translation = H(3, 1:2);
% Reconstitute new s-R-t transform:
HsRt = [[scale*[cos(theta) -sin(theta); sin(theta) cos(theta)]; translation], [0 0 1]'];
tformsRT = affine2d(HsRt);

imgBold = imwarp(imgB, tform, 'OutputView', imref2d(size(imgB)));
imgBsRt = imwarp(imgB, tformsRT, 'OutputView', imref2d(size(imgB)));

% Step 6. Run on the Full Video

% Reset the video source to the beginning of the file.
reset(hVideoSrc);

hVPlayer = vision.VideoPlayer; % Create video viewer

% Process all frames in the video
movMean = step(hVideoSrc);
imgB = movMean;
imgBp = imgB;
correctedMean = imgBp;
ii = 2;
Hcumulative = eye(3);
while ~isDone(hVideoSrc) && ii < 1000
    % Read in new frame
    imgA = imgB; % z^-1
    imgAp = imgBp; % z^-1
    imgB = rgb2gray(step(hVideoSrc));
    movMean = movMean + imgB;

    % Estimate transform from frame A to frame B, and fit as an s-R-t
    H = cvexEstStabilizationTform(imgA,imgB);
    HsRt = cvexTformToSRT(H);
    Hcumulative = HsRt * Hcumulative;
    imgBp = imwarp(imgB,affine2d(Hcumulative),'OutputView',imref2d(size(imgB)));

    % Display as color composite with last corrected frame
    rgb2gray(step(hVPlayer, imfuse(imgAp,imgBp,'ColorChannels','red-cyan')));
    correctedMean = correctedMean + imgBp;

    ii = ii+1;
end
correctedMean = correctedMean/(ii-2);
movMean = movMean/(ii-2);

% Here you call the release method on the objects to close any open files
% and release memory.
release(hVideoSrc);
release(hVPlayer);
