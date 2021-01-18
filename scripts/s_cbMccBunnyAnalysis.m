% s_cbMccBunnyAnalysis
%%
ieInit;

%% PART I: Load real image
%% Load real image
dngName = 'IMG_20210105_162204.dng';
[sensorR, infoR, ipR] = cbDNGRead(dngName, 'demosaic', true);
sensorR = sensorSet(sensorR, 'name', 'Lighting-real');

%% PART II: Load simulation image
%
wave = sensorGet(sensorR, 'wave');
cf = ieReadSpectra('p4aCorrected.mat', wave);

oiName = 'CBLens_MCC_Bunny_HQ.mat';
load(oiName, 'oi');
meanIllu = oiGet(oi, 'mean illuminance');
oi = oiSet(oi, 'mean illuminance', meanIllu * 0.215 * 0.75);
sensorS = sensorR;
sensorS = sensorSet(sensorS, 'color filters', cf);
sensorS = sensorSetSizeToFOV(sensorS, oiGet(oi, 'fov'), oi);
sensorS = sensorCompute(sensorS, oi);
sensorS = sensorSet(sensorS, 'name', 'MCC-Bunny');

% Compute ip
ipS = ipCreate;
ipS = ipSet(ipS, 'render demosaic only', true);
ipS = ipCompute(ipS, sensorS);

%%
ipWindow(ipR); ipWindow(ipS);

%% Sensor plot
hLineS = 1875; hLineR = 1952;
sensorPlot(sensorS, 'dv hline', [1 1875], 'two lines', true);
ylabel('Digital value');
sensorPlot(sensorR, 'dv hline', [1 1952], 'two lines', true);
ylabel('Digital value');

%% Second line
sensorPlot(sensorS, 'dv hline', [1 938], 'two lines', true);
ylabel('Digital value');
sensorPlot(sensorR, 'dv hline', [1 967], 'two lines', true);
ylabel('Digital value');