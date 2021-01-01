% s_p4aSpectralQE
% Estimate spectral QE of pixel 4a 
%% init
ieInit;

%% PART I: Load the real sensor image
%% Create sensor
% Path to where the images are stored
dataDir = fullfile(cboxRootPath, 'local', 'color_calibration', ...
                    'DNG-mcc-measurement1');

%%% Create sensor for illuminant A %%%
imgAName = fullfile(dataDir, 'DNG-Illuminant-A', 'IMG_20201024_123128.dng');
% Read the rectangle of the image
thisRect = [1860  2010  350  255]; %col, row, width, height
[sensorAR, infoA] = sensorDNGRead(imgAName, 'crop', thisRect); % R for real
sensorAR = sensorSet(sensorAR, 'name', 'RealImg-IlluA');

% Select the corner points
% cpA = chartCornerpoints(sensorA);   % Select corners
% {
cpA = [
    38   222
    316   224
    314    41
    40    40];
%}
blackBorder = true;  % Estimate rectangles, applies for illuminant A, CWF and Day
[rectsA, mLocsA, pSizeA] = chartRectangles(cpA,4,6,0.5,blackBorder);
%{
sensorWindow(sensorA);
chartRectsDraw(sensorA,rectsA);  % Visualize the rectangles
%}

%%% Create sensor for illuminant CWF %%%
imgCWFName = fullfile(dataDir, 'DNG-Illuminant-CWF',...
                        'IMG_20201024_122900.dng');
% Read the rectangle of the image
thisRect = [1860  2010  370  290]; %col, row, width, height
[sensorCWFR, infoCWF] = sensorDNGRead(imgCWFName, 'crop', thisRect);
sensorCWFR = sensorSet(sensorCWFR, 'name', 'RealImg-IlluCWF');
% cpCWF = chartCornerpoints(sensorCWFR);   % Select corners
% cpCWF
% {
cpCWF = [
    62   218
   337   222
   337    38
    63    37];
%}
[rectsCWF, mLocsCWF, pSizeCWF] = chartRectangles(cpCWF,4,6,0.5,blackBorder);
%{
sensorWindow(sensorCWF);
chartRectsDraw(sensorCWF,rectsCWF);  % Visualize the rectangles
%}

%%% Create sensor for illuminant Day %%%
imgDayName = fullfile(dataDir, 'DNG-Illuminant-Day',...
                        'IMG_20201024_122631.dng');
% Read the rectangle of the image
thisRect = [1860  2010  370  290]; %col, row, width, height
[sensorDayR, infoDay] = sensorDNGRead(imgDayName,'crop',thisRect);
% cpDay = chartCornerpoints(sensorDayR);   % Select corners
% cpDay
% {
cpDay = [
    73   218
   344   222
   344    39
    73    36];
%}
[rectsDay, mLocsDay, pSizeDay] = chartRectangles(cpDay,4,6,0.5,blackBorder);
%{
sensorWindow(sensorDay);
chartRectsDraw(sensorDay,rectsDay);  % Visualize the rectangles
%}

%% Correct RGB values

%%% Illuminant A %%%
nPixelsA = round(pSizeA(1)/4);  % Choose a fraction of the pixels in the patch
rgbMeanAR = chartRectsData(sensorAR,mLocsA,nPixelsA,false,'dv'); %returns digital values
rgbMeanAR = rgbMeanAR - infoA.BlackLevel(1);

%%% Illuminant CWF %%%
nPixelsCWF = round(pSizeCWF(1)/4);  % Choose a fraction of the pixels in the patch
rgbMeanCWFR = chartRectsData(sensorCWFR,mLocsCWF,nPixelsCWF,false,'dv'); %returns digital values
rgbMeanCWFR = rgbMeanCWFR - infoCWF.BlackLevel(1);


%%% Illuminant Day %%%
nPixelsDay = round(pSizeDay(1)/4);  % Choose a fraction of the pixels in the patch
rgbMeanDayR = chartRectsData(sensorDayR,mLocsDay,nPixelsDay,false,'dv'); %returns digital values
rgbMeanDayR = rgbMeanDayR - infoCWF.BlackLevel(1);


%% RGB value of MCC under illuminant A, CWF and Day. 
% Save mean RGB values at some point?
rgbMeanR = [rgbMeanAR; rgbMeanCWFR;rgbMeanDayR];

%% PART II: Compute simulated sensor
%% Load reflectance of mcc
mccName = 'MiniatureMacbethChart';
wave = 390:10:710;
patchSizePixels = 32;
scene = sceneCreate('macbeth', patchSizePixels, wave,...
                        mccName);
