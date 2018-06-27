paath_to_video = 'C:\Users\Maximus\Desktop\Toar_Sheni\Video Processing - 2018\FinalProject\OUTPUT\stabilized.avi';
v = VideoReader(paath_to_video);
video = read(v);
size(video)
imshow(video(:,:,:,200))
ff = video(:,:,:,200);
imshow(ff)
ff(ff == 0) = 255; 
% Read only the first video frame.


%Read only the last video frame.


%Read frames 5 through 10.

% video = read(v,[5 10]);