% s_cbSensorNoiseAnalysis
% Example code of conducting sensor noise analysis

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Create Cornell Box recipe
thisR = cbBoxCreate;
thisR.set('film resolution', [512, 512]);
thisR.set('nbounces', 3);
thisR.set('rays per pixel', 512);
%% Write and render
piWrite(thisR);
[scene, results] = piRender(thisR, 'render type', 'radiance');
% sceneWindow(scene);

%% Create OI
oi = oiCreate;
oi = oiSet(oi, 'fov', 20);
oi = oiCompute(oi, scene);
meanIllu = oiGet(oi, 'mean illuminance');
oi = oiSet(oi, 'mean illuminance', meanIllu * 0.5);
% oiWindow(oi);
%% Create sensor
% Load real image
dngName = 'IMG_20210105_162204.dng';
[sensorR, infoR, ipR] = cbDNGRead(dngName, 'demosaic', true);
%{
sensor = sensorCreate('IMX363');
sensor = sensorSet(sensor, 'exp time', 0.2);
%}
sensor = sensorR;
sensor = sensorSetSizeToFOV(sensor, oiGet(oi, 'fov'), oi);
wave = 390:10:710;
cf = ieReadSpectra('p4aCorrected.mat', wave);
sensor = sensorSet(sensor, 'color filters', cf);

sensor = sensorCompute(sensor, oi);
% sensorWindow(sensor);

%% IP
ip = ipCreate;
ip = ipSet(ip, 'render demosaic only', true);
ip = ipCompute(ip, sensor);
% ipWindow(ip);

prevImg = ipGet(ip, 'srgb');
ieNewGraphWin; imshow(prevImg);
%%
sensorTmp = sensor;

nROI = 9;
roiSelects = cell(1, nROI);
% [x(horizon), y(vertical), w, h];
width = 30; height = 30;
roiSelects{1} = [1000, 1000, width, height];
roiSelects{2} = [1000, 1500, width, height];
roiSelects{3} = [1000, 2000, width, height];
roiSelects{4} = [1500, 1000, width, height];
roiSelects{5} = [1500, 1500, width, height];
roiSelects{6} = [1500, 2000, width, height];
roiSelects{7} = [2000, 1000, width, height];
roiSelects{8} = [2000, 1500, width, height];
roiSelects{9} = [2000, 2000, width, height];

udataSelects = cell(1, nROI);


for ii = 1:nROI
    sensorTmp = sensorSet(sensorTmp, 'roi', roiSelects{ii});
    udataSelects{ii} = sensorStats(sensorTmp, 'basic', 'dv');
end

%% Draw rects
prevImgROI = prevImg;
for ii = 1:nROI
prevImgROI = insertShape(prevImgROI, 'rectangle', roiSelects{ii}, 'LineWidth', 8,...
                                     'Color', 'yellow');
end

ieNewGraphWin; imshow(prevImgROI);

%% Draw the comparison
udataReal = udataSelects; % Later this will be the real data

% Mean RGB
ieNewGraphWin; hold all
title('Mean RGB: I am not the final result yet!!')
for ii = 1:nROI
    plot(udataReal{ii}.mean(1), udataSelects{ii}.mean(1), 'ro',...
                                'MarkerSize', 8, 'LineWidth', 2);
    plot(udataReal{ii}.mean(2), udataSelects{ii}.mean(2), 'go',...
                                'MarkerSize', 8, 'LineWidth', 2);  
    plot(udataReal{ii}.mean(3), udataSelects{ii}.mean(3), 'bo',...
                                'MarkerSize', 8, 'LineWidth', 2);                              
end
identityLine; axis square; box on;
xlabel('Measured'); ylabel('Simulated')

% STD
ieNewGraphWin; hold all
title('STD RGB: I am not the final result yet!!')
for ii = 1:nROI
    plot(udataReal{ii}.std(1), udataSelects{ii}.std(1), 'ro',...
                                'MarkerSize', 8, 'LineWidth', 2);
    plot(udataReal{ii}.std(2), udataSelects{ii}.std(2), 'go',...
                                'MarkerSize', 8, 'LineWidth', 2);  
    plot(udataReal{ii}.std(3), udataSelects{ii}.std(3), 'bo',...
                                'MarkerSize', 8, 'LineWidth', 2);                              
end
identityLine; axis square; box on;
xlabel('Measured'); ylabel('Simulated')
