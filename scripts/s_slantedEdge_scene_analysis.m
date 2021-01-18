% s_slantedEdge_scene_analysis
%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%%
load('CBLens_slantedEdge_scene.mat', 'scene');

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

%%
sensor = sensorCreate('IMX363');
sensor = sensorSetSizeToFOV(sensor, oiGet(oi, 'fov'), oi);
sensor = sensorSet(sensor, 'noise flag', 0);
sensor = sensorSet(sensor, 'exp time', 0.0141);
sensor = sensorCompute(sensor, oi);
% sensorWindow(sensor);
ieAddObject(sensor);
ip = ipCreate;
ip = ipSet(ip, 'render demosaic only', true);
ip = ipCompute(ip, sensor);
ipWindow(ip);
