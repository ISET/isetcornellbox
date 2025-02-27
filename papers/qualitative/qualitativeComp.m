% s_cbMccBunny_scene
% A scene
%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%%
% tmp = load('p4aLensVignet.mat', 'pixel4aLensVignetSlope');
% vignetting = tmp.pixel4aLensVignetSlope;
%% Basic parameter initialization

resolution = [252 189]*16;
nRaysPerPixel = 512*6; % 2048;
nBounces = 6;
measPos1Path = fullfile(cboxRootPath, 'local', 'measurement', 'camerapos');

%% Center

from = [0 0.10 -0.39];
to = [0 0.125, 0.6];
                                  
measCenerImgPath = fullfile(measPos1Path, 'center', 'selected', 'IMG_20210130_111914.dng');
[sensor, info, ipMeasCenter] = cbDNGRead(measCenerImgPath, 'demosaic', true);
%{
ipWindow(ipMeasCenter);
imgMeasCenter = ipGet(ipMeasCenter, 'srgb');
ieNewGraphWin; imagesc(imgMeasCenter);
%}
label = 'Center';

oiCtr = cbOISim('from', from,...
                'to', to,...
                'resolution', resolution,...
                'n rays per pixel', nRaysPerPixel,... 
                'nbounces', nBounces,...
                'label', label,...
                'filmdistance', 0.49234);
% oiWindow(oiCtr); oiSet(oiCtr, 'gamma', 0.5);

[prevImgSimCtr, prevImgMeasCtr, sensorSimCtr,...
    sensorMeasCtr, ~, ipSimCtr, ipMeasCtr] = cbSensorSim(oiCtr, 'meas img path', measCenerImgPath,...
                                                'illuscale', 0.57,...
                                                'noise flag', 2,...
                                                'vignetting', []);
%{
  sensorWindow(sensorSimCtr);
  sensorWindow(sensorMeasCtr);
%}
% ipWindow(ipSimCtr); ipWindow(ipMeasCtr);                                            
ieNewGraphWin; 
subplot(1, 2, 1); imshow(prevImgSimCtr);
subplot(1, 2, 2); imshow(prevImgMeasCtr);
%{
imgCtr = imread('simCtr.png');
subplot(1, 3, 3); imshow(imgCtr);
%}
%{
% Red color patch:
redM = [244, 140, 83.4];
redS = [202, 136, 80.7];
ieNewGraphWin; hold all;
plot(redM(1), redS(1), 'ro');
plot(redM(2), redS(2), 'go');
plot(redM(3), redS(3), 'bo');
xlim([0 1000]); ylim([0 1000]);
axis square; box on; grid on; identityLine;
xlabel('Measurement'); ylabel('Simulation');
%}
%{
cornerSim = [1832 1832 2330 2187];
[~, ~, rgbMeanSim, ~] = cbMccChipsDV(sensorSimCtr, 'corner point', cornerSim);

cornerMeas = [1876 1827 2350 2154];
[~, ~, rgbMeanMeas, ~] = cbMccChipsDV(sensorMeasCtr, 'corner point', cornerMeas);

sc = sum(rgbMeanMeas(:))/sum(rgbMeanSim(:));
rgbMeanMeasS = rgbMeanMeas/sc;
ieNewGraphWin;
hold all
plot(rgbMeanMeasS(:,1), rgbMeanSim(:,1), 'ro'); 
plot(rgbMeanMeasS(:,2), rgbMeanSim(:,2), 'go'); 
plot(rgbMeanMeasS(:,3), rgbMeanSim(:,3), 'bo'); 
axis square; identityLine;
xlabel('Measurement'); ylabel('Simulation');
%}
% Save
qualSaveDirPath = fullfile(cboxRootPath, 'local', 'figures', 'qualitative');
noiseSaveDirPath = fullfile(cboxRootPath, 'local', 'figures', 'qualitative');
if ~exist(qualSaveDirPath, 'dir')
    mkdir(qualSaveDirPath);
end

if ~exist(noiseSaveDirPath, 'dir')
    mkdir(noiseSaveDirPath);
end
simCtrName = 'simCtr.png';
measCtrName = 'measCtr.png';
imwrite(prevImgSimCtr, fullfile(qualSaveDirPath, simCtrName));
imwrite(prevImgMeasCtr, fullfile(qualSaveDirPath, measCtrName));

oiCtrName = 'oiCtr.mat';
sensorSimCtrName = 'sensorSimCtr.mat';
sensorMeasCtrName = 'sensorMeasCtr.mat';
save(fullfile(qualSaveDirPath, oiCtrName), 'oiCtr');
save(fullfile(noiseSaveDirPath, sensorSimCtrName), 'sensorSimCtr');
save(fullfile(noiseSaveDirPath, sensorMeasCtrName), 'sensorMeasCtr');

%% left
%{
resolution = [252 189] * 4;
nRaysPerPixel = 64;
nBounces = 6;
%}
from = [-0.115 0.105 -0.405];
to = [0.135 0.115, 0.6];

measLeftImgPath = fullfile(measPos1Path, 'left', 'selected', 'IMG_20210130_114111.dng');
label = 'Left';

oiLeft = cbOISim('from', from,...
                'to', to,...
                'resolution', resolution,...
                'n rays per pixel', nRaysPerPixel,... 
                'nbounces', nBounces,...
                'label', label,...
                'filmdistance', 0.49234);
% oiWindow(oiLeft); oiSet(oiLeft, 'gamma', 0.5);

