%% Init
ieInit;
if ~piDockerExists, piDockerConfig; end

%%

% fname = 'Cornell_Box_EI.pbrt';
% fname = 'cornell_box_formal.pbrt';
fname = 'Cornell_Box_EI_2.pbrt';
thisR = piRead(which(fname));

%%
thisR.lights
%% Set up the render quality

thisR.set('film resolution',[512 512]);
thisR.set('rays per pixel',512);
thisR.set('n bounces',5); % Number of bounces

%%
lensName = 'wide.56deg.50.0mm.dat';
thisR.camera = piCameraCreate('realistic', 'lensfile', lensName);
% thisR.camera.aperturediameter.value = 5;
% thisR.camera.focusdistance.value = 10;

%% Check the material list
piMaterialList(thisR);

%% Modify the left (red) wall, right (green) wall and other side (white)
wave = 400:10:700;
reflectance = ieReadSpectra('cboxWalls', wave);
%{
ieNewGraphWin;
plot(wave, reflectance);
%}

refRedWall = reflectance(:,1);
refGreenWall = reflectance(:,2);
refWhiteWall = reflectance(:,3);

refRedWallFormat = zeros(1, 2 * numel(refRedWall));
refGreenWallFormat = zeros(1, 2 * numel(refGreenWall));
refWhiteWallFormat = zeros(1, 2 * numel(refWhiteWall));

for ii = 1:numel(refRedWall)
    % Red
    refRedWallFormat(1, ii * 2 - 1) = wave(ii);
    refRedWallFormat(1, ii * 2) = refRedWall(ii);
    % Green
    refGreenWallFormat(1, ii * 2 - 1) = wave(ii);
    refGreenWallFormat(1, ii * 2) = refGreenWall(ii);    
    % White
    refWhiteWallFormat(1, ii * 2 - 1) = wave(ii);
    refWhiteWallFormat(1, ii * 2) = refWhiteWall(ii);      
end

redWallIdx = piMaterialFind(thisR, 'name', 'Left Wall');
greenWallIdx = piMaterialFind(thisR, 'name', 'Right Wall');
whiteWallIdx = piMaterialFind(thisR, 'name', 'Other Walls');

% Set reflectance
piMaterialSet(thisR, redWallIdx, 'spectrumkd', refRedWallFormat);
piMaterialSet(thisR, greenWallIdx, 'spectrumkd', refGreenWallFormat);
piMaterialSet(thisR, whiteWallIdx, 'spectrumkd', refWhiteWallFormat);

%% Manage light
piLightSet(thisR, 1, 'lightspectrum', 'cboxIlluminant');
piLightSet(thisR, 1, 'spectrumscale', 1);

%%
piWrite(thisR);

%% Render
thisDocker = 'vistalab/pbrt-v3-spectral:latest';
[oi, result] = piRender(thisR, 'dockerimagename',...
            thisDocker,'wave', wave, 'render type', 'radiance',...
                        'scaleIlluminance', false);
% sceneWindow(oi);
oiWindow(oi);

oi = oiSet(oi, 'fov', 4);
%%
oiSavePath = fullfile(piRootPath, 'local', 'Cornell_Box_EI_2',...
                'renderings', 'Cornell_Box_EI.mat');
save(oiSavePath, 'oi');

%%
load(oiSavePath);
%%
rect_brighter = [244 14 10 10];
rect_darker = [129 410 10 10];
wave = 400:10:700;
irr_brighter = Quanta2Energy(wave, oiGet(oi, 'roi mean photons', rect_brighter));
irr_darker = Quanta2Energy(wave, oiGet(oi, 'roi mean photons', rect_darker));


ieNewGraphWin;
hold all
plot(400:10:700, irr_brighter,'r');
plot(400:10:700, irr_darker, 'b');
xlabel('Wavelength (nm)');
ylabel('Irradiance (Watts/nm/m^2)');
box on;
grid on;

%% sensor
sensor = sensorIMX363;
sensor = sensorSetSizeToFOV(sensor, oiGet(oi, 'fov') * 1.5, oi);
sensor = sensorSet(sensor, 'size', [2600, 2600]);
sensor = sensorSet(sensor, 'auto exp', 0);
sensor = sensorSet(sensor, 'exp time', 5e-5);

sensor = sensorCompute(sensor, oi);

% sensorWindow(sensor);

%%
volts = sensorPlot(sensor, 'volts hline', [1, 2101]);
l = line([1,2600], [2101, 2101]);
l.LineWidth = 3;

%% ip
ipSim = ipCreate;
ipSim = ipSet(ipSim, 'render demosaic only', true);
ipSim = ipCompute(ipSim, sensor);
ipWindow(ipSim);