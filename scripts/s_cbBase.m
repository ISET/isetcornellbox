% s_cbBase
% This is an example of how to build a cornell box recipe and add lens.
% The core function is cbBoxCreate, which set up the box, area light on top
% and two cubes.

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

%{
% Render the scene without lens
piWRS(thisR);
%}
%% Add lens
lensfile = 'wide.77deg.4.38mm.json'; % in 
fprintf('Using lens: %s\n',lensfile);
thisR.camera = piCameraCreate('omni','lensFile',lensfile);
thisR.set('aperture diameter', 2.5318);
thisR.set('film diagonal', 7.04); % mm

%% Specify rendering settings
thisR.set('film resolution',[512 512]);
nRaysPerPixel = 512;
thisR.set('rays per pixel',nRaysPerPixel);
thisR.set('nbounces',5);

%% Set first focus (in the back)
thisR.set('focus distance', 0.5);

% {
% Write and render
piWrite(thisR);
% Render
[oi, result] = piRender(thisR, 'render type', 'radiance', 'scale illuminance', false);
oiName = 'CBLens_Base';
oi = oiSet(oi, 'name', oiName);
oiWindow(oi);
oiSet(oi, 'gamma', 0.5);
%}
% Save oi
%{
oiSavePath = fullfile(cboxRootPath, 'local', 'simulation', 'pipeline', strcat(oiName, '.mat'));
save(oiSavePath, 'oi');
%}

%%
% sensor = sensorCreate('IMX363');
sensor = cbSensorCreate;
sensor = sensorSetSizeToFOV(sensor, oiGet(oi, 'fov'), oi);
sensor = sensorSet(sensor, 'exp time', 0.00141 * 3);
sensor = sensorCompute(sensor, oi);
sensorWindow(sensor);

%%
sensorPlot(sensor, 'dv hline', [1, 1000], 'two lines', true);