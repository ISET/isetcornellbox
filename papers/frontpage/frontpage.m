%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%%
% tmp = load('p4aLensVignet.mat', 'pixel4aLensVignetSlope');
% vignetting = tmp.pixel4aLensVignetSlope;
%% Basic parameter initialization

resolution = [252 189] * 4;
nRaysPerPixel = 1024;
nBounces = 8;
measPos1Path = fullfile(cboxRootPath, 'local', 'measurement', 'camerapos');

%% Wrong: lens, QE, noise

from = [0 0.10 -0.55];
to = [0 0.125, 0.6];
                                  
measCenerImgPath = fullfile(measPos1Path, 'center', 'selected', 'IMG_20210130_111914.dng');
[sensor, info] = sensorDNGRead(measCenerImgPath);

label = 'Center';

oiFishEye = cbOISim('from', from,...
                'to', to,...
                'resolution', resolution,...
                'n rays per pixel', nRaysPerPixel,... 
                'nbounces', nBounces,...
                'label', label,...
                'lens type', 'omni',...
                'lens file', 'fisheye.87deg.6.0mm.json',...
                'film distance', []);
oiWindow(oiFishEye); oiSet(oiFishEye, 'gamma', 0.5);

[prevImgSimCtr, prevImgMeasCtr, sensorSimCtr,...
    sensorMeasCtr, ~, ipSimCtr, ipMeasCtr] = cbSensorSim(oiFishEye, 'meas img path', measCenerImgPath,...
                                                'illuscale', 0.03,...
                                                'noise flag', 2,...
                                                'vignetting', [],...
                                                'transcolorfilter', false,...
                                                'usedemonoise', true);
%{
  sensorWindow(sensorSimCtr);
  sensorWindow(sensorMeasCtr);
%}
% ipWindow(ipSimCtr); ipWindow(ipMeasCtr);                                            
ieNewGraphWin; 
subplot(1, 2, 1); imshow(prevImgSimCtr);
subplot(1, 2, 2); imshow(prevImgMeasCtr);
% {
frontPageSaveDirPath = fullfile(cboxRootPath, 'local', 'figures', 'frontPage');
if ~exist(frontPageSaveDirPath, 'dir')
    mkdir(frontPageSaveDirPath);
end

simName = 'simWrongLensQENoise.png';
measName = 'measCtr.png';
imwrite(prevImgSimCtr, fullfile(frontPageSaveDirPath, simName));
imwrite(prevImgMeasCtr, fullfile(frontPageSaveDirPath, measName));

oiCtrName = 'oiFishEye.mat';
sensorSimCtrName = 'sensorSimCtr.mat';
sensorMeasCtrName = 'sensorMeasCtr.mat';
save(fullfile(frontPageSaveDirPath, oiCtrName), 'oiFishEye');
%}

%% Lens correction
load('oiCtr.mat');
[prevImgSimCtr, prevImgMeasCtr, sensorSimCtr,...
    sensorMeasCtr, ~, ipSimCtr, ipMeasCtr] = cbSensorSim(oiCtr, 'meas img path', measCenerImgPath,...
                                                'illuscale', 0.55,...
                                                'noise flag', 2,...
                                                'vignetting', [],...
                                                'transcolorfilter', false,...
                                                'usedemonoise', true);
ieNewGraphWin; 
subplot(1, 2, 1); imshow(prevImgSimCtr);
subplot(1, 2, 2); imshow(prevImgMeasCtr);
simName = 'simCorrLensWrongQENoise.png';
imwrite(prevImgSimCtr, fullfile(frontPageSaveDirPath, simName));

%% Noise correction
[prevImgSimCtr, prevImgMeasCtr, sensorSimCtr,...
    sensorMeasCtr, ~, ipSimCtr, ipMeasCtr] = cbSensorSim(oiCtr, 'meas img path', measCenerImgPath,...
                                                'illuscale', 0.55,...
                                                'noise flag', 2,...
                                                'vignetting', [],...
                                                'transcolorfilter', false,...
                                                'usedemonoise', false);
ieNewGraphWin; 
subplot(1, 2, 1); imshow(prevImgSimCtr);
subplot(1, 2, 2); imshow(prevImgMeasCtr);
simName = 'simCorrLensNoiseWrongQE.png';
imwrite(prevImgSimCtr, fullfile(frontPageSaveDirPath, simName));

%% QE correction