% In isetcalibrate/data/mcc
lightName = '20201023-illA-Average.mat'; % Tungsten (A)
preserveMean = false;
sceneA = sceneAdjustIlluminant(scene, lightName, preserveMean);
sceneA = sceneSet(sceneA, 'name', 'Illuminant A-R');

lightName = '20201023-illCWF-Average.mat'; % CWF
sceneCWF = sceneAdjustIlluminant(scene, lightName, preserveMean);
sceneCWF = sceneSet(sceneCWF, 'name', 'Illuminant CWF-R');

lightName = '20201023-illDay-Average.mat'; % Daylight
sceneDay = sceneAdjustIlluminant(scene, lightName, preserveMean);
sceneDay = sceneSet(sceneDay, 'name', 'Illuminant Day-R');
%{
    sceneWindow(sceneA);
    sceneWindow(sceneCWF);
    sceneWindow(sceneDay);
%}

%% OI 
oi = oiCreate;
oiA = oiCompute(oi, sceneA);
oiCWF = oiCompute(oi, sceneCWF);
oiDay = oiCompute(oi, sceneDay);

%{
    oiWindow(oiA);
    oiWindow(oiCWF);
    oiWindow(oiDay);
%}

%% Compute sensor data 
sensorAS   = sensorAR; % S for simulation
sensorCWFS = sensorCWFR; 
sensorDayS = sensorDayR;

% Set sensor to be noise free
sensorAS   = sensorSet(sensorAS, 'noise flag', 0);
sensorCWFS = sensorSet(sensorCWFS, 'noise flag', 0);
sensorDayS = sensorSet(sensorDayS, 'noise flag', 0);

% Set names
sensorAS   = sensorSet(sensorAS, 'name', 'Illuminant A-S');
sensorCWFS = sensorSet(sensorCWFS, 'name', 'Illuminant CWF-S');
sensorDayS = sensorSet(sensorDayS, 'name', 'Illuminant Day-S');

% Set sensor size to fov
sensorAS   = sensorSetSizeToFOV(sensorAS, oiGet(oiA, 'fov'), oiA);
sensorCWFS = sensorSetSizeToFOV(sensorCWFS, oiGet(oiCWF, 'fov'), oiCWF);
sensorDayS = sensorSetSizeToFOV(sensorDayS, oiGet(oiDay, 'fov'), oiDay);

% Compute
sensorAS   = sensorCompute(sensorAS, oiA);
sensorCWFS = sensorCompute(sensorCWFS, oiCWF);
sensorDayS = sensorCompute(sensorDayS, oiDay);
%{
sensorWindow(sensorAS);
sensorWindow(sensorCWFS);
sensorWindow(sensorDayS);
%}

%% Get simulated RGB data

%%% Get RGB values for Illuminant A
% cpAS = chartCornerpoints(sensorAS);   % Select corners
% {
cpAS =[
    63   385
   546   382
   546    59
    62    60 ];
%}
[rectsAS, mLocsAS, pSizeAS] = chartRectangles(cpAS,4,6,0.5,blackBorder);
%{
sensorWindow(sensorAS);
chartRectsDraw(sensorAS,rectsAS);  % Visualize the rectangles
%}

%%% Get RGB values for Illuminant CWF
% cpCWFS = chartCornerpoints(sensorCWFS);   % Select corners
% {
cpCWFS = [
    62   403
   546   404
   549    73
    62    77];
%}
[rectsCWFS, mLocsCWFS, pSizeCWFS] = chartRectangles(cpCWFS,4,6,0.5,blackBorder);
%{
sensorWindow(sensorCWFS);
chartRectsDraw(sensorCWFS,rectsCWFS);  % Visualize the rectangles
%}

%%% Get RGB values for Illuminant Day
% cpCWFS = chartCornerpoints(sensorCWFS);   % Select corners
% {
cpDayS = [
    62   403
   546   404
   549    73
    62    77];
%}
[rectsDayS, mLocsDayS, pSizeDayS] = chartRectangles(cpDayS,4,6,0.5,blackBorder);
%{
sensorWindow(sensorDayS);
chartRectsDraw(sensorDayS,rectsDayS);  % Visualize the rectangles
%}


%% Extract simulated rgb values

%%% Illuminant A %%%
nPixelsAS = round(pSizeAS(1)/4);  % Choose a fraction of the pixels in the patch
rgbMeanAS = chartRectsData(sensorAS,mLocsAS,nPixelsAS,false,'dv'); %returns digital values
rgbMeanAS = rgbMeanAS - infoA.BlackLevel(1);


%%% Illuminant CWF %%%
nPixelsCWFS = round(pSizeCWFS(1)/4);  % Choose a fraction of the pixels in the patch
rgbMeanCWFS = chartRectsData(sensorCWFS,mLocsCWFS,nPixelsCWFS,false,'dv'); %returns digital values
rgbMeanCWFS = rgbMeanCWFS - infoCWF.BlackLevel(1);


