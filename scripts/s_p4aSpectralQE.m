% s_p4aSpectralQE
% Estimate spectral QE of pixel 4a 
%% init
ieInit;
%% PART I: Load the real sensor image
%% Create sensor
%%%%%%%%%%%%%%%%%%%%% Create sensor for illuminant A %%%%%%%%%%%%%%%%%%%%%%
imgAName = 'IMG_20201024_123128.dng';
% Select the corner points: bottom left, bottom right, top right, top left
% cpDay = chartCornerpoints(camera_day);   % Select corners
cpAR = [38 222; 316 224; 314 41; 40 40];
% Read the rectangle of the image
thisRect = [1860  2010  350  255]; %col, row, width, height
% Read DNG files and other info
[sensorAR, infoAR, rgbMeanAR, rectsAR] = cbMccChipsDV(imgAName,...
                                                    'corner point', cpAR,...
                                                    'crop', thisRect,...
                                                    'vignetting', corrMapG1NormFull);
%{
sensorWindow(sensorAR);
chartRectsDraw(sensorAR,rectsAR);  % Visualize the rectangles
%}
%%%%%%%%%%%%%%%%%%%% Create sensor for illuminant CWF %%%%%%%%%%%%%%%%%%%%%                                               
imgCWFName = 'IMG_20201024_122900.dng';
% Select the corner points: bottom left, bottom right, top right, top left
% cpDay = chartCornerpoints(camera_day);   % Select corners
cpCWFR = [62 218; 337 222; 337 38; 63 37];
% Read the rectangle of the image
thisRect = [1860  2010  370  290]; %col, row, width, height
% Read DNG files and other info
[sensorCWFR, infoCWFR, rgbMeanCWFR, rectsCWFR] = cbMccChipsDV(imgCWFName,...
                                                    'corner point', cpCWFR,...
                                                    'crop', thisRect,...
                                                    'vignetting', corrMapG1NormFull);
%{
sensorWindow(sensorCWFR);
chartRectsDraw(sensorCWFR,rectsCWFR);  % Visualize the rectangles
%}                                                
%%%%%%%%%%%%%%%%%%%% Create sensor for illuminant Day %%%%%%%%%%%%%%%%%%%%%                                               
imgDayName = 'IMG_20201024_122631.dng';
% Select the corner points: bottom left, bottom right, top right, top left
% cpDay = chartCornerpoints(camera_day);   % Select corners
cpDayR = [73 218; 344 222; 344 39; 73 36];
% Read the rectangle of the image
thisRect = [1860  2010  370  290]; %col, row, width, height
% Read DNG files and other info
[sensorDayR, infoDayR, rgbMeanDayR, rectsDayR] = cbMccChipsDV(imgDayName,...
                                                    'corner point', cpDayR,...
                                                    'crop', thisRect,...
                                                    'vignetting', corrMapG1NormFull);
%{
sensorWindow(sensorDayR);
chartRectsDraw(sensorDayR,rectsDayR);  % Visualize the rectangles
%}                                                   
%% RGB value of MCC under illuminant A, CWF and Day. 
rgbMeanR = [rgbMeanAR; rgbMeanCWFR;rgbMeanDayR];
%% PART II: Compute simulated sensor
%% Load reflectance of mcc
mccName = 'MiniatureMacbethChart';
wave = 390:10:710;
patchSize = 32;
% In isetcalibrate/data/mcc
% lightNameA   = '20201023-illA-Average.mat'; % Tungsten (A)
lightNameA   = 'illA-20201023.mat'; % Tungsten (A)
lightNameCWF = 'illCWF-20201023.mat'; % CWF
lightNameDay = 'illDay-20201023.mat'; % Daylight

[sceneA, oiA] = cbMccSceneOISim('illuminant', lightNameA, 'wave', wave,...
                                'patch size', patchSize);
[sceneCWF, oiCWF] = cbMccSceneOISim('illuminant', lightNameCWF, 'wave', wave,...
                                'patch size', patchSize);       
[sceneDay, oiDay] = cbMccSceneOISim('illuminant', lightNameDay, 'wave', wave,...
                                'patch size', patchSize);                             
