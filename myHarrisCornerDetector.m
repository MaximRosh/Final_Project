function [I_CORNERS] = myHarrisCornerDetector(IN,K,Threshold)
if size(IN,3) > 1
    IN_Gray = rgb2gray(IN);
else
    IN_Gray = IN;
end
% Compute all derivatives in x and in y in the	image
I_shiftRight = circshift(IN_Gray,1,2);
I_shiftDown = circshift(IN_Gray,1,1);

I_x = IN_Gray - I_shiftRight;
I_y = IN_Gray - I_shiftDown;

% Compute the M matrix
g = ones(5,5);
S_xx = conv2(I_x.^2,g,'same');
S_xy = conv2(I_x.*I_y,g,'same');
S_yy = conv2(I_y.^2,g,'same');

% Find corner
R = S_xx.*S_yy - S_xy.*S_xy - K*(S_xx+S_yy);

R(R < Threshold) = 0;

I_CORNERS = imregionalmax(R);



