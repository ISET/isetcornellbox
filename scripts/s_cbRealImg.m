%% Initialize ISET
ieInit;

%% Load image data
imgPath = fullfile(cboxRootPath, 'local', 'mcc_img',...
                'middle', 'IMG_20201212_112601_1.dng');
imgPath = fullfile(cboxRootPath, 'local', 'Single_Edge',...
                    'IMG_20201211_143607_1.dng');            
imgPath = fullfile(cboxRootPath, 'local', 'slantedbar',...
                    'IMG_20201211_141901_2.dng');
rectRealPos = [426 164 3350 2698];
[sensorReal, info] = sensorDNGRead(imgPath, 'crop',rectRealPos);
% sensorWindow(sensorReal);
% [~, rectReal] = ieROISelect(sensorReal);
%%
sensorPlot(sensorReal, 'dv hline', [1, 917]);
%% Image processor
ipReal = ipCreate;
ipReal = ipSet(ipReal, 'render demosaic only', true);
ipReal = ipCompute(ipReal, sensorReal);
ipWindow(ipReal);

