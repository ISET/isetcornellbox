% s_mccPosition

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Create Cornell Box recipe
thisR = cbBoxCreate;

%% Adjust the position of the camera
% The origin is in the bottom center of the box, the depth of the box is 
% 30 cm, the camera is 25 cm from the front edge. The position of the 
% camera should be set to 25 + 15 = 40 cm from the origin
from = thisR.get('from');
newFrom = [0 0.115 -0.40];% This is the place where we can see more
thisR.set('from', newFrom);
newTo = newFrom + [0 0 1]; % The camera is horizontal
thisR.set('to', newTo);

%% Remove cubes
thisR.set('assets', 'CubeSmall_B', 'chop');
thisR.set('assets', 'CubeLarge_B', 'chop');

%% Add MCC
assetTreeName = 'mccCB';
[~, rootST1] = thisR.set('asset', 'root', 'graft with materials', assetTreeName);
thisR.set('asset', rootST1.name, 'world rotate', [0 0 2]);
T1 = thisR.set('asset', rootST1.name, 'world translate', [0.012 0.003 0.125]);

%% Specify rendering settings
thisR.set('film resolution',[4032 3024]);
nRaysPerPixel = 2048;
thisR.set('rays per pixel',nRaysPerPixel);
thisR.set('nbounces',5);
thisR.set('fov', 50);
thisR.set('film diagonal', 7.056);
% {
% Write and render
piWrite(thisR);
% Render
[scene, result] = piRender(thisR, 'render type', 'radiance', 'scale illuminance', false);
sceneName = 'CBLens_MCC_middle_HQ_scene_correct';
scene = sceneSet(scene, 'name', sceneName);
sceneWindow(scene);
sceneSet(scene, 'gamma', 0.5);
%}
% Save oi
% {
sceneSavePath = fullfile(cboxRootPath, 'local', 'simulation', 'mcc_pos', strcat(sceneName, '.mat'));
save(sceneSavePath, 'scene');
%}
%% Move MCC to the left
T2 = thisR.set('asset', rootST1.name, 'world translate', [-0.115 0 0]);
% {
% Write and render
piWrite(thisR);
% Render
[scene, result] = piRender(thisR, 'render type', 'radiance', 'scale illuminance', false);
sceneName = 'CBLens_MCC_left_HQ_scene_correct';0dilw
scene = oiSet(scene, 'name', sceneName);
sceneWindow(scene);
sceneSet(scene, 'gamma', 0.5);
%}
% Save oi
% {
sceneSavePath = fullfile(cboxRootPath, 'local', 'simulation', 'mcc_pos', strcat(sceneName, '.mat'));
save(sceneSavePath, 'scene');
%}
%% Move MCC to the right
T3 = thisR.set('asset', rootST1.name, 'world translate', [0.205 0 0]);
% Write and render
piWrite(thisR);
% Render
[scene, result] = piRender(thisR, 'render type', 'radiance', 'scale illuminance', false);
sceneName = 'CBLens_MCC_right_HQ_scene_correct';
scene = sceneSet(scene, 'name', sceneName);
sceneWindow(scene);
sceneSet(scene, 'gamma', 0.5);
% Save oi
% {
sceneSavePath = fullfile(cboxRootPath, 'local', 'simulation', 'mcc_pos', strcat(sceneName, '.mat'));
save(sceneSavePath, 'scene');
%}