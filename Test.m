clc
clear all
InPath = '..\INPUT\INPUT91.avi';
OutPath = '..\OUTPUT\stabilize_INPUT91_surf.avi';

% % InPath = 'C:\Users\Maximus\Desktop\Toar_Sheni\Video Processing - 2018\FinalProject\Input\INPUT.avi';
% InPath = 'C:\Users\Maxim\Desktop\Toar Sheni\Video\FinalProject\Input\INPUT.mp4';
% % OutPath = 'C:\Users\Maximus\Desktop\Toar_Sheni\Video Processing - 2018\FinalProject\stabilize_INPUT_FAST2.avi';
% OutPath = 'C:\Users\Maxim\Desktop\Toar Sheni\Video\FinalProject\stabilize_INPUT_FAST2.avi';

pxToCrop  = 60;
pxMaxDist = 10;

% status  = stabilize( InPath, OutPath, pxToCrop, pxMaxDist );
tic
status  = stabilize_max2( InPath, OutPath, pxToCrop, pxMaxDist );
toc
disp('Done')