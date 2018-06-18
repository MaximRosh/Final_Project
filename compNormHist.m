function normHist = compNormHist(I,s)
% Bin numbers
BinNum = 16;
% Compure I_subportion using data from s
I_subportion = I(max(s(2)-s(4),1):min(s(2)+s(4),size(I,1)),max(s(1)-s(3),1):min(s(1)+s(3),size(I,2)),:);
% Preparation
levels = 1:1:BinNum;
LUT = reshape(repmat(levels', 1, BinNum)', BinNum^2, 1);
% Qauntization
quantized_I_subportion = LUT(1 + I_subportion);
% Separate to channels
quantizedR = quantized_I_subportion(:, :, 1) * BinNum^2;
quantizedG = quantized_I_subportion(:, :, 2) * BinNum;
quantizedB = quantized_I_subportion(:, :, 3);
% Combine all channels
quantizedTotal = quantizedR + quantizedG + quantizedB;
% Compute Histogram
tempHist = hist(quantizedTotal(:), 0.5:1:BinNum^3)';
% Normalize Histogram
normHist = tempHist / sum(tempHist);