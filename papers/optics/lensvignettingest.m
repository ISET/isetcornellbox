% Lens vignetting estimation

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%%
tmp = load('p4aLensVignet.mat');
ieNewGraphWin; imagesc(tmp.pixel4aLensVignetSlope);
%%
thisR = piRecipeDefault('scene name', 'flat surface');
thisR.set('lights', 'delete', 'all');
distLight = piLightCreate('Distlight', 'type', 'distant');
thisR.set('light', 'add', distLight);
%%
% Fast rendering setting
% {
thisR.set('film resolution',[4032 3024]/16);
nRaysPerPixel = 32;
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
filmDist = 0.49234+0.01;
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
lumapUS = imresize(lumap, size(tmp.pixel4aLensVignetSlope));
lumapUSTest = imresize(lumap, size(tmp.pixel4aLensVignetSlope)/2);

[lensVignetNorm, lensVignet] = cbVignettingFitting(lumapUSTest, 'channel', 'G');
lensVignetFull = imresize(lensVignetNorm, size(tmp.pixel4aLensVignetSlope));
ieNewGraphWin; imagesc(lensVignetFull);
ieNewGraphWin; plot(lensVignetFull(end/2,:)); hold all; 
plot(tmp.pixel4aLensVignetSlope(end/2,:))

ieNewGraphWin; 
imagesc(abs(lensVignetFull - tmp.pixel4aLensVignetSlope)./tmp.pixel4aLensVignetSlope)
