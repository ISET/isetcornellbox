%% s_PixelSimulation
% Calculate sensor data

%% Initialize ISET
ieInit;

%% Load optical image data
oiPath = fullfile(cboxRootPath, 'local', 'CBLens_first_attempt.mat');
load(oiPath, 'oi');
%{
    oiWindow(oi);
    oiSet(oi, 'gamma', 0.5);
%}

%% Scale the oi

%% Create IMX363 sensor
sensorPx = sensorCreate('IMX363');
sensorPx = sensorSet(sensorPx, 'exp time', 0.0141); % Exp time from real image
sensorPx = sensorSet(sensorPx, 'name', 'Pixel sensor');
sensorPx = sensorSetSizeToFOV(sensorPx, oiGet(oi, 'fov'), oi);

%% Calculate sensor data
sensorPx = sensorCompute(sensorPx, oi);
% sensorWindow(sensorPx);

%% Image processor
ip = ipCreate;
ip = ipSet(ip,'render demosaic only',true);
ip = ipCompute(ip, sensorPx);
ipWindow(ip);


