% s_slantedEdge

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Create Cornell Box recipe
thisR = cbBoxCreate;

%% Add a distant light in front of 
distlight = piLightCreate('Dist light', 'type', 'distant',...
                    'spectrum spd', 'cbox-lights-1');
thisR.set('light', 'add', distlight);                
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
slantedBar = piAssetLoad(assetTreeName);
piRecipeMerge(thisR, slantedBar.thisR, 'node name', slantedBar.mergeNode);

scale = thisR.get('asset', slantedBar.mergeNode, 'scale');
thisR.set('asset', slantedBar.mergeNode, 'scale', [0.08 0.13 0.01]*1.2);
thisR.set('asset', slantedBar.mergeNode, 'world position', [0 0.15 0.10]);


% Now get a copy of the slanted bar and place it on a different position
[~, slantedBar2] = piObjectInstanceCreate(thisR, slantedBar.mergeNode);

thisR.set('asset', slantedBar2, 'world position', [0.02 0.04 -0.10]);

%% Specify rendering settings
%{
% High resolution setting
thisR.set('film resolution',[4032 3024]);
nRaysPerPixel = 2048;
thisR.set('rays per pixel',nRaysPerPixel);
thisR.set('nbounces', 2);
thisR.set('fov', 77);
thisR.set('film diagonal', 7.056); % mm
%}

% Fast rendering setting
% {
thisR.set('film resolution',[4032 3024]/16);
nRaysPerPixel = 4;
thisR.set('rays per pixel',nRaysPerPixel);
thisR.set('nbounces', 2);
thisR.set('fov', 77);
thisR.set('film diagonal', 7.056); % mm
%}

%% Create lens
% {
lensFile = fullfile(cboxRootPath, 'data', 'lens', 'pixel4a-rearcamera-ellipse-raytransfer.json');
cameraRTF = piCameraCreate('raytransfer','lensfile',lensFile);
thisR.camera = cameraRTF;
%}
%{
lensFile = 'dgauss.22deg.6.0mm_v3.json';
cameraOmni = piCameraCreate('omni', 'lensfile', lensFile);
thisR.camera = cameraRTF;
%}

%% Test section
%{
% Make sure it renders
thisR.set('film distance', filmdistance_mm/1000);
piWrite(thisR);
[oi, result] = piRender(thisR, 'render type', 'radiance', 'scale illuminance', false,...
                            'docker image','vistalab/pbrt-v3-spectral:raytransfer-ellipse');

oiName = sprintf(['CBRTF_slantedEdge_scene-filmdistance' num2str(filmdistance_mm) 'mm']);
% oiName = 'Omni';
oi = oiSet(oi, 'name', oiName);
oiWindow(oi);
oiSet(oi, 'gamma', 0.5);
%}

%% Loop through film distances
% filmdistance = 0.464135918+0.001; % in meters
filmDistOri = 0.464135918 + 0.001; % in meters
filmDistDelta = linspace(0, 0.2, 10); % 0:0.01:0.2;


for ii=2:3%1:numel(filmDistDelta)
    thisFilmDist = filmDistOri + filmDistDelta(ii);
    thisR.set('film distance', thisFilmDist/1000);
    piWrite(thisR);
    [oiTemp, result] = piRender(thisR, 'render type', 'radiance', 'scale illuminance', false,...
                            'docker image','vistalab/pbrt-v3-spectral:raytransfer-ellipse');
    oiName = sprintf(['CBRTF_slantedEdge_filmdist_' num2str(thisFilmDist) 'mm']);
    oiSlantedBar = oiSet(oiTemp, 'name', oiName);
    % {
    oiWindow(oiSlantedBar);
    oiSet(oiSlantedBar, 'gamma', 0.5);
    %}
    %% Save oi
    simPath = fullfile(cboxRootPath, 'local', 'simulation');
    if ~exist(simPath, 'dir')
        mkdir(simPath);
    end
    slantedBarPath = fullfile(simPath, 'slantedBar');
    
    if ~exist(slantedBarPath, 'dir')
        mkdir(slantedBarPath);
    end
    
    savePath = fullfile(slantedBarPath, [oiName, '.mat']);
    save(savePath, 'oiSlantedBar', 'thisFilmDist');
    fprintf('Saved to: %s', savePath);
end




%% Sensor compute part
%{
oi = oiSlantedBar{1};
sensor = cbSensorCreate;
sensor = sensorSetSizeToFOV(sensor, oiGet(oi, 'fov'), oi);
sensor = sensorSet(sensor, 'exp time', 0.00141 * 3*7 * 5);
sensor = sensorCompute(sensor, oi);

ip = cbIpCompute(sensor);

img = ipGet(ip, 'srgb');

ieNewGraphWin; imagesc(img);
%}