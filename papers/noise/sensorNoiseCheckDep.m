
%%
ieInit;

%%
sensorDir = fullfile(cboxRootPath, 'local',...
                    'figures', 'noise');
%%
% Measurement
sensorMeasPath = fullfile(sensorDir, 'sensorMeasCtr.mat');
load(sensorMeasPath, 'sensorMeasCtr');

% Simulation
sensorSimPath = fullfile(sensorDir, 'sensorSimCtr.mat');
load(sensorSimPath, 'sensorSimCtr');
%% Parameter initialization
nROI = 5;
width = 10; height = 10;
%% Simulation

roiSelectsSim = cell(1, nROI);
% [x(horizon), y(vertical), w, h];
roiSelectsSim{1} = [722, 418, width, height];
roiSelectsSim{2} = [1478, 550, width, height];
roiSelectsSim{3} = [2579, 634, width, height];
roiSelectsSim{4} = [2090, 1904, width, height];
roiSelectsSim{5} = [1512, 2067, width, height];
% roiSelectsSim{6} = [1500, 2000, width, height];
% roiSelectsSim{7} = [2000, 1000, width, height];
% roiSelectsSim{8} = [2000, 1500, width, height];
% roiSelectsSim{9} = [2000, 2000, width, height];

[udataSelectsSim, prevImgROISim] = cbRoiSelect(sensorSimCtr, roiSelectsSim);
% ieNewGraphWin; imshow(prevImgROISim);

%% Measurement
roiSelectsMeas{1} = [908, 553, width, height];
roiSelectsMeas{2} = [1946, 797, width, height];
roiSelectsMeas{3} = [3193, 995, width, height];
roiSelectsMeas{4} = [2732, 2356, width, height];
roiSelectsMeas{5} = [1980, 2551, width, height];

[udataSelectsMeas, prevImgROIMeas] = cbRoiSelect(sensorMeasCtr, roiSelectsMeas);

%% Compare

%%
tmp = double(sensorGet(sensorMeasCtr, 'dv'));

tmpG = tmp(1:2:end, 2:2:end);

tmpGV = tmpG./imresize(vignetting, 0.5);
ieNewGraphWin; imagesc(tmpGV)

cp = [1566 527 10 10];
crpWin = imcrop(tmpGV, cp);

res = isUniformPatch(crpWin);