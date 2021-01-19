% s_slantedEdge_scene_analysis
%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%% PART I: Load real image
%% Load real image
dngName = 'IMG_20210105_162204.dng';
[sensorR, infoR, ipR] = cbDNGRead(dngName, 'demosaic', true);
sensorR = sensorSet(sensorR, 'name', 'Lighting-real');

%{
sensorWindow(sensorR);
ipWindow(ipR);
%}

%%
load('CBLens_MCC_Bunny_HQ_scene_correct.mat', 'scene');

scene = sceneSet(scene, 'fov', 77);
scene = sceneSet(scene, 'distance', 0.5);
illu = sceneGet(scene, 'mean luminance');
scene = sceneSet(scene, 'mean luminance', illu / 3.476 / 1.0694 * 3.3061 * 1.4252 * 1.08);
pSize = 1.4e-6;
%%
oi = oiCreate;
oi = oiSet(oi, 'off axis method', 'skip');
oi = oiSet(oi, 'f number', 5);
oi = oiSet(oi, 'optics focal length', 0.00438);

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
% sensorWindow(sensorS);
ieAddObject(sensorS);
ipS = ipCreate;
ipS = ipSet(ipS, 'render demosaic only', true);
ipS = ipCompute(ipS, sensorS);
ipWindow(ipS);

%%
hLineS = 1924;
sData = sensorPlot(sensorS, 'dv hline', [1 hLineS], 'two lines', true);
ylabel('Digital value');

hLineR = 1868;
rData = sensorPlot(sensorR, 'dv hline', [1 hLineR], 'two lines', true);
ylabel('Digital value');

t = 'Complex scene';
[p, estY] = cbPlotSensorData(sData, rData, t);