% s_slantedEdge

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

%% Add slanted edge
assetTreeName = 'slantedbar';
[~, rootST1] = thisR.set('asset', 'root', 'graft with materials', assetTreeName);
% T1 = thisR.set('asset', rootST1.name, 'world translate', [-0.0375 0 0.10]); % 7 cm from left side
T1 = thisR.set('asset', rootST1.name, 'world translate', [0 0 0.10]); 

%{
assetTreeName = 'slantedbar';
[~, rootST2] = thisR.set('asset', 'root', 'graft with materials', assetTreeName);
T2 = thisR.set('asset', rootST2.name, 'world translate', [0.0525 0 -0.10]); % 16 cm from left side
%}

%% Specify rendering settings
thisR.set('film resolution',[2048 2048]);
nRaysPerPixel = 2048;
thisR.set('rays per pixel',nRaysPerPixel);
thisR.set('nbounces',5);

%% Set first focus (in the back)
thisR.set('focus distance', 0.5);
% {
% Write and render
piWrite(thisR);
% Render
[scene, result] = piRender(thisR, 'render type', 'radiance', 'scale illuminance', false);
sceneName = sprintf('CBLens_slantedEdge_scene');
scene = sceneSet(scene, 'name', sceneName);
sceneWindow(scene);
sceneSet(scene, 'gamma', 0.5);
%}
% Save oi
% {
sceneSavePath = fullfile(cboxRootPath, 'local', 'simulation', 'resolution_target', strcat(sceneName, '.mat'));
save(sceneSavePath, 'scene');
%}