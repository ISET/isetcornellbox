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
roiIntMeasBack = [1953        2087          43          68];
% roiIntMeasBack = [1807 1795 65 96];
mtfDataMeasBack = cbMTFAnalysis(ipMeasBack, roiIntMeasBack, dx);
filmHeightMeasBack = cbSensorLoc2FilmHeight(sensorMeasBack,...
                                    [roiIntMeasBack(2), roiIntMeasBack(1)]);

% Front
dngFileFront = fullfile('distance_1', 'focus_back', '0.4s_exp',...
                'IMG_20210106_171705.dng');
[sensorMeasFront, ~, ipMeasFront] = cbDNGRead(fullfile(measPath, dngFileFront), 'demosaic', true);
%{
ipWindow(ipMeasFront);
[roiLocs,roiMeasFront] = ieROISelect(ipMeasFront);
roiIntMeasFront = round(roiMeasFront.Position);
%}
roiIntMeasFront = [2518 1557 97 144]; 
mtfDataMeasFront = cbMTFAnalysis(ipMeasFront, roiIntMeasFront, dx);
filmHeightMeasFront = cbSensorLoc2FilmHeight(sensorMeasFront,...
                                    [roiIntMeasFront(2), roiIntMeasFront(1)]);
                                
%% Simulation: focus back
% NOTE: 0.48736 looks like a good position for back focus, need to move a
% bit further though
% 0.48934 is an even better one

% NOTE: 0.59847 is too far for focusing in front. Move it closer
% Load oi
% Focus back: filmdist_0.49234mm
mtfPath = fullfile(cboxRootPath, 'local', 'simulation', 'slantedBar');

mtfFile = 'CBRTF_slantedEdge_filmdist_0.49234mm.mat';

load(fullfile(mtfPath, mtfFile));
%{
oiWindow(oiSlantedBar);
oiSet(oiSlantedBar, 'gamma', 0.5);
%}
meanIllu = oiGet(oiSlantedBar, 'mean illuminance');
oiSlantedBarAdj = oiSet(oiSlantedBar, 'mean illuminance', meanIllu/2);
sensorSim = sensorMeasBack;
sensorSim = cbSensorCompute(sensorSim, oiSlantedBarAdj);
ipSim = cbIpCompute(sensorSim);

%{
ipWindow(ipSim);
[roiLocs,roiSimBack] = ieROISelect(ipSim);
roiIntSimBack = round(roiSimBack.Position);
%}

% roiIntSimBack = [1729 1665 72 145];
roiIntSimBack = [1829 2067 27 46];
mtfDataSimBack = cbMTFAnalysis(ipSim, roiIntSimBack, dx);
filmHeightSimBack = cbSensorLoc2FilmHeight(sensorSim,...
                                    [roiIntSimBack(2), roiIntSimBack(1)]);
%{
ipWindow(ipSim);
[roiLocs,roiSimFront] = ieROISelect(ipSim);
roiIntSimFront = round(roiSimFront.Position);
%}

roiIntSimFront = [2511        1667          48          127]; % [2461 1546 135 202];
mtfDataSimFront = cbMTFAnalysis(ipSim, roiIntSimFront, dx);
filmHeightSimFront = cbSensorLoc2FilmHeight(sensorSim,...
                                    [roiIntSimFront(2), roiIntSimFront(1)]);
                                
%% Figure plot: Focus back
freqMeasBack = mtfDataMeasBack.freq + 0.0001;
mtfMeasBack = mtfDataMeasBack.mtf(:,4);
lsfxMeasBack = mtfDataMeasBack.lsfx;
lsfMeasBack = mtfDataMeasBack.lsf;
freqSimBack = mtfDataSimBack.freq + 0.0001;
mtfSimBack = mtfDataSimBack.mtf(:,4);
lsfxSimBack = mtfDataSimBack.lsfx;
lsfSimBack = mtfDataSimBack.lsf;

freqMeasFront = mtfDataMeasFront.freq + 0.0001;
mtfMeasFront = mtfDataMeasFront.mtf(:,4);
lsfxMeasFront = mtfDataMeasFront.lsfx;
lsfMeasFront = mtfDataMeasFront.lsf;
freqSimFront = mtfDataSimFront.freq + 0.0001;
mtfSimFront = mtfDataSimFront.mtf(:,4);
lsfxSimFront = mtfDataSimFront.lsfx;
lsfSimFront = mtfDataSimFront.lsf;

