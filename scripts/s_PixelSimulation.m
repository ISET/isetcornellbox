%% s_PixelSimulation
% Calculate sensor data

%% Initialize ISET
ieInit;

%% In the case of scene
%{
load(sceneSavePath, 'scene');
oi = oiCreate;
oi = oiCompute(oi, scene);
illu = oiGet(oi, 'mean illuminance');
oi = oiSet(oi, 'mean illuminance', 2.5 * 0.9098);
%}
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
sensorPx = sensorCreate('IMX363', [], 'iso speed', 418);
sensorPx = sensorSet(sensorPx, 'exp time', 0.0201); % Exp time from real image
sensorPx = sensorSet(sensorPx, 'name', 'Pixel sensor');
sensorPx = sensorSet(sensorPx, 'read noise electrons', 2);
sensorPx = sensorSet(sensorPx, 'prnu sigma', 0);
sensorPx = sensorSetSizeToFOV(sensorPx, oiGet(oi, 'fov'), oi);
sensorPx = sensorSet(sensorPx, 'color filters', cfPredCons);
%% Calculate sensor data
% sensorPx = sensorSet(sensorPx, 'noise flag', 0);
sensorPx = sensorCompute(sensorPx, oi);
% sensorWindow(sensorPx);

%%
% [~, rectPx] = ieROISelect(sensorPx);
% rectPxPos = round(rectPx.Position);
rectPxPos = [564 395 1393 1326];
sensorPx = sensorCrop(sensorPx, rectPxPos);

%%
sensorPlot(sensorPx, 'dv hline', [1, 1872]);
%% Image processor
ip = ipCreate;
ip = ipSet(ip,'render demosaic only',true);
ip = ipCompute(ip, sensorPx);
ipWindow(ip);
