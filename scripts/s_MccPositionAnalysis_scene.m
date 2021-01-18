% s_slantedEdge_scene_analysis
%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%%
load('CBLens_MCC_middle_HQ_scene.mat', 'scene');

scene = sceneSet(scene, 'distance', 0.5);
sceneSz = sceneGet(scene, 'size');
pSize = 1.4e-6;
%%
oi = oiCreate;
oi = oiSet(oi, 'off axis method', 'skip');
oi = oiSet(oi, 'f number', 5);
oi = oiSet(oi, 'optics focal length', 0.00438);

%%
scene = sceneAdjustPixelSize(scene, oi, pSize);
oi = oiCompute(oi, scene);
rect = [263, 263, sceneSz(2), 1800];
% rect = [41, 41, sceneSz(1), sceneSz(2)];
oi = oiCrop(oi, rect);
%% Load lens vignetting map
fName = 'p4aLensVignette.mat';
load(fName, 'corrMapBNormUpSamp', 'corrMapBNorm');

% Get oi size
oiSz = oiGet(oi, 'size');
% Resize
corrMapBNormRS = imresize(corrMapBNorm, oiSz);
corrMapBNormRSMap = repmat(corrMapBNormRS, [1, 1, 31]);

tmp = oi.data.photons;
scaledData = oi.data.photons .* corrMapBNormRSMap;
%{
diff = tmp - scaledData;
ieNewGraphWin; imagesc(diff(:,:,1));
%}
oi.data.photons = scaledData;
curIllu = oiGet(oi, 'mean illuminance');
oi = oiSet(oi, 'mean illuminance', curIllu / 10 * 2.55 * 1.3);


%%
sensorM = sensorCreate('IMX363');
sensorM = sensorSetSizeToFOV(sensorM, [oiGet(oi, 'fov'), oiGet(oi, 'fov')], oi);
% sensor = sensorSet(sensor, 'noise flag', 0);
sensorM = sensorSet(sensorM, 'exp time', 0.2);
wave = sensorGet(sensorM, 'wave');
cf = ieReadSpectra('p4aCorrected.mat', wave);
sensorM = sensorSet(sensorM, 'color filters', cf);
sensorM = sensorCompute(sensorM, oi);
%{
% Resize
corrMapBNormRS = imresize(corrMapBNorm, sensorGet(sensor, 'size'));
corrMapBNormRSMap = repmat(corrMapBNormRS, [1, 1, 31]);
sensor.data.volts = sensor.data.volts .* corrMapBNormRS;
sensor.data.dv = sensor.data.dv .* corrMapBNormRS;
%}
sensorWindow(sensorM);
% {
ieAddObject(sensorM);
ip = ipCreate;
ip = ipSet(ip, 'render demosaic only', true);
ip = ipCompute(ip, sensorM);
ipWindow(ip);
%}

%%
[uDataM, gM] = sensorPlot(sensorM, 'dv hline', [1, 2015], 'two lines', true);

%%
load('CBLens_MCC_left_HQ_scene.mat', 'scene');

scene = sceneSet(scene, 'distance', 0.5);
sceneSz = sceneGet(scene, 'size');
pSize = 1.4e-6;
%%
oi = oiCreate;
oi = oiSet(oi, 'off axis method', 'skip');
oi = oiSet(oi, 'f number', 5);
oi = oiSet(oi, 'optics focal length', 0.00438);

%%
scene = sceneAdjustPixelSize(scene, oi, pSize);
oi = oiCompute(oi, scene);
rect = [263, 263, sceneSz(2), 1800];
% rect = [41, 41, sceneSz(1), sceneSz(2)];
oi = oiCrop(oi, rect);
%% Load lens vignetting map
fName = 'p4aLensVignette.mat';
load(fName, 'corrMapBNormUpSamp', 'corrMapBNorm');

% Get oi size
oiSz = oiGet(oi, 'size');
% Resize
corrMapBNormRS = imresize(corrMapBNorm, oiSz);
corrMapBNormRSMap = repmat(corrMapBNormRS, [1, 1, 31]);

tmp = oi.data.photons;
scaledData = oi.data.photons .* corrMapBNormRSMap;
%{
diff = tmp - scaledData;
ieNewGraphWin; imagesc(diff(:,:,1));
%}
oi.data.photons = scaledData;
curIllu = oiGet(oi, 'mean illuminance');
oi = oiSet(oi, 'mean illuminance', curIllu / 10 * 2.55 * 1.3);