[prevImgSimLeft, prevImgMeasLeft, sensorSimLeft,...
    sensorMeasLeft, ~, ipSimLeft, ipMeasLeft] = cbSensorSim(oiLeft, 'meas img path', measLeftImgPath,...
                                                'illuscale', 0.8,...
                                                'noise flag', 2,...
                                                'vignetting', []);
ieNewGraphWin; 
subplot(1, 2, 1); imshow(prevImgSimLeft);
subplot(1, 2, 2); imshow(prevImgMeasLeft);   

qualSaveDirPath = fullfile(cboxRootPath, 'local', 'figures', 'qualitative');
if ~exist(qualSaveDirPath, 'dir')
    mkdir(qualSaveDirPath);
end
simLeftName = 'simLeft.png';
measLeftName = 'measLeft.png';
imwrite(prevImgSimLeft, fullfile(qualSaveDirPath, simLeftName));
imwrite(prevImgMeasLeft, fullfile(qualSaveDirPath, measLeftName));

oiLeftName = 'oiLeft.mat';
save(fullfile(qualSaveDirPath, oiLeftName), 'oiLeft');

%% Right

%{
resolution = [252 189];
nRaysPerPixel = 256;
nBounces = 6;
%}

from = [0.02 0.20 -0.40];
to = [-0.1 0.115, 0.6];

measRightImgPath = fullfile(measPos1Path, 'right', 'selected', 'IMG_20210130_113451.dng');
label = 'Right';

oiRight = cbOISim('from', from,...
                'to', to,...
                'resolution', resolution,...
                'n rays per pixel', nRaysPerPixel,... 
                'nbounces', nBounces,...
                'label', label,...
                'filmdistance', 0.49234);
% oiWindow(oiRight); oiSet(oiRight, 'gamma', 0.5);

[prevImgSimRight, prevImgMeasRight, sensorSimRight,...
    sensorMeasRight, ~, ipSimRight, ipMeasRight] = cbSensorSim(oiRight, 'meas img path', measRightImgPath,...
                                                'illuscale', 0.75,...
                                                'noise flag', 2,...
                                                'vignetting', []);
ieNewGraphWin; 
subplot(1, 2, 1);imshow(prevImgSimRight);
subplot(1, 2, 2); imshow(prevImgMeasRight);     

qualSaveDirPath = fullfile(cboxRootPath, 'local', 'figures', 'qualitative');
if ~exist(qualSaveDirPath, 'dir')
    mkdir(qualSaveDirPath);
end
simRightName = 'simRight.png';
measRightName = 'measRight.png';
imwrite(prevImgSimRight, fullfile(qualSaveDirPath, simRightName));
imwrite(prevImgMeasRight, fullfile(qualSaveDirPath, measRightName));

oiRightName = 'oiRight.mat';
save(fullfile(qualSaveDirPath, oiRightName), 'oiRight');

%% Now let's produce random positions!
to = [-0.1 0.115, 0.6];

% {
resolution = [252 189] * 16;
nRaysPerPixel = 256 * 7;
nBounces = 6;
%}
% {
fromX = [-0.08 0.08];
fromY = [0.08, 0.2];
%}
% fromX = [0 0];
% fromY = [0 0];

nFrames = 3;
measRightImgPath = fullfile(measPos1Path, 'right', 'selected', 'IMG_20210130_113451.dng');

for ii = 1:1

thisX = (fromX(2)-fromX(1)).*rand(1,1) + fromX(1);
thisY = (fromY(2)-fromY(1)).*rand(1,1) + fromY(1);

thisFrom = [thisX thisY -0.42];

thisTo = [to(1) + 0.4 * (rand(1, 1)-0.5) to(2) + 0.4*(rand(1, 1)-0.5) 0.6];
label = ['Frame_#', num2str(ii)];

%{
thisFrom = [0 0.10 -0.385];
thisTo = [0 0.125, 0.6];
%}

oiFrame = cbOISim('from', thisFrom,...
                'to', thisTo,...
                'resolution', resolution,...
                'n rays per pixel', nRaysPerPixel,... 
                'nbounces', nBounces,...
                'label', label,...
                'filmdistance', 0.49234);
% oiWindow(oiFrame); oiSet(oiFrame, 'gamma', 0.5);

qualSaveDirPath = fullfile(cboxRootPath, 'local', 'figures', 'qualitative');
if ~exist(qualSaveDirPath, 'dir')
    mkdir(qualSaveDirPath);
end

oiName = ['oi',label,'.mat'];
save(fullfile(qualSaveDirPath, oiName), 'oiFrame');
end


%% Vis
[thisPrevImgSim, thisPrevImgMeas, thisSensorSim,...
    thisSensorMeas, ~, thisIpSim, thisIpMeas] = cbSensorSim(oiFrame,...
                                'meas img path', measRightImgPath,...
                                                'illuscale', 0.7,...
                                                'noise flag', 2,...
                                                'vignetting', []);
ieNewGraphWin; 
subplot(1, 2, 1);imshow(thisPrevImgSim);
subplot(1, 2, 2); imshow(thisPrevImgMeas); 

thisSensorSimName = 'thisSensorSim.mat';
thisSensorMeasName = 'thisSensorMeas.mat';
save(fullfile(noiseSaveDirPath, thisSensorSimName), 'thisSensorSim');
save(fullfile(noiseSaveDirPath, thisSensorMeasName), 'thisSensorMeas');