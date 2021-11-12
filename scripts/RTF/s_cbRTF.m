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
%% Add lens RTF


cameraRTF = piCameraCreate('raytransfer','lensfile','pixel4a-rearcamera-filmtoscene-raytransfer.json');
cameraRTF = piCameraCreate('raytransfer','lensfile','dgauss.22deg.50.0mm_aperture6.0.json-filmtoscene-raytransfer.json');
%cameraRTF = piCameraCreate('raytransfer','lensfile','pixel4a-rearcamera-filmtoscene-raytransfer-linear.json');

filmdistance_mm=0.464135918+1;
filmdistance_mm=0.464135918+0.005;
filmdistance_mm=37

thisR.camera = cameraRTF;
thisR.set('film diagonal', 7.04); % mm
thisR.set('filmdistance',filmdistance_mm/1000)
%% Specify rendering settings
thisR.set('film resolution',[512 512]);
nRaysPerPixel = 10;
thisR.set('rays per pixel',nRaysPerPixel);
thisR.set('nbounces',5);

%% Set first focus (in the back)
%thisR.set('focus distance', 0.5);

% {
% Write and render
piWrite(thisR);
% Render
[oi, result] = piRender(thisR, 'render type', 'radiance', 'scale illuminance', false,'docker image','vistalab/pbrt-v3-spectral:raytransfer-spectral');
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

%% Manual load
label={};path={}
 label{end+1}='nonlinear';path{end+1}='/home/thomas/Documents/stanford/libraries/pbrt-v3-spectral/scenes/simpleScene/rtfcornell.dat';

 oi = piDat2ISET(path{1}, 'wave', 400:10:700, 'recipe', thisR);
oiWindow(oi)

%%
sensor = cbSensorCreate;
sensor = sensorSetSizeToFOV(sensor, oiGet(oi, 'fov'), oi);
sensor = sensorSet(sensor, 'exp time', 0.00141 * 3*7);
sensor = sensorCompute(sensor, oi);
sensorWindow(sensor);


%%
sensorPlot(sensor, 'dv hline', [1, 1000], 'two lines', true);

%%
ip = cbIpCompute(sensor);
ipWindow(ip);



%save('/scratch/thomas42/cornell-RTF-nonlinear.mat','sensor','oi')