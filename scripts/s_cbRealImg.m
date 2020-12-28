%% Initialize ISET
ieInit;

%% Load image data
imgPath = fullfile(cboxRootPath, 'local', 'cornell_box_img',...
                'Wall_and_Boxes', 'IMG_20201212_112438_0.dng');
            
[sensorReal, info] = sensorDNGRead(imgPath);

% sensorWindow(sensorReal);

%% Image processor
ipReal = ipCreate;
ipReal = ipSet(ipReal, 'render demosaic only', true);
ipReal = ipCompute(ipReal, sensorReal);
ipWindow(ipReal);