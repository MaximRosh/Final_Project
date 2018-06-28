function [ status ] = bg_substract( video_in_path, video_out_path, OutMaskPath, BGth, winSize, Debug )
warning('off')
% video_in_path ='C:\Users\Maximus\Desktop\Toar_Sheni\Video Processing - 2018\FinalProject\stabilize_INPUT_FAST2.avi';
status = 0;
input_video = vision.VideoFileReader(video_in_path, 'ImageColorSpace', 'RGB');
video_info = aviinfo(video_in_path);
frame_rate = video_info.FramesPerSecond;
number_of_frames = video_info.NumFrames;
extracted_video = vision.VideoFileWriter([video_out_path 'extracted.avi'], 'FrameRate', frame_rate);

%Use first frame as Background Image
background = step(input_video);

%Read second Frame
cur_frame = step(input_video);


% %Display Background and Foreground
% figure(33)
% subplot(2,2,1);imshow(background);title('BackGround');
% subplot(2,2,2);imshow(cur_frame-background);title('Current Frame')


% Save modified RGB frame

sigma = 0.5;
sub_im = cur_frame-background;
% imshow(sub_im)
% I_RGB2 = imgaussfilt(cur_frame-background, sigma);
% % figure(33)
% [~, im_grad] = imgradient(rgb2gray(I_RGB2), 'roberts');
% % imshow(im_grad)
% im_gray_edge = bwareaopen(im_grad, ceil(75 / 1));
% % imshow(im_gray_edge)
% im_edges = imfill(im_gray_edge, 'holes');
% % imshow(im_edges)
% im_edges = bwareaopen(im_edges, 500);
% % imshow(im_edges)
% % figure(33)
% % imshow(cur_frame-background);
% % imshow(I_RGB2);
step(extracted_video, sub_im);
h = waitbar(0, sprintf('Frame processed: %d / %d', 1, number_of_frames), ...
    'Name', 'Stabilizing video ...');
for i=1:number_of_frames
    background = cur_frame;
    cur_frame = step(input_video);
    
    
    sub_im = cur_frame-background;

%     [~, im_grad] = imgradient(rgb2gray(sub_im), 'sobel');
% 
%     im_gray_edge = bwareaopen(im_grad, ceil(75 / 1));
% 
%     im_edges = imfill(im_gray_edge, 'holes');
% 
%     im_edges = bwareaopen(im_edges, 500);
%     
    step(extracted_video, sub_im);
        waitbar(i / number_of_frames, h, ...
        sprintf('Frame processed: %d / %d', i, number_of_frames));
end
close(h)

% Save stabilized RGB video
release(extracted_video);
% Close input video
release(input_video);


%Convert RGB 2 HSV Color conversion
[background_hsv]=uint8(round(rgb2hsv(background)));
[currentFrame_hsv]=uint8(round(rgb2hsv(cur_frame)));
out = bitxor(background_hsv,currentFrame_hsv);


% subplot(2,2,1);imshow(Background_hsv);title('BackGround');
% subplot(2,2,2);imshow(Out);title('Current Frame')

%Convert RGB 2 GRAY
out=rgb2gray(out);

%Read Rows and Columns of the Image
[rows columns]=size(out);

%Convert to Binary Image
for i=1:rows
    for j=1:columns
        
        if out(i,j) >0
            
            binaryImage(i,j)=1;
            
        else
            
            binaryImage(i,j)=0;
            
        end
        
    end
end

%Apply Median filter to remove Noise
filteredImage=medfilt2(binaryImage,[5 5]);


%Boundary Label the Filtered Image
[L num]=bwlabel(filteredImage);

STATS=regionprops(L,'all');
cc=[];
removed=0;

%Remove the noisy regions
for i=1:num
    dd=STATS(i).Area;
    
    if (dd < 500)
        
        L(L==i)=0;
        removed = removed + 1;
        num=num-1;
        
    else
        
    end
    
end

[L2 num2]=bwlabel(L);

% Trace region boundaries in a binary image.

[B,L,N,A] = bwboundaries(L2);

%Display results

% subplot(2,2,3),  imshow(L2);title('BackGround Detected');
% subplot(2,2,4),  imshow(L2);title('Blob Detected');

hold on;

for k=1:length(B),
    
    if(~sum(A(k,:)))
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), 'r','LineWidth',2);
        
        for l=find(A(:,k))'
            boundary = B{l};
            plot(boundary(:,2), boundary(:,1), 'g','LineWidth',2);
        end
        
    end
    
end