%%% Illuminant Day %%%
nPixelsDayS = round(pSizeDayS(1)/4);  % Choose a fraction of the pixels in the patch
rgbMeanDayS = chartRectsData(sensorDayS,mLocsDayS,nPixelsDayS,false,'dv'); %returns digital values
rgbMeanDayS = rgbMeanDayS - infoDay.BlackLevel(1);

%%
rgbMeanS = [rgbMeanAS; rgbMeanCWFS; rgbMeanDayS];

% {
ieNewGraphWin;
plot(rgbMeanS, rgbMeanR, 'o');
identityLine;
%}
%% First effort
L = pinv(rgbMeanS) * rgbMeanR;
pred = rgbMeanS * L;
% Plot the predicted color filter
sensorT = sensorAS;
cfS = sensorGet(sensorT, 'color filters');
cfPred = cfS * L;
%{
sensorT = sensorSet(sensorT, 'color filters', cfPred);
sensorPlot(sensorT, 'color filters');
%}
%{
% Plot the prediction
ieNewGraphWin;
plot(pred, rgbMeanR, 'o')
identityLine;

% Check each block
colorList = ['r', 'g', 'b'];
ieNewGraphWin;
for ii=1:24
    subplot(6, 4, ii);
    hold all
    for jj=1:3
        plot(pred(ii, jj), rgbMeanR(ii, jj), strcat(colorList(jj), 'o'));
    end
    title(sprintf('Illuminant A-patch: %d', ii))
    xlabel('prediction')
    ylabel('measured')
    identityLine;
    axis square
    axis equal    
end

ieNewGraphWin;
for ii=25:48
    subplot(6, 4, ii-24);
    hold all
    for jj=1:3
        plot(pred(ii, jj), rgbMeanR(ii, jj), strcat(colorList(jj), 'x'));
    end
    title(sprintf('Illuminant CWF-patch: %d', ii-24))
    xlabel('prediction')
    ylabel('measured')
    identityLine;
    axis square
    axis equal    
end

ieNewGraphWin;
for ii=49:72
    subplot(6, 4, ii-48);
    hold all
    for jj=1:3
        plot(pred(ii, jj), rgbMeanR(ii, jj), strcat(colorList(jj), '*'));
    end
    title(sprintf('Illuminant Day-patch: %d', ii-48))
    xlabel('prediction')
    ylabel('measured')
    identityLine;
    axis square
    axis equal    
end


%}

%% Diagonal transformation
diagL = eye(3);
for ii=1:3
    diagL(ii, ii) = rgbMeanS(:, ii) \ rgbMeanR(:, ii);
end
disp(diagL)
predDiag = rgbMeanS * diagL;
% Plot the predicted color filter
sensorT = sensorAS;
cfS = sensorGet(sensorT, 'color filters');
cfPredDiag = cfS * diagL;
%{
sensorT = sensorSet(sensorT, 'color filters', cfPredDiag);
sensorPlot(sensorT, 'color filters');
%}
%{
% Plot the prediction
ieNewGraphWin;
plot(rgbMeanS * diagL, rgbMeanR, 'o')
identityLine;

% Check each block
colorList = ['r', 'g', 'b'];
ieNewGraphWin;
for ii=1:24
    subplot(6, 4, ii);
    hold all
    for jj=1:3
        plot(predDiag(ii, jj), rgbMeanR(ii, jj), strcat(colorList(jj), 'o'));
    end
    title(sprintf('Illuminant A-patch: %d', ii))
    xlabel('prediction')
    ylabel('measured')
    identityLine;
    axis square
    axis equal
end

ieNewGraphWin;
for ii=25:48
    subplot(6, 4, ii-24);
    hold all
    for jj=1:3
        plot(predDiag(ii, jj), rgbMeanR(ii, jj), strcat(colorList(jj), 'x'));
    end
    title(sprintf('Illuminant CWF-patch: %d', ii-24))
    xlabel('prediction')
    ylabel('measured')
    identityLine;
    axis square
    axis equal
end

ieNewGraphWin;
for ii=49:72
    subplot(6, 4, ii-48);
    hold all
    for jj=1:3
        plot(predDiag(ii, jj), rgbMeanR(ii, jj), strcat(colorList(jj), '*'));
    end
    title(sprintf('Illuminant Day-patch: %d', ii-48))
    xlabel('prediction')
    ylabel('measured')
    identityLine;
    axis square
    axis equal
end


%}

