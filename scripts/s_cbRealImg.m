%% Initialize ISET
ieInit;

%% Load image data
imgPath = fullfile(cboxRootPath, 'local', 'cornell_box_img',...
                'Wall_and_Boxes', 'IMG_20201212_112438_0.dng');
% imgPath = fullfile(cboxRootPath, 'local', 'Single_Edge',...
%                     'IMG_20201211_143607_0.dng');            
            
[sensorReal, info] = sensorDNGRead(imgPath);

% sensorWindow(sensorReal);

%% Image processor
ipReal = ipCreate;
ipReal = ipSet(ipReal, 'render demosaic only', true);
ipReal = ipCompute(ipReal, sensorReal);
ipWindow(ipReal);

%%
rgbReal = [0.376899 0.418028 0.1808]
rgbSim = [0.616562 0.525089 0.297948]
realRG = rgbReal(1) / rgbReal(2);
realGB = rgbReal(2) / rgbReal(3);
realRB = rgbReal(1) / rgbReal(3);

simRG = rgbSim(1) / rgbSim(2);
simGB = rgbSim(2) / rgbSim(3);
simRB = rgbSim(1) / rgbSim(3);