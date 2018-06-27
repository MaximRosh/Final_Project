function [ mask ] = getFgMask_ilya( bwImg )
%
% Filter noise by morphological operations
%
    bwTmp = imfill(bwImg, 'holes');
    bwTmp = bwmorph(bwTmp, 'bridge', 100);
    bwTmp = imdilate(bwTmp, strel('disk', 1));
    
    bwTmp = imerode(bwTmp, strel('disk', 2));
    bwTmp = imfill(bwTmp, 'holes');

    % Get connected components
    cc = bwconncomp(bwTmp, 8);
    if (cc.NumObjects ~= 0)
         % Getting more information about the connected-components
         rp = regionprops(cc, 'Area', 'PixelIdxList', 'BoundingBox');
         % Sorting by size, largest first
         [~, ind] = max([rp.Area]);
         % Keeping only the largest connected component
         rp = rp(ind); 
         % p = round(rp.BoundingBox);
         % Setting relevant indices in the output array
         mask = false(size(bwTmp));         
         mask(rp.PixelIdxList) = true; 
    else
         mask = bwTmp;
    end
    
    mask = bwmorph(mask, 'bridge', 100);
    mask = imfill(mask, 'holes');
    mask = imclearborder(mask);

end

