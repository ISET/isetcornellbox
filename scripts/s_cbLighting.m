% s_mccPosition
%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Create Cornell Box recipe
thisR = cbBoxCreate('surface color', 'white');

%% Adjust the position of the camera

from = thisR.get('from');
newFrom = [0 0.19 -0.381576 - 0.15];% This is the place where we can see more
thisR.set('from', newFrom);
newTo = newFrom + [0 0 1]; % The camera is horizontal
thisR.set('to', newTo);

%% Remove cubes
thisR.set('assets', 'CubeSmall_B', 'chop');
thisR.set('assets', 'CubeLarge_B', 'chop');

%% Add lens
lensfile = 'wide.77deg.4.38mm.json'; % in 
fprintf('Using lens: %s\n',lensfile);
thisR.camera = piCameraCreate('omni','lensFile',lensfile);
thisR.set('aperture diameter', 2.5318);
thisR.set('focus distance', 0.681576);
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
oiName = 'CBLens_Lighting_HQ';
oi = oiSet(oi, 'name', oiName);
oiWindow(oi);
oiSet(oi, 'gamma', 0.5);

% Save oi
% {
oiSavePath = fullfile(cboxRootPath, 'local', 'simulation', 'lighting', strcat(oiName, '.mat'));
save(oiSavePath, 'oi');
%}