% s_slantedEdge_scene_analysis
%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%% PART I: Load real image
% Middle
dngName = 'IMG_20210105_163525.dng';
[sensorMR, infoMR, ipMR] = cbDNGRead(dngName, 'demosaic', true);

% Left
dngName = 'IMG_20210105_163902.dng';
[sensorLR, infoLR, ipLR] = cbDNGRead(dngName, 'demosaic', true);

% Right
dngName = 'IMG_20210105_164410.dng';
[sensorRR, infoRR, ipRR] = cbDNGRead(dngName, 'demosaic', true);

%{
sensorWindow(sensorMR);
sensorPlot(sensorMR, 'dv hline', [1 hLineR(1)], 'two lines', true);
ylabel('Digital value');
ipWindow(ipR);

sensorPlot(sensorLR, 'dv hline', [1 hLineR(1)], 'two lines', true);
ylabel('Digital value');

sensorPlot(sensorRR, 'dv hline', [1 hLineR(1)], 'two lines', true);
ylabel('Digital value');
%}

% {
ipWindow(ipMR);
ipWindow(ipLR);
ipWindow(ipRR);
%}

%% Middle
load('CBLens_MCC_middle_HQ_scene_correct.mat', 'scene');

sceneMS = sceneSet(scene, 'fov', 77);
sceneMS = sceneSet(sceneMS, 'distance', 0.5);
illu = sceneGet(sceneMS, 'mean luminance');
sceneMS = sceneSet(sceneMS, 'mean luminance',...
        illu / 3.476 / 1.0694 * 3.3061 * 1.4252 * 1.08 * 1.14 * 1.04);
pSize = 1.4e-6;
%%
oiMS = oiCreate;
oiMS = oiSet(oiMS, 'off axis method', 'skip');
oiMS = oiSet(oiMS, 'f number', 5);
oiMS = oiSet(oiMS, 'optics focal length', 0.00438);

%%
sceneMS = sceneAdjustPixelSize(sceneMS, oiMS, pSize);
oiMS = oiCompute(oiMS, sceneMS);
rect = [506 379 4031 3023];
oiCpMS = oiCrop(oiMS, rect);
% oiWindow(oiCp)

%%
fName = 'p4aLensVignette.mat';
load(fName, 'corrMapBNormUpSamp');
oiCpMS.data.photons = oiCpMS.data.photons .* corrMapBNormUpSamp;
%%
sensorMS = sensorMR;
sensorMS = sensorSet(sensorMS, 'prnu sigma', 1.894);
sensorMS = sensorSet(sensorMS, 'dsnu sigma', 6.36e-4);
sensorMS = sensorSetSizeToFOV(sensorMS, oiGet(oiCpMS, 'fov'), oiCpMS);
sensorMS = sensorSet(sensorMS, 'noise flag', 2);

% Load sensor QE
wave = sensorGet(sensorMS, 'wave');
cf = ieReadSpectra('p4aCorrected.mat', wave);
sensorMS = sensorSet(sensorMS, 'color filters', cf);

sensorMS = sensorSet(sensorMS, 'exp time', 0.2);
sensorMS = sensorCompute(sensorMS, oiCpMS);
rectMS = [1820, 1863, 2375 - 1820, 2252 - 1863];
% sensorWindow(sensorMS);
sensorMSCp = sensorCrop(sensorMS, rectMS);
sensorWindow(sensorMSCp);

ieAddObject(sensorMS);
ipMS = ipCreate;
ipMS = ipSet(ipMS, 'render demosaic only', true);
ipMS = ipCompute(ipMS, sensorMS);
ipWindow(ipMS);

%% Scale and align
% Crop image
rectMR = [1808 1793 2321 - 1808 2207 - 1793];
sensorMRCp = sensorCrop(sensorMR, rectMR);
sensorWindow(sensorMRCp);

hLineMS = 311;
msData = sensorPlot(sensorMSCp, 'dv hline', [1 hLineMS], 'two lines', true);
ylabel('Digital value');
hLineMR = [313, 0, 0];
mrData = sensorPlot(sensorMRCp, 'dv hline', [1, hLineMR],'two lines',true);
ylabel('Digital value');

t = 'Middle';
cbPlotSensorData(msData, mrData, t);



%% Left
load('CBLens_MCC_left_HQ_scene_correct.mat', 'scene');

sceneLS = sceneSet(scene, 'fov', 77);
sceneLS = sceneSet(sceneLS, 'distance', 0.5);
illu = sceneGet(sceneLS, 'mean luminance');
sceneLS = sceneSet(sceneLS, 'mean luminance',...
        illu / 3.476 / 1.0694 * 3.3061 * 1.4252 * 1.08 * 1.14 * 1.04 / 1.16);
pSize = 1.4e-6;
%%
oiLS = oiCreate;
oiLS = oiSet(oiLS, 'off axis method', 'skip');
oiLS = oiSet(oiLS, 'f number', 5);
oiLS = oiSet(oiLS, 'optics focal length', 0.00438);

%%
sceneLS = sceneAdjustPixelSize(sceneLS, oiLS, pSize);
oiLS = oiCompute(oiLS, sceneLS);
rect = [506 379 4031 3023];
oiCpLS = oiCrop(oiLS, rect);
% oiWindow(oiCp)

