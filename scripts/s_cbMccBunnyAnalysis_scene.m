% s_slantedEdge_scene_analysis
%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%% PART I: Load real image
%% Load real image
dngName = 'IMG_20210105_162204.dng';
[sensorR, infoR, ipR] = cbDNGRead(dngName, 'demosaic', true);
sensorR = sensorSet(sensorR, 'name', 'Lighting-real');

%% Select a region (real image)
%{
sensorWindow(sensorR);
[~, roiR] = ieROISelect(sensorR);
roiRInt = round(roiR.Position);
%}
roiRInt = [678 1224 272 272];
sensorR = sensorSet(sensorR, 'roi', roiRInt);
sensorStats(sensorR, 'basic', 'dv');
%%
ipWindow(ipR);
%% PART II: 
%%
load('CBLens_MCC_Bunny_HQ_scene_correct.mat', 'scene');

scene = sceneSet(scene, 'fov', 77);
scene = sceneSet(scene, 'distance', 0.5);
illu = sceneGet(scene, 'mean luminance');
scene = sceneSet(scene, 'mean luminance', illu / 3.476 / 1.0694 * 3.3061 * 1.4252 * 1.08 / 8);
pSize = 1.4e-6;
%%
%{
oi = oiCreate;
oi = oiSet(oi, 'off axis method', 'skip');
oi = oiSet(oi, 'f number', 5);
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

oi = wvf2oi(wvf1);
% oiPlot(oi, 'psf 550');
%}
oi = oiSet(oi, 'off axis method', 'skip');

%%
scene = sceneAdjustPixelSize(scene, oi, pSize);
oi = oiCompute(oi, scene);
rect = [506 379 4031 3023];
oiCp = oiCrop(oi, rect);
% oiWindow(oiCp)

%%
fName = 'p4aLensVignette.mat';
load(fName, 'corrMapBNormUpSamp', 'corrMapBNorm');
oiCp.data.photons = oiCp.data.photons .* corrMapBNormUpSamp;
%%
sensorS = sensorR;
sensorS = sensorSetSizeToFOV(sensorS, oiGet(oiCp, 'fov'), oiCp);
sensorS = sensorSet(sensorS, 'noise flag', 2);
sensorS = sensorSet(sensorS, 'prnu sigma', 1.894);
sensorS = sensorSet(sensorS, 'dsnu sigma', 6.36e-4);
% Load sensor QE
wave = sensorGet(sensorS, 'wave');
cf = ieReadSpectra('p4aCorrected.mat', wave);
sensorS = sensorSet(sensorS, 'color filters', cf);

sensorS = sensorSet(sensorS, 'exp time', 0.2);
sensorS = sensorCompute(sensorS, oiCp);
%{
% sensorWindow(sensorS);
ieAddObject(sensorS);
ipS = ipCreate;
ipS = ipSet(ipS, 'render demosaic only', true);
ipS = ipCompute(ipS, sensorS);
ipWindow(ipS);
%}
%%
hLineS = 1924;
sData = sensorPlot(sensorS, 'dv hline', [1 hLineS], 'two lines', true);
ylabel('Digital value');

hLineR = 1868;
rData = sensorPlot(sensorR, 'dv hline', [1 hLineR], 'two lines', true);
ylabel('Digital value');

%{
t = 'Complex scene';
pattern1 = [2, 3, 1, 2];
pattern2 = [2, 3, 1, 2];
[p, estY] = cbPlotSensorData(sData, rData, t);
labels = get(legend(), 'String');
plots = flipud(get(gca, 'children'));
neworder = [5 1 7 3 6 2 8 4];
legend(plots(neworder), labels(neworder))
%}

%% Select a region (simulation)
%{
sensorWindow(sensorS);
[~, roiS] = ieROISelect(sensorS);
roiSInt = round(roiS.Position);
%}
roiSInt = [678 1224 272 272];
sensorS = sensorSet(sensorS, 'roi', roiSInt);
sensorStats(sensorS, 'basic', 'dv');