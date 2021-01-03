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
                                                    'crop', thisRect);
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
                                                    'crop', thisRect);
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
                                                    'crop', thisRect);
%% RGB value of MCC under illuminant A, CWF and Day. 
rgbMeanR = [rgbMeanAR; rgbMeanCWFR;rgbMeanDayR];
%% PART II: Compute simulated sensor
%% Load reflectance of mcc
mccName = 'MiniatureMacbethChart';
wave = 390:10:710;
patchSize = 32;
% In isetcalibrate/data/mcc
lightNameA   = '20201023-illA-Average.mat'; % Tungsten (A)
lightNameCWF = '20201023-illCWF-Average.mat'; % CWF
lightNameDay = '20201023-illDay-Average.mat'; % Daylight

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
cpAS =[63 385; 546 382; 546 59; 62 60];
[sensorAS, rgbMeanAS, rectAS] = cbMccSensorSim(oiA, sensorAS, cpAS);
%{
sensorWindow(sensorAS);
chartRectsDraw(sensorAS,rectsAS);  % Visualize the rectangles
%}
%%% Illuminant CWF %%%
cpCWFS = [62 403; 546 404; 549 73; 62 77];
[sensorCWFS, rgbMeanCWFS, rectCWFS] = cbMccSensorSim(oiCWF, sensorCWFS, cpCWFS);
%{
sensorWindow(sensorCWFS);
chartRectsDraw(sensorCWFS,rectsCWFS);  % Visualize the rectangles
%}
%%% Illuminant Day %%%
cpDayS = [62 403; 546 404; 549 73; 62 77];
[sensorDayS, rgbMeanDayS, rectDayS] = cbMccSensorSim(oiDay, sensorDayS, cpDayS);
% Concat simulated rgb values
rgbMeanS = [rgbMeanAS; rgbMeanCWFS; rgbMeanDayS];
%% Initial comparison
%{
ieNewGraphWin;
plot(rgbMeanS, rgbMeanR, 'o');
identityLine;
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
% cbMccPredEval('measurement', rgbMeanR, 'prediction', predDiag);
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
%}
% cbMccPredEval('measurement', rgbMeanR, 'prediction', predCons);
%% Might delete in the future
% {
%% Compare sensor
sensorPred = sensorAS;
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
% Real img
ipAR = ipCompute(ip, sensorAR);
ipCWFR = ipCompute(ip, sensorCWFR);
ipDayR = ipCompute(ip, sensorDayR);

% Simulation - all entry
ipPredA = ipCompute(ip, sensorPredA);
ipPredCWF = ipCompute(ip, sensorPredCWF);
ipPredDay = ipCompute(ip, sensorPredDay);

% Simulation - diagonal
ipPredADiag = ipCompute(ip, sensorPredADiag);
ipPredCWFDiag = ipCompute(ip, sensorPredCWFDiag);
ipPredDayDiag = ipCompute(ip, sensorPredDayDiag);

% Simulation - diagonal
ipPredACons = ipCompute(ip, sensorPredACons);
ipPredCWFCons = ipCompute(ip, sensorPredCWFCons);
ipPredDayCons = ipCompute(ip, sensorPredDayCons);

% Visualize
ipWindow(ipAR); ipWindow(ipPredA); ipWindow(ipPredADiag); ipWindow(ipPredACons);
ipWindow(ipCWFR); ipWindow(ipPredCWF); ipWindow(ipPredCWFDiag); ipWindow(ipPredCWFCons);
ipWindow(ipDayR); ipWindow(ipPredDay); ipWindow(ipPredDayDiag); ipWindow(ipPredDayCons);
%}
%% END