%{
    sceneWindow(sceneA);
    sceneWindow(sceneCWF);
    sceneWindow(sceneDay);
    oiWindow(oiA);
    oiWindow(oiCWF);
    oiWindow(oiDay);
%}
%% Compute sensor data 
sensorAS   = sensorAR; % S for simulation
sensorCWFS = sensorCWFR; 
sensorDayS = sensorDayR;

%%% Illuminant A %%%
% cpAS = chartCornerpoints(sensorAS);
% cpAS =[63 385; 546 382; 546 59; 62 60];
cpAS = [75 374; 532 374; 537 69; 74 67];
[sensorAS, rgbMeanAS, rectAS] = cbMccSensorSim(oiA, sensorAS, cpAS);
%{
sensorWindow(sensorAS);
chartRectsDraw(sensorAS,rectAS);  % Visualize the rectangles
%}
%%% Illuminant CWF %%%
% cpCWFS = chartCornerpoints(sensorCWFS);
% cpCWFS = [62 403; 546 404; 549 73; 62 77];
cpCWFS = [69 397; 536 401; 538 83; 66 80];
[sensorCWFS, rgbMeanCWFS, rectCWFS] = cbMccSensorSim(oiCWF, sensorCWFS, cpCWFS);
%{
sensorWindow(sensorCWFS);
chartRectsDraw(sensorCWFS,rectCWFS);  % Visualize the rectangles
%}
%%% Illuminant Day %%%
% cpDayS = [62 403; 546 404; 549 73; 62 77];
cpDayS = [69 397; 536 401; 538 83; 66 80];
[sensorDayS, rgbMeanDayS, rectDayS] = cbMccSensorSim(oiDay, sensorDayS, cpDayS);
%{
sensorWindow(sensorCWFS);
chartRectsDraw(sensorCWFS,rectCWFS);  % Visualize the rectangles
%}
% Concat simulated rgb values
rgbMeanS = [rgbMeanAS; rgbMeanCWFS; rgbMeanDayS];
%% Initial comparison
%{
ieNewGraphWin;
hold all
h1 = plot(rgbMeanS(:, 1), rgbMeanR(:, 1), 'ro');
h2 = plot(rgbMeanS(:, 2), rgbMeanR(:, 2), 'go');
h3 = plot(rgbMeanS(:, 3), rgbMeanR(:, 3), 'bo');
identityLine; box on
title('Simulated vs measured RGB values')
xlabel('Simulation'); ylabel('Measurement');
set(gca, 'FontSize', 20);
axis square
%}
%% First effort
L = cbMccFit(rgbMeanS, rgbMeanR);
pred = rgbMeanS * L;
% Plot the predicted color filter
sensorT = sensorAS;
cfS = sensorGet(sensorT, 'color filters');
cfPred = cfS * L;
%{
sensorT = sensorSet(sensorT, 'color filters', cfPred);
sensorPlot(sensorT, 'color filters');
%}
% cbMccPredEval('measurement', rgbMeanR, 'prediction', pred);
%% Diagonal transformation
diagL = cbMccFit(rgbMeanS, rgbMeanR, 'method', 'diag');
predDiag = rgbMeanS * diagL;
% Plot the predicted color filter
sensorT = sensorAS;
cfS = sensorGet(sensorT, 'color filters');
cfPredDiag = cfS * diagL;
%{
sensorT = sensorSet(sensorT, 'color filters', cfPredDiag);
sensorPlot(sensorT, 'color filters');
%}
% cbMccPredEval('measurement', rgbMeanR, 'prediction', cfPredDiag);
%% Constrained lsq equation

consL = cbMccFit(rgbMeanS, rgbMeanR, 'method', 'nonnegative');
predCons = rgbMeanS * consL;
% Plot the predicted color filter
sensorT = sensorAS;
cfS = sensorGet(sensorT, 'color filters');
cfPredCons = cfS * consL;

