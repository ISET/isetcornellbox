% Lens vignetting estimation

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%%
tmp = load('p4aLensVignet_dc_p55_pos1.mat');
ieNewGraphWin; imagesc(tmp.pixel4aLensVignetSlope);

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
thisR.set('fov', 77);
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
%{
oiWindow(oiFlatSurface);
oiSet(oiFlatSurface, 'gamma', 0.5);
%}
lumap = oiGet(oiFlatSurface, 'illuminance');

lumapUSTest = imresize(lumap, size(tmp.pixel4aLensVignetSlope)/2);

[lensVignetNorm, lensVignet] = cbVignettingFitting(lumapUSTest, 'channel', 'G');

lensVignetFull = imresize(lensVignetNorm, size(tmp.pixel4aLensVignetSlope));

% Save the on-axis lens vignetting
%{
simVignetOnAxis = fullfile(RIpath, 'simCompwithZemax.mat');
save(simVignetOnAxis, 'lensVignetFull');
%}

%%
sz = size(lensVignetFull);
indexX = 0:sz(2)/2*1.25;
indexY = uint16(0.75 * indexX);
filmHeight = [0:1.4:1.4*sz(2)/2 * 1.25]/1000;
%% Compare with Zemax
ieNewGraphWin; hold all;
plot(filmHeight, lensVignetFull(end/2,end/2:end));
plot(lensVignetZemax(:,1), lensVignetZemax(:,2));
%% Analysis
% ieNewGraphWin; imagesc(lensVignetFull);
delta = -1/6;
lensVignetFullPlus = lensVignetFull + delta;
lensVignetFullPlus = lensVignetFullPlus/max(lensVignetFullPlus(:));
ieNewGraphWin; plot(lensVignetFullPlus(end/2,:)); hold all; 
plot(tmp.pixel4aLensVignetSlope(end/2,:)); legend('RTF', 'Meas')

relError = abs(lensVignetFullPlus - tmp.pixel4aLensVignetSlope)./tmp.pixel4aLensVignetSlope*100;
ieNewGraphWin; 
imagesc(relError);
axis off; colormap('gray'); c = colorbar; c.Ruler.TickLabelFormat='%g%%';
caxis([0 10])

numel(relError(relError<=10)) / numel(relError)