%%
sensorL = sensorCreate('IMX363');
sensorL = sensorSetSizeToFOV(sensorL, [oiGet(oi, 'fov'), oiGet(oi, 'fov')], oi);
% sensor = sensorSet(sensor, 'noise flag', 0);
sensorL = sensorSet(sensorL, 'exp time', 0.2);
wave = sensorGet(sensorL, 'wave');
cf = ieReadSpectra('p4aCorrected.mat', wave);
sensorL = sensorSet(sensorL, 'color filters', cf);
sensorL = sensorCompute(sensorL, oi);
%{
% Resize
corrMapBNormRS = imresize(corrMapBNorm, sensorGet(sensor, 'size'));
corrMapBNormRSMap = repmat(corrMapBNormRS, [1, 1, 31]);
sensor.data.volts = sensor.data.volts .* corrMapBNormRS;
sensor.data.dv = sensor.data.dv .* corrMapBNormRS;
%}
sensorWindow(sensorL);
% {
ieAddObject(sensorL);
ip = ipCreate;
ip = ipSet(ip, 'render demosaic only', true);
ip = ipCompute(ip, sensorL);
ipWindow(ip);
%}

%%
[uDataL, gL] = sensorPlot(sensorL, 'dv hline', [1, 2006], 'two lines', true);



%%
load('CBLens_MCC_right_HQ_scene.mat', 'scene');

scene = sceneSet(scene, 'distance', 0.5);
sceneSz = sceneGet(scene, 'size');
pSize = 1.4e-6;
%%
oi = oiCreate;
oi = oiSet(oi, 'off axis method', 'skip');
oi = oiSet(oi, 'f number', 5);
oi = oiSet(oi, 'optics focal length', 0.00438);

%%
scene = sceneAdjustPixelSize(scene, oi, pSize);
oi = oiCompute(oi, scene);
rect = [263, 263, sceneSz(2), 1800];
% rect = [41, 41, sceneSz(1), sceneSz(2)];
oi = oiCrop(oi, rect);
%% Load lens vignetting map
fName = 'p4aLensVignette.mat';
load(fName, 'corrMapBNormUpSamp', 'corrMapBNorm');

% Get oi size
oiSz = oiGet(oi, 'size');
% Resize
corrMapBNormRS = imresize(corrMapBNorm, oiSz);
corrMapBNormRSMap = repmat(corrMapBNormRS, [1, 1, 31]);

tmp = oi.data.photons;
scaledData = oi.data.photons .* corrMapBNormRSMap;
%{
diff = tmp - scaledData;
ieNewGraphWin; imagesc(diff(:,:,1));
%}
oi.data.photons = scaledData;
curIllu = oiGet(oi, 'mean illuminance');
oi = oiSet(oi, 'mean illuminance', curIllu / 10 * 2.55 * 1.3);

%%
sensorR = sensorCreate('IMX363');
sensorR = sensorSetSizeToFOV(sensorR, [oiGet(oi, 'fov'), oiGet(oi, 'fov')], oi);
% sensor = sensorSet(sensor, 'noise flag', 0);
sensorR = sensorSet(sensorR, 'exp time', 0.2);
wave = sensorGet(sensorR, 'wave');
cf = ieReadSpectra('p4aCorrected.mat', wave);
sensorR = sensorSet(sensorR, 'color filters', cf);
sensorR = sensorCompute(sensorR, oi);
%{
% Resize
corrMapBNormRS = imresize(corrMapBNorm, sensorGet(sensor, 'size'));
corrMapBNormRSMap = repmat(corrMapBNormRS, [1, 1, 31]);
sensor.data.volts = sensor.data.volts .* corrMapBNormRS;
sensor.data.dv = sensor.data.dv .* corrMapBNormRS;
%}
sensorWindow(sensorR);
% {
ieAddObject(sensorR);
ip = ipCreate;
ip = ipSet(ip, 'render demosaic only', true);
ip = ipCompute(ip, sensorR);
ipWindow(ip);
%}

%%
[uDataR, gR] = sensorPlot(sensorR, 'dv hline', [1, 2009], 'two lines', true);