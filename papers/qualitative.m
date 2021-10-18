% s_cbMccBunny_scene
% A scene
%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end


%% Basic parameter initialization
from = [0 0.105 -0.40];
to = [0 0.105, 0.6];
resolution = [189 252];
nRaysPerPixel = 128;
nBounces = 5;

%%
measPos1Path = fullfile(cboxRootPath, 'local', 'measurement', 'camerapos', 'pos1');
measPos1ImgPath = fullfile(measPos1Path, 'center', 'IMG_20210105_151748.dng');

[prevImgSimPos1Ctr, prevImgMeasPos1Ctr, oiPos1Ctr, sensorSimPos1Ctr,...
    sensorMeasPos1Ctr] = cbWholePipelineSim('from', from, )
%%

%%
%{
%% Create Cornell Box recipe
thisR = cbBoxCreate;
%{
%% Adjust the position of the camera
% The origin is in the bottom center of the box, the depth of the box is 
% 30 cm, the camera is 25 cm from the front edge. The position of the 
% camera should be set to 25 + 15 = 40 cm from the origin
from = thisR.get('from');
newFrom = [0 0.115 -0.40];% This is the place where we can see more
thisR.set('from', newFrom);
newTo = newFrom + [0 0 1]; % The camera is horizontal
thisR.set('to', newTo);
%}

%% Add MCC
%{
assetTreeName = 'mccCB';
[~, rootST1] = thisR.set('asset', 'root', 'graft with materials', assetTreeName);
thisR.set('asset', rootST1.name, 'world rotate', [0 0 2]);
T1 = thisR.set('asset', rootST1.name, 'world translate', [0.012 0.003 0.125]);
%}
assetTreeNameMCC = 'mccCB';
mccCB = piAssetLoad(assetTreeNameMCC);
piRecipeMerge(thisR, mccCB.thisR, 'node name', mccCB.mergeNode);
thisR.set('asset', 'MCC_B', 'world position', [0 0.035,0.125]);
thisR.set('asset', 'MCC_B', 'world rotation', [0 0 2]);

%{
%% Add bunny
assetTreeNameBunny = 'bunny';

bunnychart = piAssetLoad(assetTreeNameBunny);
% Merge bunny into the cornell box
piRecipeMerge(thisR,bunnychart.thisR,'node name',bunnychart.mergeNode);
bunnyMatName = thisR.get('assets', '001_Bunny_O', 'material name');

wave = 400:10:700;
refl = ieReadSpectra('cboxSurfaces', wave);
wRefl = refl(:, 3);
thisR = cbAssignMaterial(thisR, bunnyMatName, wRefl);

thisR.set('asset', '001_Bunny_O', 'world position', [0 0.005 0]);
thisR.set('asset', '001_Bunny_O', 'scale', 1.3);
% thisR.set('asset', bunnychart.mergeNode, 'world rotate', [0 -35 0]);
% thisR.assets.show
%}
%% Specify rendering settings
thisR.set('film resolution',[256 256]);
nRaysPerPixel = 128;
thisR.set('rays per pixel',nRaysPerPixel);
thisR.set('nbounces',3);
thisR.set('fov', 50);
thisR.set('film diagonal', 7.056);
% {
% Write and render
piWrite(thisR);
% Render
[scene, result] = piRender(thisR, 'render type', 'radiance', 'scale illuminance', false);
sceneName = 'View1';
scene = sceneSet(scene, 'name', sceneName);
sceneWindow(scene);
sceneSet(scene, 'gamma', 0.5);

%% Create OI
oi = oiCreate;
oi = oiSet(oi, 'fov', 77);
oi = oiCompute(oi, scene);
meanIllu = oiGet(oi, 'mean illuminance');
oi = oiSet(oi, 'mean illuminance', meanIllu);
% oiWindow(oi);

%% Create real image and sensor
measPos1Path = fullfile(cboxRootPath, 'local', 'measurement', 'camerapos', 'pos1');
centerImg = fullfile(measPos1Path, 'center', 'IMG_20210105_151748.dng');
[sensorPos1CenterMeas, infoPos1CenterMeas, ipPos1CenterMeas] = cbDNGRead(centerImg, 'demosaic', true);

sensorPos1CenterSim = sensorPos1CenterMeas;
sensorPos1CenterSim = sensorSetSizeToFOV(sensorPos1CenterSim, oiGet(oi, 'fov'), oi);
wave = 390:10:710;
cf = ieReadSpectra('p4aCorrected.mat', wave);
sensorPos1CenterSim = sensorSet(sensorPos1CenterSim, 'color filters', cf);

sensorPos1CenterSim = sensorCompute(sensorPos1CenterSim, oi);
ipPos1CenterSim = ipCreate;
ipPos1CenterSim = ipSet(ipPos1CenterSim, 'render demosaic only', true);
ipPos1CenterSim = ipCompute(ipPos1CenterSim, sensorPos1CenterSim);
% ipWindow(ip);

prevImgSim = ipGet(ipPos1CenterSim, 'srgb');
ieNewGraphWin; imshow(prevImgSim);

prevImgMeas = ipGet(ipPos1Center, 'srgb');
ieNewGraphWin; imshow(prevImgMeas);
%}