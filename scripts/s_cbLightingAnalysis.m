% s_cbLightingAnalysis

%%
ieInit;

%% PART I: Load real image
%% Load real image
dngName = 'IMG_20201028_160121_3.dng';
% Crop rectangle of sensor image
crop = [701 305 2500 2500];
[sensorR, infoR, ipR] = cbDNGRead(dngName, 'crop', crop, 'demosaic', true);
sensorR = sensorSet(sensorR, 'name', 'Lighting-real');
% sensorWindow(sensorR);
ipWindow(ipR)
%% PART II: Load simulation image
oiName = 'CBLens_Lighting_HQ.mat';
load(oiName, 'oi');
oi = oiCrop(oi, [286 479 1500 1500]);
meanIllu = oiGet(oi, 'mean illuminance');
oi = oiSet(oi, 'mean illuminance', meanIllu/2.5 * 1.2989 * 1.1667 * 1.11);
%{
oiWindow(oi);
oiSet(oi, 'gamma', 0.5);
%}
% Copy the settings from real DNG file
sensorS = sensorR;
% Apply corrected color filter
wave = sensorGet(sensorS, 'wave');
cf = ieReadSpectra('p4aCorrected.mat', wave);
sensorS = sensorSet(sensorS, 'color filters', cf);
sensorS = sensorSet(sensorS, 'noise flag', 2);
sensorS = sensorSetSizeToFOV(sensorS, oiGet(oi, 'fov'), oi);
sensorS = sensorCompute(sensorS, oi);
sensorS = sensorSet(sensorS, 'name', 'Lighting-simulation');
% sensorWindow(sensorS);
% Compute ip
ipS = ipCreate;
ipS = ipSet(ipS, 'render demosaic only', true);
ipS = ipCompute(ipS, sensorS);
ipWindow(ipS);
ipWindow(ipR);
%% Analysis
% Draw a line across real and simulation image
hLineS = 1040; hLineR = 1117;
sensorPlot(sensorS, 'dv hline', [1, 1040], 'two lines', true);
sensorPlot(sensorR, 'dv hline', [1, 1117], 'two lines', true);

%% Generate spatial lighting distribution map
dvR = sensorGet(sensorR, 'dv');
dvRedR = dvR(1:2:end, 1:2:end);
dvS = sensorGet(sensorS, 'dv');
dvRedS = dvS(1:2:end, 1:2:end);

ieNewGraphWin; imagesc(dvRedR); title('Real lighting')
ieNewGraphWin; imagesc(dvRedS); title('Simulation lighting');