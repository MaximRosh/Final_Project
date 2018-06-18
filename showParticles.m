function showParticles(I,s,W,i,ID)
figure
imshow(I);
title([ID ' - Frame number = ' num2str(i)]);
hold on
% Compure red Border
% largest weight
[~,indxMax] = max(W);
% Compute maximal particle filter
xMinR = max(s(2,indxMax)-s(4,indxMax),1); xMaxR = min(s(2,indxMax)+s(4,indxMax),size(I,2));
yMinR = max(s(1,indxMax)-s(3,indxMax),1) ; yMaxR = min(s(1,indxMax)+s(3,indxMax),size(I,1));
% Create red lines
rLx1 = [xMinR:xMaxR;repmat(yMinR,1,length(xMinR:xMaxR))]';
rLx2 = [xMinR:xMaxR;repmat(yMaxR,1,length(xMinR:xMaxR))]';
rLy1 = [repmat(xMinR,1,length(yMinR:yMaxR));yMinR:yMaxR]';
rLy2 = [repmat(xMaxR,1,length(yMinR:yMaxR));yMinR:yMaxR]';
% Plot maximal particle filter
plot(rLx1(:,2),rLx1(:,1),'r',rLx2(:,2),rLx2(:,1),'r',rLy1(:,2),rLy1(:,1),'r',rLy2(:,2),rLy2(:,1),'r')

% Compure green Border
% Average weight
[sortW,indxSort] = sort(W);
[~,indxssAvg] = find(((max(W)-min(W))/2)<sortW);
indxAvg = indxSort(indxssAvg(1));
% Compute average particle filter
xMinG = max(s(2,indxAvg)-s(4,indxAvg),1); xMaxG = min(s(2,indxAvg)+s(4,indxAvg),size(I,2));
yMinG = max(s(1,indxAvg)-s(3,indxAvg),1) ; yMaxG = min(s(1,indxAvg)+s(3,indxAvg),size(I,1));
% Create Green lines
gLx1 = [xMinG:xMaxG;repmat(yMinG,1,length(xMinG:xMaxG))]';
gLx2 = [xMinG:xMaxG;repmat(yMaxG,1,length(xMinG:xMaxG))]';
gLy1 = [repmat(xMinG,1,length(yMinG:yMaxG));yMinG:yMaxG]';
gLy2 = [repmat(xMaxG,1,length(yMinG:yMaxG));yMinG:yMaxG]';
% Plot average particle filter
plot(gLx1(:,2),gLx1(:,1),'g',gLx2(:,2),gLx2(:,1),'g',gLy1(:,2),gLy1(:,1),'g',gLy2(:,2),gLy2(:,1),'g')

% ADD CODE LINES HERE TO PLOT THE RED AND GREEN RECTANGLE ABOVE THE IMAGE
% DO NOT DELETE THE ORIGINAL CODE LINES 3-5 AND 12-13
print(1, '-dpng', '-r300','-noui',[ID,'-HW3-',num2str(i),'.png'])
close
end

