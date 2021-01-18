% s_cbMccIlluminant
% Verify different illumination 
%% Load the real sensor image
%%%%%%%%%%%%%%%%%%%%% Create sensor for illuminant A %%%%%%%%%%%%%%%%%%%%%%
imgAName = 'IMG_20201024_123128.dng';
% Read the rectangle of the image
thisRect = [1860  2010  350  255]; %col, row, width, height
[~, ~, ipA] = cbDNGRead(imgAName, 'crop', thisRect, 'demosaic', true);
ipWindow(ipA);
%%%%%%%%%%%%%%%%%%%% Create sensor for illuminant CWF %%%%%%%%%%%%%%%%%%%%%                                               
imgCWFName = 'IMG_20201024_122900.dng';
% Read the rectangle of the image
thisRect = [1860  2010  370  290]; %col, row, width, height
[~, ~, ipCWF] = cbDNGRead(imgCWFName, 'crop', thisRect, 'demosaic', true);
ipWindow(ipCWF);
%%%%%%%%%%%%%%%%%%%% Create sensor for illuminant Day %%%%%%%%%%%%%%%%%%%%%                                               
imgDayName = 'IMG_20201024_122631.dng';
% Read the rectangle of the image
thisRect = [1860  2010  370  290]; %col, row, width, height
[~, ~, ipDay] = cbDNGRead(imgDayName, 'crop', thisRect, 'demosaic', true);
ipWindow(ipDay);
%%%%%%%%%%%%%%%%%%%% Create sensor for lamp in cornell box %%%%%%%%%%%%%%%%
imgCBName = 'IMG_20201212_112601_1.dng'; %% mcc image
% Read crop of the DNG file
thisRect = [1800 1788 580 370]; %col, row, width, height
[~, ~, ipCB] = cbDNGRead(imgCBName, 'crop', thisRect, 'demosaic', true);
ipWindow(ipCB);
%% Plot SPDs of the light
wave = 400:10:700;
% In isetcalibrate/data/mcc
lightNameA   = '20201023-illA-Average.mat'; % Tungsten (A)
lightNameCWF = '20201023-illCWF-Average.mat'; % CWF
lightNameDay = '20201023-illDay-Average.mat'; % Daylight
lightNameCB = 'cbox-lights-1.mat'; % Cornell Box light
illuA = ieReadSpectra(lightNameA, wave);
illuCWF = ieReadSpectra(lightNameCWF, wave);
illuDay = ieReadSpectra(lightNameDay, wave);
illuCB = ieReadSpectra(lightNameCB, wave);
%%
% Illuminant A
ieNewGraphWin;
h = plot(wave, illuA, 'k');
title('Illuminant A');
xlabel('Wavelength (nm)'); ylabel('Radiance (watts/sr/nm/m^2)')
set(gca, 'FontSize', 20); grid on; set(h, 'linewidth', 3);
% Illuminant CWF
ieNewGraphWin;
h = plot(wave, illuCWF, 'k');
title('Illuminant CWF');
xlabel('Wavelength (nm)'); ylabel('Radiance (watts/sr/nm/m^2)')
set(gca, 'FontSize', 20); grid on; set(h, 'linewidth', 3);
% Illuminant Daylight
ieNewGraphWin;
h = plot(wave, illuDay, 'k');
title('Illuminant Day');
xlabel('Wavelength (nm)'); ylabel('Radiance (watts/sr/nm/m^2)')
set(gca, 'FontSize', 20); grid on; set(h, 'linewidth', 3);
% Illuminant CB
ieNewGraphWin;
h = plot(wave, illuCB, 'k');
title('Illuminant Cornell Box');
xlabel('Wavelength (nm)'); ylabel('Radiance (watts/sr/nm/m^2)')
set(gca, 'FontSize', 20); grid on; set(h, 'linewidth', 3);

%% Compare illuminant A and CB
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
imgCBName = 'IMG_20201212_112601_1.dng'; %% mcc image
% sensorMcc = sensorDNGRead(imgName1);
% Read crop of the DNG file
thisRect = [1844 1808 500 350]; %col, row, width, height
% Select the corner points: bottom left, bottom right, top right, top left
% cpR = chartCornerpoints(sensorMcc);   % Select corners
cpR = [14 332; 489 332; 484 12; 12 13];
% Read DNG files and other info
[sensorMcc, infoR, rgbMeanCBR, roisR] = cbMccChipsDV(imgCBName,...
                                                    'corner point', cpR,...
                                                    'crop', thisRect);
%{
sensorWindow(sensorMcc);
chartRectsDraw(sensorMcc,roisR);  % Visualize the rectangles
%}  
%%


