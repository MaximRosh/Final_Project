function [ im_edges ] = getEdges(im_in, downsample_rate)

    [~, im_grad] = imgradient(im_in, 'sobel');

    im_gray_edge = bwareaopen(im_grad, ceil(75 / downsample_rate));

    im_edges = imfill(im_gray_edge, 'holes');

    im_edges = bwareaopen(im_edges, 500);

end
