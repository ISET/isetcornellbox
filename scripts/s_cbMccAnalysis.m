%% Initialize ISET
ieInit;

%% Part I: Real image
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

%% Part II: Simulation
%% Load optical image data
% {
oiName = 'CBLens_MCC_Bunny_HQ';
oiPath = fullfile(cboxRootPath, 'local', strcat(oiName, '.mat'));
load(oiPath, 'oi');

%{
    oiWindow(oi);
    oiSet(oi, 'gamma', 0.5);
%}
illuMap = oiGet(oi, 'illuminance');
illuSort = sort(illuMap(:), 'descend');
% Take the mean of first 50 illuminance
meanMaxIllu = mean(illuSort(1:50));
illu = oiGet(oi, 'max illuminance');
oi = oiSet(oi, 'max illuminance', illu*3);
%}
%% Create IMX363 sensor
sensorS = sensorCreate('IMX363', [], 'iso speed', 418);
sensorS = sensorSet(sensorS, 'exp time', 0.0201); % Exp time from real image
sensorS = sensorSet(sensorS, 'name', 'Pixel sensor');
sensorS = sensorSet(sensorS, 'noise flag', 0);
sensorS = sensorSetSizeToFOV(sensorS, oiGet(oi, 'fov'), oi);
sensorS = sensorSet(sensorS, 'color filters', cfPredCons);

%% Compute sensor data

sensorS = sensorCompute(sensorS, oi);
rectS = [1100 1280 330 220];
sensorS = sensorCrop(sensorS, rectS);
% cpS = chartCornerpoints(sensorS);
cpS = [15 210; 316 209; 317 10; 14 11];
[rgbMeanCBS, roisS] = cbMccRGBMean(sensorS, cpS, true);

%{
sensorWindow(sensorS);
chartRectsDraw(sensorS,roisS);  % Visualize the rectangles
%}


%%
% Calculate scale factor due to illumination difference
illuSF = rgbMeanCBS(:) \ rgbMeanCBR(:);
rgbMeanSScaled = rgbMeanCBS * illuSF;
cbMccPredEval('prediction', rgbMeanSScaled ,...
              'measurement', rgbMeanCBR);

% Calculate relative mean absolute error
mean(abs(rgbMeanSScaled(:) - rgbMeanCBR(:)) ./ rgbMeanCBR(:)) * 100


%%
% Greytag booth
% MCC analysis for color filter
% Analysis on lamp illumination
% 
% Show rgb values in cb is different from greytag lights
% Compare the rgb value w/ red and green wall and w/ white surface (for
% indirect light), and cubes