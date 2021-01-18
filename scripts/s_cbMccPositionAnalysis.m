% s_cbMccPositionAnalysis
%% init
ieInit;

%% PART I: Load real images
% Middle
dngName = 'IMG_20210105_163525.dng';
[sensorMR, infoMR, ipMR] = cbDNGRead(dngName, 'demosaic', true);

% Left
dngName = 'IMG_20210105_163902.dng';
[sensorLR, infoLR, ipLR] = cbDNGRead(dngName, 'demosaic', true);

% Right
dngName = 'IMG_20210105_164410.dng';
[sensorRR, infoRR, ipRR] = cbDNGRead(dngName, 'demosaic', true);

%% PART II: Load simulation image
%
wave = sensorGet(sensorMR, 'wave');
cf = ieReadSpectra('p4aCorrected.mat', wave);

% Middle
oiName = 'CBLens_MCC_middle_HQ.mat';
load(oiName, 'oi');
meanIllu = oiGet(oi, 'mean illuminance');
oi = oiSet(oi, 'mean illuminance', meanIllu / 1000 * 3 * 1.2857 * 1.0778);
sensorMS = sensorMR;
sensorMS = sensorSet(sensorMS, 'color filters', cf);
sensorMS = sensorSetSizeToFOV(sensorMS, oiGet(oi, 'fov'), oi);
sensorMS = sensorCompute(sensorMS, oi);
sensorMS = sensorSet(sensorMS, 'name', 'MCC-Sim-middle');

% Left
oiName = 'CBLens_MCC_left_HQ.mat';
load(oiName, 'oi');
oi = oiSet(oi, 'mean illuminance', meanIllu / 1000 * 3 * 1.1111);
sensorLS = sensorLR;
sensorLS = sensorSet(sensorLS, 'color filters', cf);
sensorLS = sensorSetSizeToFOV(sensorLS, oiGet(oi, 'fov'), oi);
sensorLS = sensorCompute(sensorLS, oi);
sensorLS = sensorSet(sensorLS, 'name', 'MCC-Sim-left');

% Right
oiName = 'CBLens_MCC_right_HQ.mat';
load(oiName, 'oi');
oi = oiSet(oi, 'mean illuminance', meanIllu / 1000 * 3 * 1.2857);
sensorRS = sensorRR;
sensorRS = sensorSet(sensorRS, 'color filters', cf);
sensorRS = sensorSetSizeToFOV(sensorRS, oiGet(oi, 'fov'), oi);
sensorRS = sensorCompute(sensorRS, oi);
sensorRS = sensorSet(sensorRS, 'name', 'MCC-Sim-right');

% Compute ip
ipS = ipCreate;
ipS = ipSet(ipS, 'render demosaic only', true);
ipMS = ipCompute(ipS, sensorMS);
ipLS = ipCompute(ipS, sensorLS);
ipRS = ipCompute(ipS, sensorRS);

%% Sensor analysis
hLineR = [2106, 2106, 2106];
hLineS = [2045, 2045, 2045];
% Middle
sensorPlot(sensorMR, 'dv hline', [1, 2106], 'two line', true); 
title('Real image'); ylabel('Digital value')
sensorPlot(sensorMS, 'dv hline', [1, 2045], 'two line', true); 
title('Simulation image'); ylabel('Digital value')
% Left
sensorPlot(sensorLR, 'dv hline', [1, 2106], 'two line', true); 
title('Real image'); ylabel('Digital value')
sensorPlot(sensorLS, 'dv hline', [1, 2045], 'two line', true); 
title('Simulation image'); ylabel('Digital value')
% Right
sensorPlot(sensorRR, 'dv hline', [1, 2106], 'two line', true); 
title('Real image'); ylabel('Digital value')
sensorPlot(sensorRS, 'dv hline', [1, 2045], 'two line', true); 
title('Simulation image'); ylabel('Digital value')
%%
ipWindow(ipMR); ipWindow(ipMS);
ipWindow(ipLR); ipWindow(ipLS);
ipWindow(ipRR); ipWindow(ipRS);