% MTF curve
% {
ieNewGraphWin; hold all; 
plot(freqMeasBack, mtfMeasBack,':k','LineWidth', 3);
plot(freqSimBack, mtfSimBack, 'k','LineWidth', 3);
plot(freqMeasFront, mtfMeasFront, ':r', 'LineWidth', 3);
plot(freqSimFront, mtfSimFront, 'r', 'LineWidth', 3);
box on; grid on;
xlabel('Spatial frequency (cy/mm)'); ylabel('Contrast reduction (SFR)');
xlim([0 350]); ylim([0 1])
legend('MTF@0.5m-Meas', 'MTF@0.5m-Sim', 'MTF@0.3m-Meas', 'MTF@0.3m-Sim');
title('Focused @0.5m');
%}

% LSF
% {
ieNewGraphWin; hold all;
plot(lsfxMeasBack, lsfMeasBack, ':k', 'LineWidth', 3);
% Slight shift for curve allignment
plot(lsfxSimBack-0.0009, lsfSimBack, 'k', 'LineWidth', 3);
plot(lsfxMeasFront+0.0050, lsfMeasFront, ':r', 'LineWidth', 3);
plot(lsfxSimFront+0.002, lsfSimFront, 'r', 'LineWidth', 3);
xlim([-0.06 0.06]); ylim([0 1]);
box on; grid on; 
legend('LSF@0.5m-Meas', 'LSF@0.5m-Sim', 'LSF@0.3m-Meas', 'LSF@0.3m-Sim');
title('Focused @0.5m');
xlabel('Pixel position'); ylabel('Relative intensity');
%}


%% Measurement: focus front
% Back
dngFileBack2 = fullfile('distance_1', 'focus_front', '0.2s_exp',...
                'IMG_20210106_171803.dng');
            
[sensorMeasBack2, ~, ipMeasBack2] = cbDNGRead(fullfile(measPath, dngFileBack2), 'demosaic', true);
dx = sensorGet(sensorMeasBack2,'pixel width','mm');

%{
ipWindow(ipMeasBack2);
[roiLocs,roiMeasBack2] = ieROISelect(ipMeasBack2);
roiIntMeasBack2 = round(roiMeasBack2.Position);
%}
% roiIntMeasBack2 = [1835 1854 58 92];
roiIntMeasBack2 = [1924        2055         118         161];
% roiIntMeasBack2 = [1807 1795 65 96];
mtfDataMeasBack2 = cbMTFAnalysis(ipMeasBack2, roiIntMeasBack2, dx);
filmHeightMeasBack2 = cbSensorLoc2FilmHeight(sensorMeasBack,...
                                    [roiIntMeasBack2(2), roiIntMeasBack2(1)]);

% Front
dngFileFront2 = fullfile('distance_1', 'focus_front', '0.4s_exp',...
                'IMG_20210106_171912.dng');
[sensorMeasFront2, ~, ipMeasFront2] = cbDNGRead(fullfile(measPath, dngFileFront2), 'demosaic', true);
%{
ipWindow(ipMeasFront2);
[roiLocs,roiMeasFront2] = ieROISelect(ipMeasFront2);
roiIntMeasFront2 = round(roiMeasFront2.Position);
%}
% roiIntMeasFront2 = [2380 1883 66 111];
roiIntMeasFront2 = [2515 1475 109 195]; %  [2380 1883 66 111]; 
mtfDataMeasFront2 = cbMTFAnalysis(ipMeasFront2, roiIntMeasFront2, dx);
filmHeightMeasFront2 = cbSensorLoc2FilmHeight(sensorMeasFront,...
                                    [roiIntMeasFront2(2), roiIntMeasFront2(1)]);


%% Simulation: Focus front
mtfPath = fullfile(cboxRootPath, 'local', 'simulation', 'slantedBar');

% Front: filmdist 0.57624mm.
mtfFile = 'CBRTF_slantedEdge_filmdist_0.57624mm.mat';

load(fullfile(mtfPath, mtfFile));
%{
oiWindow(oiSlantedBar);
oiSet(oiSlantedBar, 'gamma', 0.5);
%}
meanIllu2 = oiGet(oiSlantedBar, 'mean illuminance');
oiSlantedBarAdj2 = oiSet(oiSlantedBar, 'mean illuminance', meanIllu2/2);
sensorSim2 = sensorMeasBack;
sensorSim2 = cbSensorCompute(sensorSim2, oiSlantedBarAdj2);
ipSim2 = cbIpCompute(sensorSim2);

