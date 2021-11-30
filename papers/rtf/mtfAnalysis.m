%%
ieInit;

%% Measurement: focus back
% Distance 1: 0.5m, 0.3m
% Load resolution chart
measPath = fullfile(cboxRootPath, 'local', 'measurement',...
                'resolution_targets');
% Back
dngFileBack = fullfile('distance_1', 'focus_back', '0.2s_exp',...
                'IMG_20210106_171618.dng');
            
[sensorMeasBack, ~, ipMeasBack] = cbDNGRead(fullfile(measPath, dngFileBack), 'demosaic', true);
dx = sensorGet(sensorMeasBack,'pixel width','mm');

%{
ipWindow(ipMeasBack);
[roiLocs,roiMeasBack] = ieROISelect(ipMeasBack);
roiIntMeasBack = round(roiMeasBack.Position);
%}
roiIntMeasBack = [1835 1854 58 92];
mtfDataMeasBack = cbMTFAnalysis(ipMeasBack, roiIntMeasBack, dx);


% Front
dngFileFront = fullfile('distance_1', 'focus_back', '0.4s_exp',...
                'IMG_20210106_171705.dng');
[sensorMeasFront, ~, ipMeasFront] = cbDNGRead(fullfile(measPath, dngFileFront), 'demosaic', true);
%{
ipWindow(ipMeasFront);
[roiLocs,roi] = ieROISelect(ipMeasFront);
roiIntMeasFront = round(roi.Position);
%}
roiIntMeasFront = [2528        1578          43          65];
mtfDataMeasFront = cbMTFAnalysis(ipMeasFront, roiIntMeasFront, dx);

%% Simulation
% Load oi
mtfPath = fullfile(cboxRootPath, 'local', 'simulation', 'slantedBar');

mtfFile = 'CBRTF_slantedEdge_filmdist_0.48736mm.mat';

load(fullfile(mtfPath, mtfFile));
%{
oiWindow(oiSlantedBar);
oiSet(oiSlantedBar, 'gamma', 0.5);
%}

sensorSim = sensorMeas;
sensorSim = cbSensorCompute(sensorSim, oiSlantedBar);
ipSim = cbIpCompute(sensorSim);

%{
ipWindow(ipSim);
[roiLocs,roi] = ieROISelect(ipSim);
roiIntSimBack = round(roi.Position);
%}

roiIntSimBack = [1743 1891 28 41];
mtfDataSimBack = cbMTFAnalysis(ipSim, roiIntSimBack, dx);

%{
ipWindow(ipSim);
[roiLocs,roi] = ieROISelect(ipSim);
roiIntSimFront = round(roi.Position);
%}

roiIntMeasFront = [2523        2015          44          70];
mtfDataSimFront = cbMTFAnalysis(ipSim, roiIntMeasFront, dx);
