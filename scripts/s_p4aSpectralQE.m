% s_p4aSpectralQE
% Estimate spectral QE of pixel 4a 
%% init
ieInit;

%% Load reflectance of mcc
mccName = 'MiniatureMacbethChart';
wave = 400:10:700;
patchSizePixels = 32;
scene = sceneCreate('macbeth', patchSizePixels, wave,...
                        mccName);
% In isetcalibrate/data/mcc
lightName = '20201023-illA-Average.mat'; % Tungsten (A)
preserveMean = false;
sceneA = sceneAdjustIlluminant(scene, lightName, preserveMean);
sceneA = sceneSet(sceneA, 'name', 'Illuminant A');

lightName = '20201023-illCWF-Average.mat'; % CWF
sceneCWF = sceneAdjustIlluminant(scene, lightName, preserveMean);
sceneCWF = sceneSet(sceneCWF, 'name', 'Illuminant CWF');

lightName = '20201023-illDay-Average.mat'; % Daylight
sceneDay = sceneAdjustIlluminant(scene, lightName, preserveMean);
sceneDay = sceneSet(sceneDay, 'name', 'Illuminant Day');
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
%% Create sensor
% Path to where the images are stored
dataDir = fullfile(cboxRootPath, 'local', 'color_calibration', ...
                    'DNG-mcc-measurement1');

%%% Create sensor for illuminant A %%%
imgAName = fullfile(dataDir, 'DNG-Illuminant-A', 'IMG_20201024_123128.dng');
% Read the rectangle of the image
thisRect = [1860  2010  350  255]; %col, row, width, height
[sensorA, infoA] = sensorDNGRead(imgAName, 'crop', thisRect);
sensorA = sensorSet(sensorA, 'name', 'RealImg-IlluA');

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
[sensorCWF, infoCWF] = sensorDNGRead(imgCWFName, 'crop', thisRect);
sensorCWF = sensorSet(sensorCWF, 'name', 'RealImg-IlluCWF');
% cpCWF = chartCornerpoints(camera_cwf);   % Select corners
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
[sensorDay, infoDay] = sensorDNGRead(imgDayName,'crop',thisRect);
% cpDay = chartCornerpoints(camera_day);   % Select corners
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
fullData = true;             % Return only the mean

%%% Illuminant A %%%
nPixelsA = round(pSizeA(1)/4);  % Choose a fraction of the pixels in the patch
dValuesA = chartRectsData(sensorA,mLocsA,nPixelsA,fullData,'dv'); %returns digital values
rgbMeanA = zeros(24,3);
rgbStdA = rgbMeanA;
for ii = 1:24
    % Correct the values for the black level
    theseValues = (dValuesA{ii}- infoA.BlackLevel(1));
    rgbMeanA(ii,:) = nanmean(theseValues);
    rgbStdA(ii,:)  = nanstd(theseValues);
end


%%% Illuminant CWF %%%
nPixelsCWF = round(pSizeCWF(1)/4);  % Choose a fraction of the pixels in the patch
dValuesCWF = chartRectsData(sensorCWF,mLocsCWF,nPixelsCWF,fullData,'dv'); %returns digital values
rgbMeanCWF = zeros(24,3);
rgbStdCWF = rgbMeanCWF;
for ii = 1:24
    % Correct the values for the black level
    theseValues = (dValuesCWF{ii}- infoCWF.BlackLevel(1));
    rgbMeanCWF(ii,:) = nanmean(theseValues);
    rgbStdCWF(ii,:)  = nanstd(theseValues);
end

%%% Illuminant Day %%%
nPixelsDay = round(pSizeDay(1)/4);  % Choose a fraction of the pixels in the patch
dValuesDay = chartRectsData(sensorDay,mLocsDay,nPixelsDay,fullData,'dv'); %returns digital values
rgbMeanDay = zeros(24,3);
rgbStdDay = rgbMeanDay;
for ii = 1:24
    % Correct the values for the black level
    theseValues = (dValuesDay{ii}- infoDay.BlackLevel(1));
    rgbMeanDay(ii,:) = nanmean(theseValues);
    rgbStdDay(ii,:)  = nanstd(theseValues);
end

%% 
