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
newFrom = [0 0.125 -0.40];% This is the place where we can see more
thisR.set('from', newFrom);
newTo = newFrom + [0 0 1]; % The camera is horizontal
thisR.set('to', newTo);
%% Specify rendering settings
thisR.set('film resolution',[320 320]);
nRaysPerPixel = 512;
thisR.set('rays per pixel',nRaysPerPixel);
thisR.set('nbounces',5);

%%
% Write and render
piWrite(thisR);
% Render
[scene, result] = piRender(thisR, 'render type', 'radiance', 'scale illuminance', false);
sceneName = 'CBLens_Base';
scene = sceneSet(scene, 'name', sceneName);
sceneWindow(scene);
sceneSet(scene, 'gamma', 0.5);