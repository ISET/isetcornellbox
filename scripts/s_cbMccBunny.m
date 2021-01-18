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
newFrom = [0 0.125 -0.40];% This is the place where we can see more
thisR.set('from', newFrom);
newTo = newFrom + [0 0 1]; % The camera is horizontal
thisR.set('to', newTo);

%% Add MCC
assetTreeName = 'mccCB';
[~, rootST1] = thisR.set('asset', 'root', 'graft with materials', assetTreeName);
thisR.set('asset', rootST1.name, 'world rotate', [0 0 2]);
T1 = thisR.set('asset', rootST1.name, 'world translate', [0.012 0.003 0.125]);

%% Add bunny
assetTreeName = 'bunny';
[~, rootST2] = thisR.set('asset', 'CubeSmall_B', 'graft with materials', assetTreeName);
thisR.set('asset', rootST2.name, 'world translate', [0.01 0.025+0.01 0]);
thisR.set('asset', 'Bunny_O', 'scale', 1.3);
thisR.set('asset', rootST2.name, 'world rotate', [0 -35 0])
bunnyMatName = thisR.get('assets', rootST2.name, 'material name');
wave = 400:10:700;
refl = ieReadSpectra('cboxSurfaces', wave);
wRefl = refl(:, 3);
thisR = cbAssignMaterial(thisR, bunnyMatName, wRefl);
% thisR.assets.show

%% Add lens
lensfile = 'wide.77deg.4.38mm.json'; % in 
fprintf('Using lens: %s\n',lensfile);
thisR.camera = piCameraCreate('omni','lensFile',lensfile);
thisR.set('aperture diameter', 2.5318);
thisR.set('focus distance', 0.5);
thisR.set('film diagonal', 7.04); % mm

%% Specify rendering settings
thisR.set('film resolution',[2048 2048]);
nRaysPerPixel = 2048;
thisR.set('rays per pixel',nRaysPerPixel);
thisR.set('nbounces',5);
% {
% Write and render
piWrite(thisR);
% Render
[oi, result] = piRender(thisR, 'render type', 'radiance', 'scale illuminance', false);
oiName = 'CBLens_MCC_Bunny_HQ';
oi = oiSet(oi, 'name', oiName);
oiWindow(oi);
oiSet(oi, 'gamma', 0.5);

% Save oi
% {
oiSavePath = fullfile(cboxRootPath, 'local', 'simulation', 'complex_scene', strcat(oiName, '.mat'));
save(oiSavePath, 'oi');
%}