%%
fName = 'p4aLensVignette.mat';
load(fName, 'corrMapBNormUpSamp', 'corrMapBNorm');
oiCpLS.data.photons = oiCpLS.data.photons .* corrMapBNormUpSamp;
%%
sensorLS = sensorLR;
sensorLS = sensorSet(sensorLS, 'prnu sigma', 1.894);
sensorLS = sensorSet(sensorLS, 'dsnu sigma', 6.36e-4);
sensorLS = sensorSetSizeToFOV(sensorLS, oiGet(oiCpLS, 'fov'), oiCpLS);
sensorLS = sensorSet(sensorLS, 'noise flag', 2);

% Load sensor QE
wave = sensorGet(sensorLS, 'wave');
cf = ieReadSpectra('p4aCorrected.mat', wave);
sensorLS = sensorSet(sensorLS, 'color filters', cf);

sensorLS = sensorSet(sensorLS, 'exp time', 0.2);
sensorLS = sensorCompute(sensorLS, oiCpLS);
% sensorWindow(sensorLS);
% [roiLocs,roi] = ieROISelect(sensorLS);
% rectLS = round(roi.Position);
rectLS = [1086 1859 588 414];
% sensorWindow(sensorMS);
sensorLSCp = sensorCrop(sensorLS, rectLS);
sensorWindow(sensorLSCp);

ieAddObject(sensorLS);
ipLS = ipCreate;
ipLS = ipSet(ipLS, 'render demosaic only', true);
ipLS = ipCompute(ipLS, sensorLS);
ipWindow(ipLS);

%%
hLineLS = 325;
lsData = sensorPlot(sensorLSCp, 'dv hline', [1 hLineLS], 'two lines', true);
ylabel('Digital value');

sensorWindow(sensorLR);
% [roiLocs,roi] = ieROISelect(sensorLR);
% rectLR = round(roi.Position);
rectLR = [1045 1783 582 418];
% Crop image
sensorLRCp = sensorCrop(sensorLR, rectLR);
sensorWindow(sensorLRCp);
hLineLR = 327;
lrData = sensorPlot(sensorLRCp, 'dv hline', [1 hLineLR], 'two lines', true);
ylabel('Digital value');

t = 'Left';
cbPlotSensorData(lrData, lsData, t);




%% Right
load('CBLens_MCC_right_HQ_scene_correct.mat', 'scene');

sceneRS = sceneSet(scene, 'fov', 77);
sceneRS = sceneSet(sceneRS, 'distance', 0.5);
illu = sceneGet(sceneRS, 'mean luminance');
sceneRS = sceneSet(sceneRS, 'mean luminance',...
        illu / 3.476 / 1.0694 * 3.3061 * 1.4252 * 1.08 * 1.14 * 1.04);
pSize = 1.4e-6;
%%
oiRS = oiCreate;
oiRS = oiSet(oiRS, 'off axis method', 'skip');
oiRS = oiSet(oiRS, 'f number', 5);
oiRS = oiSet(oiRS, 'optics focal length', 0.00438);

%%
sceneRS = sceneAdjustPixelSize(sceneRS, oiRS, pSize);
oiRS = oiCompute(oiRS, sceneRS);
rect = [506 379 4031 3023];
oiCpRS = oiCrop(oiRS, rect);
% oiWindow(oiCp)

oiCpRS.data.photons = oiCpRS.data.photons .* corrMapBNormUpSamp;
%%
sensorRS = sensorRR;
sensorRS = sensorSetSizeToFOV(sensorRS, oiGet(oiCpRS, 'fov'), oiCpRS);
sensorRS = sensorSet(sensorRS, 'noise flag', 2);
sensorRS = sensorSet(sensorRS, 'prnu sigma', 1.894);
sensorRS = sensorSet(sensorRS, 'dsnu sigma', 6.36e-4);
% Load sensor QE
wave = sensorGet(sensorRS, 'wave');
cf = ieReadSpectra('p4aCorrected.mat', wave);
sensorRS = sensorSet(sensorRS, 'color filters', cf);

sensorRS = sensorSet(sensorRS, 'exp time', 0.2);
sensorRS = sensorCompute(sensorRS, oiCpRS);
% sensorWindow(sensorRS);
ieAddObject(sensorRS);
ipRS = ipCreate;
ipRS = ipSet(ipRS, 'render demosaic only', true);
ipRS = ipCompute(ipRS, sensorRS);
ipWindow(ipRS);

%%
% [roiLocs,roi] = ieROISelect(sensorRS);
% rectRS = round(roi.Position);
rectRS = [2369 1851 596 389];
% sensorWindow(sensorRS);
sensorRSCp = sensorCrop(sensorRS, rectRS);
sensorWindow(sensorRSCp);

hLineRS = 325;
rsData = sensorPlot(sensorRSCp, 'dv hline', [1 hLineRS], 'two lines', true);
ylabel('Digital value');

% sensorWindow(sensorRR);
% [roiLocs,roi] = ieROISelect(sensorRR);
% rectRR = round(roi.Position);
rectRR = [2342 1793 618 412];
% sensorWindow(sensorRS);
sensorRRCp = sensorCrop(sensorRR, rectRR);

sensorWindow(sensorRRCp);

hLineRR = 314;
rrData = sensorPlot(sensorRRCp, 'dv hline', [1 hLineRR], 'two lines', true);
ylabel('Digital value');

t = 'Right';
cbPlotSensorData(rsData, rrData, t);