%% Constrained lsq equation
%{
argmin_x = 0.5|Cx-d|^2 st Ax <= b
%}
C = rgbMeanS; d = rgbMeanR;
A = -cfS; b = zeros(size(A, 1), 1);
lb = zeros(size(A, 2), 1);
x1 = lsqlin(C, d(:, 1), A, b, [], [], lb);
x2 = lsqlin(C, d(:, 2), A, b, [], [], lb);
x3 = lsqlin(C, d(:, 3), A, b, [], [], lb);

consL = [x1 x2 x3];
predCons = rgbMeanS * consL;
% Plot the predicted color filter
sensorT = sensorAS;
cfS = sensorGet(sensorT, 'color filters');
cfPredCons = cfS * consL;
%{
sensorT = sensorSet(sensorT, 'color filters', cfPredCons);
sensorPlot(sensorT, 'color filters');
%}
%{
% Plot the prediction
ieNewGraphWin;
plot(predCons, rgbMeanR, 'o')
identityLine;

% Check each block
colorList = ['r', 'g', 'b'];
ieNewGraphWin;
for ii=1:24
    subplot(6, 4, ii);
    hold all
    for jj=1:3
        plot(predCons(ii, jj), rgbMeanR(ii, jj), strcat(colorList(jj), 'o'));
    end
    title(sprintf('Illuminant A-patch: %d', ii))
    xlabel('prediction')
    ylabel('measured')
    identityLine;
    axis square
    axis equal
end

ieNewGraphWin;
for ii=25:48
    subplot(6, 4, ii-24);
    hold all
    for jj=1:3
        plot(predCons(ii, jj), rgbMeanR(ii, jj), strcat(colorList(jj), 'x'));
    end
    title(sprintf('Illuminant CWF-patch: %d', ii-24))
    xlabel('prediction')
    ylabel('measured')
    identityLine;
    axis square
    axis equal
end

ieNewGraphWin;
for ii=49:72
    subplot(6, 4, ii-48);
    hold all
    for jj=1:3
        plot(predCons(ii, jj), rgbMeanR(ii, jj), strcat(colorList(jj), '*'));
    end
    title(sprintf('Illuminant Day-patch: %d', ii-48))
    xlabel('prediction')
    ylabel('measured')
    identityLine;
    axis square
    axis equal
end


%}
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
% {
%% Compare ip
ip = ipCreate;
ip = ipSet(ip, 'render demosaic only', true);

% Real img
ipAR = ipCompute(ip, sensorAR);
ipCWFR = ipCompute(ip, sensorCWFR);
ipDayR = ipCompute(ip, sensorDayR);
ipAR = ipSet(ipAR, 'name', 'Illuminant A-real');
ipCWFR = ipSet(ipCWFR, 'name', 'Illuminant CWF-real');
ipDayR = ipSet(ipDayR, 'name', 'Illuminant Day-real');

% Simulation - all entry
ipPredA = ipCompute(ip, sensorPredA);
ipPredCWF = ipCompute(ip, sensorPredCWF);
ipPredDay = ipCompute(ip, sensorPredDay);
ipPredA = ipSet(ipPredA, 'name', 'Illuminant A-pred');
ipPredCWF = ipSet(ipPredCWF, 'name', 'Illuminant CWF-pred');
ipPredDay = ipSet(ipPredDay, 'name', 'Illuminant Day-pred');

% Simulation - diagonal
ipPredADiag = ipCompute(ip, sensorPredADiag);
ipPredCWFDiag = ipCompute(ip, sensorPredCWFDiag);
ipPredDayDiag = ipCompute(ip, sensorPredDayDiag);
ipPredADiag = ipSet(ipPredADiag, 'name', 'Illuminant A-pred-diag');
ipPredCWFDiag = ipSet(ipPredCWFDiag, 'name', 'Illuminant CWF-pred-diag');
ipPredDayDiag = ipSet(ipPredDayDiag, 'name', 'Illuminant Day-pred-diag');

% Simulation - diagonal
ipPredACons = ipCompute(ip, sensorPredACons);
ipPredCWFCons = ipCompute(ip, sensorPredCWFCons);
ipPredDayCons = ipCompute(ip, sensorPredDayCons);
ipPredACons = ipSet(ipPredACons, 'name', 'Illuminant A-pred-cons');
ipPredCWFCons = ipSet(ipPredCWFCons, 'name', 'Illuminant CWF-pred-cons');
ipPredDayCons = ipSet(ipPredDayCons, 'name', 'Illuminant Day-pred-cons');


% Visualize
ipWindow(ipAR); ipWindow(ipPredA); ipWindow(ipPredADiag); ipWindow(ipPredACons);
ipWindow(ipCWFR); ipWindow(ipPredCWF); ipWindow(ipPredCWFDiag); ipWindow(ipPredCWFCons);
ipWindow(ipDayR); ipWindow(ipPredDay); ipWindow(ipPredDayDiag); ipWindow(ipPredDayCons);
%}
%%END