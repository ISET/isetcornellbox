% s_slantedEdge

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Create Cornell Box recipe
thisR = cbBoxCreate;

%% Add a distant light in front of 
distlight = piLightCreate('Dist light', 'type', 'distant',...
                    'spectrum spd', 'cbox-lights-1');
% thisR.set('light', 'add', distlight);                
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
thisR.set('asset', slantedBar.mergeNode, 'scale', [0.08 0.1 0.01]);
thisR.set('asset', slantedBar.mergeNode, 'world position', [0 0.05 0.10]);


% Now get a copy of the slanted bar and place it on a different position
[~, slantedBar2] = piObjectInstanceCreate(thisR, slantedBar.mergeNode);

thisR.set('asset', slantedBar2, 'world position', [0.12 0.05 -0.10]);

%% Specify rendering settings
%{
% High resolution setting
thisR.set('film resolution',[4032 3024]);
nRaysPerPixel = 2048;
thisR.set('rays per pixel',nRaysPerPixel);
thisR.set('nbounces', 5);
thisR.set('fov', 50);
thisR.set('film diagonal', 7.056); % mm
%}
% Fast rendering setting
thisR.set('film resolution',[4032 3024]/8);
nRaysPerPixel = 4096;
thisR.set('rays per pixel',nRaysPerPixel);
thisR.set('nbounces', 5);
thisR.set('fov', 77);
thisR.set('film diagonal', 7.056); % mm

%% Create lens
%{
lensFile = fullfile(cboxRootPath, 'data', 'lens', 'pixel4a-rearcamera-ellipse-raytransfer.json');
cameraRTF = piCameraCreate('raytransfer','lensfile',lensFile);
filmdistance_mm=0.464135918+0.001;
thisR.camera = cameraRTF;
%}
lensFile = 'dgauss.22deg.6.0mm_v3.json';
cameraOmni = piCameraCreate('omni', 'lensfile', lensFile);
thisR.camera = cameraRTF;

%% Test section
% Make sure it renders
thisR.set('film distance', filmdistance_mm/1000);
piWrite(thisR);
[oi, result] = piRender(thisR, 'render type', 'radiance', 'scale illuminance', false,...
                            'docker image','vistalab/pbrt-v3-spectral:raytransfer-ellipse');

% oiName = sprintf(['CBRTF_slantedEdge_scene-filmdistance' num2str(filmdistance_mm) 'mm']);
oiName = 'Omni';
oi = oiSet(oi, 'name', oiName);
oiWindow(oi);
oiSet(oi, 'gamma', 0.5);

%%
sensor = cb
%%
%{
%% Loop parameters
filmdistances_delta = flip(linspace(0.03,0.1,10))
%filmdistances_delta = 0.0667  % seemed optimal

%% Render
for i=1:numel(filmdistances_delta)
film_mm=(filmdistance_mm+filmdistances_delta(i))
thisR.set('film distance',film_mm/1000);

% Write and render
piWrite(thisR);
% Render

[oiTemp, result] = piRender(thisR, 'render type', 'radiance', 'scale illuminance', false);
oiName = sprintf(['CBRTF_slantedEdge_scene-filmdistance' num2str(film_mm) 'mm']);
oi{i} = oiSet(oiTemp, 'name', oiName);
oiWindow(oi{i});
oiSet(oi{i}, 'gamma', 0.5);
end
%}
save('/scratch/thomas42/cornellMTF-RTF-linear-fullresolution.mat','oi')

%}
% Save oi
%{
oiSavePath = fullfile(cboxRootPath, 'local', 'simulation', 'resolution_target', strcat(oiName, '.mat'));
save(oiSavePath, 'oi');
%}

%% Load data
% load('/scratch/thomas42/cornellMTF-RTF-linear.mat','oi')  

%% Sensor
positions=  [1633        1546         338         497];

positions=[        1359        1332         330         476]

figure(10);clf
color = hot;
hold on
%for i=6:numel(oi)
    for i=5:8
oiChoice=oi{i};
sensor = cbSensorCreate;
sensor = sensorSetSizeToFOV(sensor, oiGet(oiChoice, 'fov'), oiChoice);
sensor = sensorSet(sensor, 'exp time', 0.00141 * 3*7);
sensor = sensorSet(sensor,'noise flag',-1); warning('Noise Flag OFF')

sensor = sensorCompute(sensor, oiChoice);
ip = cbIpCompute(sensor);
% ipWindow(ip)
%     [locs,rect] = ieROISelect(ip);
%     positions = round(rect.Position);
MTF{i} = ieISO12233(ip,sensor,'none',positions);
figure(10)
hold on
hpbrt=plot(MTF{i}.freq,MTF{i}.mtf(:,1),'color',color(20*i,:))
measured=csvread('mtfzheng_infocus.csv');
hmeas=plot(measured(:,1),measured(:,2)/100,'k.-')
xlim([0 400])
%l(filmdistances_delta(i))
pause(0.1)
    end

legend([hpbrt hmeas],'RTF PBRT','Measured')