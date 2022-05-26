% Lens vignetting estimation

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%%
tmp = load('p4aLensVignet_dc_inf_pos1.mat');
% ieNewGraphWin; imagesc(tmp.pixel4aLensVignetSlope);

%%
RIpath = fullfile(cboxRootPath, 'local', 'measurement',...
                        'zemax');
RIName = fullfile(RIpath, 'RI_data.txt');
RI = readmatrix(RIName);
lensVignetZemax = RI(:,1:2);
%%
thisR = piRecipeDefault('scene name', 'flat surface');
thisR.set('lights', 'delete', 'all');
infLight = piLightCreate('inflight', 'type', 'infinite');
thisR.set('light', 'add', infLight);
%{
from = thisR.get('from'); to = thisR.get('to');
shift = [0 -500 0];
from = from + shift;
to = to + shift;
thisR.set('from', from); thisR.set('to', to);
%}
%%
% Fast rendering setting
% {
thisR.set('film resolution',[4032 3024]/16);
nRaysPerPixel = 256;
thisR.set('rays per pixel',nRaysPerPixel);
thisR.set('nbounces', 2);
thisR.set('fov', 83);
thisR.set('film diagonal', 7.056); % mm
%}

%% Create lens
lensFile = fullfile(cboxRootPath, 'data', 'lens', 'pixel4a-rearcamera-ellipse-raytransfer.json');
cameraRTF = piCameraCreate('raytransfer','lensfile',lensFile);
thisR.camera = cameraRTF;

%% Set film distance
filmDistOri = 0.464135918 + 0.001; % in meters
% filmDist = 0.49234;
filmDist = filmDistOri;
thisR.set('film distance', filmDist/1000);

piWrite(thisR);

[oiTemp, result] = piRender(thisR, 'render type', 'radiance', 'scale illuminance', false,...
                    'docker image','vistalab/pbrt-v3-spectral:raytransfer-ellipse');
oiName = sprintf(['CBRTF_flatsurf_filmdist_' num2str(filmDist) 'mm']);
oiFlatSurface = oiSet(oiTemp, 'name', oiName);
oiFlatSurface = oiSet(oiFlatSurface, 'optics offaxismethod',  'skip');
%{
oiWindow(oiFlatSurface);
oiSet(oiFlatSurface, 'gamma', 0.5);
%}
%{
lumap = oiGet(oiFlatSurface, 'illuminance');

lumapUSTest = imresize(lumap, size(tmp.pixel4aLensVignetSlope)/2);

[lensVignetNorm, lensVignet] = cbVignettingFitting(lumapUSTest, 'channel', 'G');

lensVignetFull = imresize(lensVignetNorm, size(tmp.pixel4aLensVignetSlope));
%}

% Save the on-axis lens vignetting
%{
simVignetOnAxis = fullfile(RIpath, 'simCompwithZemax.mat');
save(simVignetOnAxis, 'lensVignetFull');
%}

%{
ieNewGraphWin;
hold all;
plot(tmp.pixel4aLensVignetSlope(end/2,:));
plot(lensVignetFull(end/2,:));
%}

%{
% Optics validation
ieNewGraphWin;
hold all;
temp = lensVignetFull(end/2,:);
plot((1:2016)*1.4/1000, temp(end/2+1:end));
plot(lensVignetZemax(:,1), lensVignetZemax(:,2));
%}


%% Calculate before and after correction
sensorRTF = cbSensorCreate;
sensorRTF = sensorSet(sensorRTF, 'noise flag', -1);
sensorRTF = cbSensorCompute(sensorRTF, oiFlatSurface,...
                            'vignettcorrection', false);
voltsRTF = sensorGet(sensorRTF, 'volts');
%{
tmp = volts(2:2:end, 1:2:end);
tmp = tmp(end/2,:);
ieNewGraphWin; plot(tmp(end/2+1:end)/0.4); hold all;
temp = lensVignetFull(end/2,:);
plot((1:2016), temp(end/2+1:end));
%}
[lensVignetNorm, lensVignet] = cbVignettingFitting(voltsRTF(1:2:end, 1:2:end), 'type', 'sensor');
lensVignetFullRTF = imresize(lensVignetNorm, size(tmp.pixel4aLensVignetSlope));


sensorRTFCorr = cbSensorCompute(sensorRTF, oiFlatSurface,...
                            'vignettcorrection', true);

voltsRTFCorr = sensorGet(sensorRTFCorr, 'volts');
[lensVignetNorm, lensVignet] = cbVignettingFitting(voltsRTFCorr(1:2:end, 2:2:end), 'type', 'sensor');
lensVignetFullRTFCorr = imresize(lensVignetNorm, size(tmp.pixel4aLensVignetSlope));

%%
sz = size(lensVignetFullRTFCorr);
indexX = uint16(1:sz(2)/2);
indexY = uint16(0.75 * indexX);
filmHeight = (single(indexX).^2+single(indexY).^2).^0.5*1.4/1000;
ind = sub2ind(sz, indexY+sz(1)/2-1, indexX+sz(2)/2-1);
%% Compare with Zemax
ieNewGraphWin; hold all;
% Zemax & RTF
% plot(lensVignetZemax(:,1), lensVignetZemax(:,2), 'LineWidth', 8);
plot(filmHeight, lensVignetFullRTF(ind), 'k-', 'LineWidth', 8);
plot(filmHeight, tmp.pixel4aLensVignetSlope(ind), 'LineWidth', 8)
legend('PBRT/Zemax', 'Measured');
grid on; box on; ylim([0 1]); xlim([0 3.5]);
xlabel('Position (mm)'); ylabel('Relative illuminationm');

%{
ieNewGraphWin; hold all;
tmp = lensVignetFullRTF(end/2,:);
plot((1:2016)*1.4/1000, tmp(end/2+1:end));
plot(lensVignetZemax(:,1),lensVignetZemax(:,2));
%}