%{
% For paper illustration
sensorSim2 = cbSensorCompute(sensorSim2, oiSlantedBar);
ipSim2 = cbIpCompute(sensorSim2);
ipWindow(ipSim2);
%}

%{
ipWindow(ipSim2);
[roiLocs,roiSimBack2] = ieROISelect(ipSim2);
roiIntSimBack2 = round(roiSimBack2.Position);
%}


% roiIntSimBack = [1729 1665 72 145];
roiIntSimBack2 = [1824 2025 70 183];
mtfDataSimBack2 = cbMTFAnalysis(ipSim2, roiIntSimBack2, dx);
filmHeightSimBack2 = cbSensorLoc2FilmHeight(sensorSim2,...
                                    [roiIntSimBack2(2), roiIntSimBack2(1)]);
%{
ipWindow(ipSim2);
[roiLocs,roiSimFront2] = ieROISelect(ipSim2);
roiIntSimFront2 = round(roiSimFront2.Position);
%}

roiIntSimFront2 = [2394 1173 48 91];
mtfDataSimFront2 = cbMTFAnalysis(ipSim2, roiIntSimFront2, dx);
filmHeightSimFront2 = cbSensorLoc2FilmHeight(sensorSim2,...
                                    [roiIntSimFront2(2), roiIntSimFront2(1)]);
%% Figure plot: focus front
freqMeasBack2 = mtfDataMeasBack2.freq + 0.0001;
mtfMeasBack2 = mtfDataMeasBack2.mtf(:,4);
lsfxMeasBack2 = mtfDataMeasBack2.lsfx;
lsfMeasBack2 = mtfDataMeasBack2.lsf;
freqSimBack2 = mtfDataSimBack2.freq + 0.0001;
mtfSimBack2 = mtfDataSimBack2.mtf(:,4);
lsfxSimBack2 = mtfDataSimBack2.lsfx;
lsfSimBack2 = mtfDataSimBack2.lsf;

freqMeasFront2 = mtfDataMeasFront2.freq + 0.0001;
mtfMeasFront2 = mtfDataMeasFront2.mtf(:,4);
lsfxMeasFront2 = mtfDataMeasFront2.lsfx;
lsfMeasFront2 = mtfDataMeasFront2.lsf;
freqSimFront2 = mtfDataSimFront2.freq + 0.0001;
mtfSimFront2 = mtfDataSimFront2.mtf(:,4);
lsfxSimFront2 = mtfDataSimFront2.lsfx;
lsfSimFront2 = mtfDataSimFront2.lsf;

ieNewGraphWin; hold all; 
plot(freqMeasBack2, mtfMeasBack2, ':k', 'LineWidth', 8);
plot(freqSimBack2, mtfSimBack2, 'k', 'LineWidth', 8);
plot(freqMeasFront2, mtfMeasFront2, ':r', 'LineWidth', 8);
plot(freqSimFront2, mtfSimFront2, 'r', 'LineWidth', 8);
box on; grid on;
xlabel('Spatial frequency (cy/mm)'); ylabel('Contrast reduction (SFR)');
xlim([0 350]); ylim([0 1])
legend('MTF@0.5m-Meas', 'MTF@0.5m-Sim', 'MTF@0.3m-Meas', 'MTF@0.3m-Sim');
title('Focused @0.3m');

% LSF
% {
ieNewGraphWin; hold all;
plot(lsfxMeasBack2+0.0008, lsfMeasBack2, ':k', 'LineWidth', 8);
plot(lsfxSimBack2-0.0010, lsfSimBack2, 'k', 'LineWidth', 8);
plot(lsfxMeasFront2-0.0012, lsfMeasFront2, ':r', 'LineWidth', 8);
plot(lsfxSimFront2+0.00175, lsfSimFront2, 'r', 'LineWidth', 8);
box on; grid on;
xlabel('Pixel position'); ylabel('Relative intensity');
xlim([-0.06 0.06]); ylim([0 1])
legend('LSF@0.5m-Meas', 'LSF@0.5m-Sim', 'LSF@0.3m-Meas', 'LSF@0.3m-Sim');
title('Focused @0.3m');
%}

%% Get preview
