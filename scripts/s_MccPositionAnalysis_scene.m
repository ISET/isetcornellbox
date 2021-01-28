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
        illu / 3.476 / 1.0694 * 3.3061 * 1.4252 * 1.08 * 1.14 * 1.04 / 2 / 2.7 / 1.4);
pSize = 1.4e-6;
%%
%{
oiMS = oiCreate;
oiMS = oiSet(oiMS, 'off axis method', 'skip');
oiMS = oiSet(oiMS, 'f number', 5);
oiMS = oiSet(oiMS, 'optics focal length', 0.00438);
%}
%%
%{
% Apply diffuser blur
oi = oiCreate;
oi = oiSet(oi, 'diffuser method', 'blur');
oi = oiSet(oi, 'diffuser blur', [0.95e-6, 0.95e-6]);
oi = oiSet(oi, 'f number', 1.73);
oi = oiSet(oi, 'optics focal length', 0.00438);
%}
% {
wvf1 = wvfCreate;
% f-number
fNumber = 1.73;
fLength = 0.00438;
wvf1 = wvfSet(wvf1,'focal length', fLength);    % Meters
wvf1 = wvfSet(wvf1,'pupil diameter', fLength / fNumber * 1e3);     % Millimeters
% wvf0 = wvfSet(wvf0, 'umperdegree', 78.5285);
% wvf0 = wvfSet(wvf0,'z pupil diameter', fLength / fNumber * 1e3);
wvf1 = wvfSet(wvf1,'zcoeffs', 1.225, 'defocus');
% We need to calculate the pointspread explicitly
wvf1 = wvfComputePSF(wvf1);

% Finally, we convert the wavefront representation to a shift-invariant
% optical image with this routine.

oiMS = wvf2oi(wvf1);
% oiPlot(oi, 'psf 550');
%}
oiMS = oiSet(oiMS, 'off axis method', 'skip');
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
%{
sensorWindow(sensorMSCp);

ieAddObject(sensorMS);
ipMS = ipCreate;
ipMS = ipSet(ipMS, 'render demosaic only', true);
ipMS = ipCompute(ipMS, sensorMS);
ipWindow(ipMS);
%}
%% Scale and align
% Crop image
rectMR = [1808 1793 2321 - 1808 2207 - 1793];
sensorMRCp = sensorCrop(sensorMR, rectMR);
% sensorWindow(sensorMRCp);

hLineMS = 311;
msData = sensorPlot(sensorMSCp, 'dv hline', [1 hLineMS], 'two lines', true);
ylabel('Digital value');
hLineMR = [313, 0, 0];
mrData = sensorPlot(sensorMRCp, 'dv hline', [1, hLineMR],'two lines',true);
ylabel('Digital value');

t = 'Middle';
pattern1 = [2, 3, 1, 2];
pattern2 = [2, 3, 1, 2];
cbPlotSensorData(msData, mrData, t, pattern1, pattern2);
labels = get(legend(), 'String');
plots = flipud(get(gca, 'children'));
neworder = [5 1 7 3 6 2 8 4];
legend(plots(neworder), labels(neworder))
% set(gca,'Children',[h(1), h(5), h(3), h(7), h(2), h(6), h(4), h(8)])


%% Left
load('CBLens_MCC_left_HQ_scene_correct.mat', 'scene');

sceneLS = sceneSet(scene, 'fov', 77);
sceneLS = sceneSet(sceneLS, 'distance', 0.5);
illu = sceneGet(sceneLS, 'mean luminance');
sceneLS = sceneSet(sceneLS, 'mean luminance',...
        illu / 3.476 / 1.0694 * 3.3061 * 1.4252 * 1.08 * 1.14 * 1.04 / 1.16 / 4.48 / 1.4 / 1.2 / 1.15);
pSize = 1.4e-6;
%%
oiLS = oiMS;
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
%{
sensorWindow(sensorLSCp);

ieAddObject(sensorLS);
ipLS = ipCreate;
ipLS = ipSet(ipLS, 'render demosaic only', true);
ipLS = ipCompute(ipLS, sensorLS);
ipWindow(ipLS);
%}
%%
hLineLS = 325;
lsData = sensorPlot(sensorLSCp, 'dv hline', [1 hLineLS], 'two lines', true);
ylabel('Digital value');

% sensorWindow(sensorLR);
% [roiLocs,roi] = ieROISelect(sensorLR);
% rectLR = round(roi.Position);
rectLR = [1045 1783 582 418];
% Crop image
sensorLRCp = sensorCrop(sensorLR, rectLR);
% sensorWindow(sensorLRCp);
hLineLR = 327;
lrData = sensorPlot(sensorLRCp, 'dv hline', [1 hLineLR], 'two lines', true);
ylabel('Digital value');

t = 'Left';
pattern1 = [2, 3, 1, 2];
pattern2 = [2, 3, 1, 2];
cbPlotSensorData(lrData, lsData, t, pattern1, pattern2);
labels = get(legend(), 'String');
plots = flipud(get(gca, 'children'));
neworder = [5 1 7 3 6 2 8 4];
legend(plots(neworder), labels(neworder))
%% Right
load('CBLens_MCC_right_HQ_scene_correct.mat', 'scene');

sceneRS = sceneSet(scene, 'fov', 77);
sceneRS = sceneSet(sceneRS, 'distance', 0.5);
illu = sceneGet(sceneRS, 'mean luminance');
sceneRS = sceneSet(sceneRS, 'mean luminance',...
        illu / 3.476 / 1.0694 * 3.3061 * 1.4252 * 1.08 * 1.14 * 1.04 / 8.83 / 0.8705 / 1.03);
pSize = 1.4e-6;
%%
oiRS = oiMS;

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
%{
% sensorWindow(sensorRS);
ieAddObject(sensorRS);
ipRS = ipCreate;
ipRS = ipSet(ipRS, 'render demosaic only', true);
ipRS = ipCompute(ipRS, sensorRS);
ipWindow(ipRS);
%}
%%
% [roiLocs,roi] = ieROISelect(sensorRS);
% rectRS = round(roi.Position);
rectRS = [2369 1851 596 389];
% sensorWindow(sensorRS);
sensorRSCp = sensorCrop(sensorRS, rectRS);
% sensorWindow(sensorRSCp);

hLineRS = 325;
rsData = sensorPlot(sensorRSCp, 'dv hline', [1 hLineRS], 'two lines', true);
ylabel('Digital value');

% sensorWindow(sensorRR);
% [roiLocs,roi] = ieROISelect(sensorRR);
% rectRR = round(roi.Position);
rectRR = [2342 1793 618 412];
% sensorWindow(sensorRS);
sensorRRCp = sensorCrop(sensorRR, rectRR);

% sensorWindow(sensorRRCp);

hLineRR = 314;
rrData = sensorPlot(sensorRRCp, 'dv hline', [1 hLineRR], 'two lines', true);
ylabel('Digital value');

t = 'Right';
pattern1 = [2, 3, 1, 2];
pattern2 = [1, 2, 2, 3];
cbPlotSensorData(rsData, rrData, t, pattern1, pattern2);
labels = get(legend(), 'String');
plots = flipud(get(gca, 'children'));
neworder = [5 1 7 3 2 6 4 8];
legend(plots(neworder), labels(neworder))