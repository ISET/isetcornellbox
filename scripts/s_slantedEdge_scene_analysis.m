% s_slantedEdge_scene_analysis
%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%%
load('CBLens_slantedEdge_scene_correct.mat', 'scene');

scene = sceneSet(scene, 'fov', 77);
scene = sceneSet(scene, 'distance', 0.5);
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
oiWindow(oiCp)

%%
fName = 'p4aLensVignette.mat';
load(fName, 'corrMapBNormUpSamp', 'corrMapBNorm');
oiCp.data.photons = oiCp.data.photons .* corrMapBNormUpSamp;
%%
sensor = sensorCreate('IMX363');
sensor = sensorSetSizeToFOV(sensor, oiGet(oiCp, 'fov'), oiCp);
sensor = sensorSet(sensor, 'noise flag', 0);
sensor = sensorSet(sensor, 'prnu sigma', 1.894);
sensor = sensorSet(sensor, 'dsnu sigma', 6.36e-4);
% Load sensor QE
wave = sensorGet(sensor, 'wave');
cf = ieReadSpectra('p4aCorrected.mat', wave);
sensor = sensorSet(sensor, 'color filters', cf);

sensor = sensorSet(sensor, 'exp time', 0.0141 * 4);
sensor = sensorCompute(sensor, oiCp);
% sensorWindow(sensor);
ieAddObject(sensor);
ip = ipCreate;
ip = ipSet(ip, 'render demosaic only', true);
ip = ipCompute(ip, sensor);
ipWindow(ip);
