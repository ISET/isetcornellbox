% s_cbMccIlluminant
% Verify different illumination 
%% PART I: Load the real sensor image
%%%%%%%%%%%%%%%%%%%%% Create sensor for illuminant A %%%%%%%%%%%%%%%%%%%%%%
imgAName = 'IMG_20201024_123128.dng';
% Read the rectangle of the image
thisRect = [1860  2010  350  255]; %col, row, width, height
[~, ~, ipA] = cbDNGRead(imgAName, 'crop', thisRect, 'demosaic', true);
ipWindow(ipA);
%%%%%%%%%%%%%%%%%%%% Create sensor for illuminant CWF %%%%%%%%%%%%%%%%%%%%%                                               
imgCWFName = 'IMG_20201024_122900.dng';
% Read the rectangle of the image
thisRect = [1860  2010  370  290]; %col, row, width, height
[~, ~, ipCWF] = cbDNGRead(imgCWFName, 'crop', thisRect, 'demosaic', true);
ipWindow(ipCWF);
%%%%%%%%%%%%%%%%%%%% Create sensor for illuminant Day %%%%%%%%%%%%%%%%%%%%%                                               
imgDayName = 'IMG_20201024_122631.dng';
% Read the rectangle of the image
thisRect = [1860  2010  370  290]; %col, row, width, height
[~, ~, ipDay] = cbDNGRead(imgDayName, 'crop', thisRect, 'demosaic', true);
ipWindow(ipDay);
%%%%%%%%%%%%%%%%%%%% Create sensor for lamp in cornell box %%%%%%%%%%%%%%%%
imgCBName = 'IMG_20201212_112601_1.dng'; %% mcc image
% Read crop of the DNG file
thisRect = [1844 1808 500 350]; %col, row, width, height
[~, ~, ipCB] = cbDNGRead(imgCBName, 'crop', thisRect, 'demosaic', true);
ipWindow(ipCB);
%% Create sensor
%%%%%%%%%%%%%%%%%%%%% Create sensor for illuminant A %%%%%%%%%%%%%%%%%%%%%%
imgAName = 'IMG_20201024_123128.dng';
% Select the corner points: bottom left, bottom right, top right, top left
% cpDay = chartCornerpoints(camera_day);   % Select corners
cpAR = [38 222; 316 224; 314 41; 40 40];

% Read DNG files and other info
[sensorAR, infoAR, rgbMeanAR, rectsAR] = cbMccChipsDV(imgAName,...
                                                    'corner point', cpAR,...
                                                    'crop', thisRect);
%{
sensorWindow(sensorAR);
chartRectsDraw(sensorAR,rectsAR);  % Visualize the rectangles
%}
%%%%%%%%%%%%%%%%%%%% Create sensor for illuminant CWF %%%%%%%%%%%%%%%%%%%%%                                               
imgCWFName = 'IMG_20201024_122900.dng';
% Select the corner points: bottom left, bottom right, top right, top left
% cpDay = chartCornerpoints(camera_day);   % Select corners
cpCWFR = [62 218; 337 222; 337 38; 63 37];
% Read the rectangle of the image
thisRect = [1860  2010  370  290]; %col, row, width, height
% Read DNG files and other info
[sensorCWFR, infoCWFR, rgbMeanCWFR, rectsCWFR] = cbMccChipsDV(imgCWFName,...
                                                    'corner point', cpCWFR,...
                                                    'crop', thisRect);
%{
sensorWindow(sensorCWFR);
chartRectsDraw(sensorCWFR,rectsCWFR);  % Visualize the rectangles
%}                                                
%%%%%%%%%%%%%%%%%%%% Create sensor for illuminant Day %%%%%%%%%%%%%%%%%%%%%                                               
imgDayName = 'IMG_20201024_122631.dng';
% Select the corner points: bottom left, bottom right, top right, top left
% cpDay = chartCornerpoints(camera_day);   % Select corners
cpDayR = [73 218; 344 222; 344 39; 73 36];
% Read the rectangle of the image
thisRect = [1860  2010  370  290]; %col, row, width, height
% Read DNG files and other info
[sensorDayR, infoDayR, rgbMeanDayR, rectsDayR] = cbMccChipsDV(imgDayName,...
                                                    'corner point', cpDayR,...
                                                    'crop', thisRect);
%%%%%%%%%%%%%%%%%%%% Create sensor for lamp in cornell box %%%%%%%%%%%%%%%%
imgName1 = 'IMG_20201212_112601_1.dng'; %% mcc image
% sensorMcc = sensorDNGRead(imgName1);
% Read crop of the DNG file
thisRect = [1844 1808 500 350]; %col, row, width, height
% Select the corner points: bottom left, bottom right, top right, top left
% cpR = chartCornerpoints(sensorMcc);   % Select corners
cpR = [14 332; 489 332; 484 12; 12 13];
% Read DNG files and other info
[sensorMcc, infoR, rgbMeanCBR, roisR] = cbMccChipsDV(imgName1,...
                                                    'corner point', cpR,...
                                                    'crop', thisRect);
%{
sensorWindow(sensorMcc);
chartRectsDraw(sensorMcc,roisR);  % Visualize the rectangles
%}
                                                    
%%
dvBlvl = sensorGet(sensorAR, 'black level');
dvRange = sensorGet(sensorAR, 'maxdigitalvalue') - dvBlvl;
rgbMeanAR = rgbMeanAR / dvRange;
rgbMeanCWFR = rgbMeanCWFR / dvRange;
rgbMeanDayR = rgbMeanDayR / dvRange;
rgbMeanCBR = rgbMeanCBR / dvRange;
%%
patchSize = 4;
% Illuminant A
rgbMeanARsp = reshape(rgbMeanAR, 4, 6, 3);
rgbMeanARsp = imageIncreaseImageRGBSize(rgbMeanARsp, patchSize);
ieNewGraphWin;
imagesc(rgbMeanARsp * 2);
axis off

% Illuminant CWF
rgbMeanCWFRsp = reshape(rgbMeanCWFR, 4, 6, 3);
rgbMeanCWFRsp = imageIncreaseImageRGBSize(rgbMeanCWFRsp, patchSize);
ieNewGraphWin;
imagesc(rgbMeanCWFRsp * 2);
axis off

% Illuminant Day
rgbMeanDayRsp = reshape(rgbMeanDayR, 4, 6, 3);
rgbMeanDayRsp = imageIncreaseImageRGBSize(rgbMeanDayRsp, patchSize);
ieNewGraphWin;
imagesc(rgbMeanDayRsp * 2);
axis off

% Illuminant CB
rgbMeanCBRsp = reshape(rgbMeanCBR, 4, 6, 3);
rgbMeanCBRsp = imageIncreaseImageRGBSize(rgbMeanCBRsp, patchSize);
ieNewGraphWin;
imagesc(rgbMeanCBRsp * 2);
axis off

%%
mccChip = [1 2;3 4];
mccComp = repelem(mccChip, patchSize, patchSize);
mccFull = repmat(repmat(mccComp, 4, 6), [1, 1, 3]);

mccFull(mccFull == 1) = rgbMeanARsp(:) * 2;
mccFull(mccFull == 2) = rgbMeanCWFRsp(:) * 2;
mccFull(mccFull == 3) = rgbMeanDayRsp(:) * 2;
mccFull(mccFull == 4) = rgbMeanCBRsp(:) * 2;
imagesc(mccFull)
