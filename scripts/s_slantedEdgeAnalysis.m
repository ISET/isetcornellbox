%%
% For Tessar lens

%% Load oi
oiName = 'CBLens_Focus_50cm_HQ_tessar_on_axis.mat';
load(oiName, 'oi');
oi = oiSet(oi, 'fov', 39.3061);
%%
% s_slantedEdgeAnalysis
sensor = sensorCreate('IMX363');

sensor = sensorSetSizeToFOV(sensor, oiGet(oi, 'fov'), oi);
sensor = sensorSet(sensor, 'noise flag', 0);
sensor = sensorSet(sensor, 'exp time', 0.00141);
sensor = sensorCompute(sensor, oi);
% sensorWindow(sensor);
ieAddObject(sensor);
ip = ipCreate;
ip = ipSet(ip, 'render demosaic only', true);
ip = ipCompute(ip, sensor);
ipWindow(ip);

%% Real Tessar lens MTF curve from book
fName = 'TessarLensMTF';
[mtfTessar, wave] = ieReadSpectra(fName);

ieNewGraphWin;
plot(wave, mtfTessar);