%{
sensorT = sensorSet(sensorT, 'color filters', cfPredCons);
sensorPlot(sensorT, 'color filters');
% Save the new color filter
savePath = fullfile(cboxRootPath, 'data', 'color', 'p4aCorrected.mat');
ieSaveColorFilter(sensorT, savePath);
%}
% cbMccPredEval('measurement', rgbMeanR, 'prediction', predCons);
%% Might delete in the future
% {
%% Compare sensor
sensorT = sensorAS;
sensorPred = sensorAS;

sensorTA = sensorCompute(sensorT, oiA);
sensorTCWF = sensorCompute(sensorT, oiCWF);
sensorTDay = sensorCompute(sensorT, oiDay);

sensorPred = sensorSet(sensorPred, 'color filters', cfPred);
% sensorSPred = sensorSet(sensorSPred, 'noise flag', 2);
sensorPredA = sensorCompute(sensorPred, oiA);
sensorPredCWF = sensorCompute(sensorPred, oiCWF);
sensorPredDay = sensorCompute(sensorPred, oiDay);

sensorPredDiag = sensorSet(sensorPred, 'color filters', cfPredDiag);
sensorPredADiag = sensorCompute(sensorPredDiag, oiA);
sensorPredCWFDiag = sensorCompute(sensorPredDiag, oiCWF);
sensorPredDayDiag = sensorCompute(sensorPredDiag, oiDay);

sensorPredCons = sensorSet(sensorPred, 'color filters', cfPredCons);
sensorPredACons = sensorCompute(sensorPredCons, oiA);
sensorPredCWFCons = sensorCompute(sensorPredCons, oiCWF);
sensorPredDayCons = sensorCompute(sensorPredCons, oiDay);
%{
sensorWindow(sensorPredA);
sensorWindow(sensorPredADiag);
sensorWindow(sensorPredACons);
sensorWindow(sensorAR);

sensorWindow(sensorPredCWF);
sensorWindow(sensorPredCWFDiag);
sensorWindow(sensorPredCWFCons);
sensorWindow(sensorCWFR);

sensorWindow(sensorPredDay);
sensorWindow(sensorPredDayDiag);
sensorWindow(sensorPredDayCons);
sensorWindow(sensorDayR);
%}
%}
% {
%% Compare ip
ip = ipCreate;
ip = ipSet(ip, 'render demosaic only', true);
ip = ipSet(ip, 'scale display', 0);
% Real img
ipAR = ipCompute(ip, sensorAR);
ipCWFR = ipCompute(ip, sensorCWFR);
ipDayR = ipCompute(ip, sensorDayR);

% Simulation - no correction
ipAT = ipCompute(ip, sensorTA);
ipCWFT = ipCompute(ip, sensorTCWF);
ipDayT = ipCompute(ip, sensorTDay);

% Simulation - all entry
ipPredA = ipCompute(ip, sensorPredA);
ipPredCWF = ipCompute(ip, sensorPredCWF);
ipPredDay = ipCompute(ip, sensorPredDay);

% Simulation - diagonal
ipPredADiag = ipCompute(ip, sensorPredADiag);
ipPredCWFDiag = ipCompute(ip, sensorPredCWFDiag);
ipPredDayDiag = ipCompute(ip, sensorPredDayDiag);

% Simulation - constraint
ipPredACons = ipCompute(ip, sensorPredACons);
ipPredCWFCons = ipCompute(ip, sensorPredCWFCons);
ipPredDayCons = ipCompute(ip, sensorPredDayCons);

% Visualize
ipWindow(ipAR);
ipWindow(ipAT);
ipWindow(ipPredACons);

imgAR = ipGet(ipAR, 'results');
imgAT = ipGet(ipAT, 'results');
imgPredACons = ipGet(ipPredACons, 'results');
ieNewGraphWin; imshow(imgAR.^0.4);
ieNewGraphWin; imshow(imgAT.^0.4);
ieNewGraphWin; imshow(imgPredACons.^0.4);

imgCWFR = ipGet(ipCWFR, 'results');
imgCWFT = ipGet(ipCWFT, 'results');
imgPredCWFCons = ipGet(ipPredCWFCons, 'results');
ieNewGraphWin; imshow(imgCWFR.^0.4);
ieNewGraphWin; imshow(imgCWFT.^0.4);
ieNewGraphWin; imshow(imgPredCWFCons.^0.4);

imgDayR = ipGet(ipDayR, 'results');
imgDayT = ipGet(ipDayT, 'results');
imgPredDayCons = ipGet(ipPredDayCons, 'results');
ieNewGraphWin; imshow(imgDayR.^0.4);
ieNewGraphWin; imshow(imgDayT.^0.4);
ieNewGraphWin; imshow(imgPredDayCons.^0.4);
%}
%% END