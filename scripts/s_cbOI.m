%% s_cbOI
%  Cornell Box simulation

%% Initialize ISET and Docker
% ieInit;
if ~piDockerExists, piDockerConfig; end

%% Create Cornell Box recipe
thisR = cbBoxCreate;

%% Adjust the position of the camera
% The origin is in the bottom center of the box, the depth of the box is 
% 30 cm, the camera is 10 cm from the front edge. The position of the 
% camera should be set to 10 + 15 = 25 cm from the origin
from = thisR.get('from');
newFrom = [-0.01 0.10 -0.25];
thisR.set('from', newFrom);
newTo = newFrom + [0 0 1]; % The camera is horizontal
thisR.set('to', newTo);

%% Set position and rotation of cubes
assetName = 'CubeLarge_B';
thisR.set('asset', assetName, 'world translate', [-0.005 0 -0.03]);
thisR.set('asset', 'CubeLarge_O', 'world rotate', [0 -20 0]);
% thisR.get('asset', 'CubeLarge_O', 'world position')
assetName = 'CubeSmall_O';
T1 = thisR.set('asset', assetName, 'world translate', [0.006 0 -0.01]);
thisR.set('assets', 'CubeSmall_O', 'world rotate', [0 15 0]);

%% Add bunny
assetTreeName = 'bunny';
rootST = thisR.set('asset', T1.name, 'graft with materials', assetTreeName);
thisR.set('asset', rootST.name, 'world translate', [0.008 0.025+0.005 0]);
thisR.set('asset', 'Bunny_O', 'scale', 1.3);
thisR.set('asset', rootST.name, 'world rotate', [0 85 0])
bunnyMatName = thisR.get('assets', rootST.name, 'material name');
thisR = cbAssignMaterial(thisR, bunnyMatName, wRefl);
% thisR.assets.show

%% Add Slanted bar
%{
assetTreeName = 'slantedbar';
rootST3 = thisR.set('asset', 'root', 'graft with materials', assetTreeName);
T1 = thisR.set('asset', rootST3.name, 'world translate', [0 0 0.1]);
% thisR.assets.show
%}
%% Add MCC
assetTreeName = 'mccCB';
rootST4 = thisR.set('asset', 'root', 'graft with materials', assetTreeName);
thisR.set('asset', rootST4.name, 'world rotate', [0 0 2]);
T2 = thisR.set('asset', rootST4.name, 'world translate', [0.01 0.002 0.1]);

% thisR.assets.show
%% In the case of using pinhole
%{
% Do a quick rendering to get the scaling factor
thisR.set('film resolution',[320 320]);
nRaysPerPixel = 32;
thisR.set('rays per pixel',nRaysPerPixel);
thisR.set('nbounces',5); 
thisR.set('fov', 77);
% Write and render
piWrite(thisR);

[scene, result] = piRender(thisR, 'render type', 'radiance', 'scale illuminance', false);
sceneName = 'CBPinhole';
scene = sceneSet(scene, 'name', sceneName);
sceneWindow(scene);
sceneSet(scene, 'gamma', 0.5);
%}
%% In the case of using lens
% {
%% Specify new rendering setting
thisR.set('film resolution',[320 320]);
nRaysPerPixel = 32;
thisR.set('rays per pixel',nRaysPerPixel);
thisR.set('nbounces',5); 
%% Build a lens
% lensfile = 'reversed.telephoto.77deg.3.5201mm.json';
lensfile  = 'dgauss.77deg.3.5201mm.json';  
fprintf('Using lens: %s\n',lensfile);
thisR.camera = piCameraCreate('omni','lensFile',lensfile);
thisR.set('aperture diameter', 2.5);
thisR.set('film diagonal',7); % mm
%% Write and render
piWrite(thisR);
% Render 
[oi, result] = piRender(thisR, 'render type', 'radiance', 'scale illuminance', false);
oiName = 'CBLens_MCC_Bunny_LQ';
oi = oiSet(oi, 'name', oiName);
oiWindow(oi);
oiSet(oi, 'gamma', 0.5);
%}
%% Save oi
%{
oiSavePath = fullfile(cboxRootPath, 'local', strcat(oiName, '.mat'));
save(oiSavePath, 'oi');
%}