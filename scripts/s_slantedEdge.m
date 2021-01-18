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
newFrom = [0 0.125 -0.40];% This is the place where we can see more
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
%% Add lens
% lensfile = 'wide.77deg.4.38mm.json'; % in 
% lensfile = 'mobile.76deg.4.4mm.json'; % in 
% lensfile = 'dogmar.77deg.4.38mm.json';
lensfile = 'tessar.test.77deg.4.38mm.json';
lensType = 'tessar';
fprintf('Using lens: %s\n',lensfile);
thisR.camera = piCameraCreate('omni','lensFile',lensfile);
thisR.set('aperture diameter', 2.5318);
thisR.set('film diagonal', 7.04); % mm

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
[oi, result] = piRender(thisR, 'render type', 'radiance', 'scale illuminance', false);
oiName = sprintf('CBLens_Focus_50cm_HQ_%s_on_axis', lensType);
oi = oiSet(oi, 'name', oiName);
oiWindow(oi);
oiSet(oi, 'gamma', 0.5);
%}
% Save oi
% {
oiSavePath = fullfile(cboxRootPath, 'local', 'simulation', 'resolution_target', strcat(oiName, '.mat'));
save(oiSavePath, 'oi');
%}
%% Set second focus (in the front)
thisR.set('focus distance', 0.3);
% {
% Write and render
piWrite(thisR);
% Render
[oi, result] = piRender(thisR, 'render type', 'radiance', 'scale illuminance', false);
oiName = sprintf('CBLens_Focus_30cm_HQ_%s', lensType);
oi = oiSet(oi, 'name', oiName);
oiWindow(oi);
oiSet(oi, 'gamma', 0.5);
%}
% Save oi
% {
oiSavePath = fullfile(cboxRootPath, 'local', 'simulation', 'resolution_target', strcat(oiName, '.mat'));
save(oiSavePath, 'oi');
%}
%% Set third focus at a different distance
T3 = thisR.set('asset', rootST2.name, 'world translate', [0 0 0.05]);
thisR.set('focus distance', 0.35);
% {
% Write and render
piWrite(thisR);
% Render
[oi, result] = piRender(thisR, 'render type', 'radiance', 'scale illuminance', false);
oiName = sprintf('CBLens_Focus_35cm_HQ_%s', lensType);
oi = oiSet(oi, 'name', oiName);
oiWindow(oi);
oiSet(oi, 'gamma', 0.5);
%}
% Save oi
% {
oiSavePath = fullfile(cboxRootPath, 'local', 'simulation', 'resolution_target', strcat(oiName, '.mat'));
save(oiSavePath, 'oi');
%}