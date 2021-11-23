% Note:
% This code is deprecated as it uses autofocus feature with unknown focus
% distance.

% Please check QEfactorAnalaysisP55, where the images were captured with
% focus distance of 0.55m

%%
ieInit;

%% Initialization
tmp = load('p4aLensVignet.mat', 'pixel4aLensVignetSlope');
vignetting = tmp.pixel4aLensVignetSlope;

%
qeDir = fullfile(cboxRootPath, 'local', 'measurement', 'QEcalibration',...
                               'QE');
%% First check the accuracy in the middle center with everything on 
% Read in mean meas
illuminantType = {'A', 'day', 'cwf'};
pos = {'midcenter'};
cornerPointsMeas = {[1890 1395 2233 1630],...
                    [1890 1395 2233 1630],...
                    [1890 1395 2233 1630]};
nFrames = numel(illuminantType) * numel(pos);
imgNames = cell(1, nFrames);
illuminants = cell(1, nFrames);
% Counter
cnt = 1;
for ii=1:numel(illuminantType)
    thisIllu = illuminantType{ii};
    
    curIlluDir = fullfile(qeDir, thisIllu);
    
    for jj=1:numel(pos)
        thisDngFile = dir(fullfile(curIlluDir, pos{jj}, '*.dng'));
        imgNames{cnt} = fullfile(curIlluDir, pos{jj},thisDngFile(1).name);
        illuminants{cnt} = thisIllu;
        cnt = cnt + 1;
    end
end

% Get rgb mean in mid center
rgbMeanMeasMidCenter = zeros(nFrames * 24, 3);
for ii=1:numel(imgNames)
    thisCropMeas = cornerPointsMeas{ii};
    thisIllu = illuminants{ii};
    % Get the mean rgb for this sensor
    [thisSensorMeas, thisInfo, thisRGBMeanMeas, ~] = cbMccChipsDV(imgNames{ii},...
                                                              'corner point', thisCropMeas,...
                                                              'vignetting', vignetting);
    rgbMeanMeasMidCenter((ii-1) * 24+1:ii*24,:) = thisRGBMeanMeas;
end


%% Calculate simulate signals
% Precompute the illumination scene and oi
wave = 390:10:710;
lightNameA   = 'illA-20201023.mat'; % Tungsten (A)
lightNameCWF = 'illCWF-20201023.mat'; % CWF
lightNameDay = 'illDay-20201023.mat'; % Daylight
patchSize = 32;
[sceneA, oiA] = cbMccSceneOISim('illuminant', lightNameA, 'wave', wave,...
                                'patch size', patchSize);
[sceneCWF, oiCWF] = cbMccSceneOISim('illuminant', lightNameCWF, 'wave', wave,...
                                'patch size', patchSize);       
[sceneDay, oiDay] = cbMccSceneOISim('illuminant', lightNameDay, 'wave', wave,...
                                'patch size', patchSize);
                            
cornerPointsSim = [165 160 1089 770];
sensorSimCor = cbDNGRead(imgNames{3}, 'demosaic', false);
[~, rgbMeanACor, ~] = cbMccSensorSim(oiA, sensorSimCor, cornerPointsSim);
[~, rgbMeanDayCor, ~] = cbMccSensorSim(oiDay, sensorSimCor, cornerPointsSim);
[~, rgbMeanCWFCor, ~] = cbMccSensorSim(oiCWF, sensorSimCor, cornerPointsSim);

rgbMeanSimCorMidCenter = [rgbMeanACor;rgbMeanDayCor;rgbMeanCWFCor];
% Make sure the simulated sensor data match the measurement
ieNewGraphWin; 
hold all;
plot(rgbMeanMeasMidCenter(:,1), rgbMeanSimCorMidCenter(:,1),'ro', 'MarkerSize', 5); 
plot(rgbMeanMeasMidCenter(:,2), rgbMeanSimCorMidCenter(:,2),'go', 'MarkerSize', 5);
plot(rgbMeanMeasMidCenter(:,3), rgbMeanSimCorMidCenter(:,3),'bo', 'MarkerSize', 5);
axis square; box on;
identityLine;
xlabel('Measurement (dv)'); ylabel('Simulation (dv)');

% Now compute the sensor response without color filter correction
sensorSimNoCor = cbDNGRead(imgNames{3}, 'demosaic', false, 'transcolorfilter', false);
[~, rgbMeanANoCor, ~] = cbMccSensorSim(oiA, sensorSimNoCor, cornerPointsSim);
[~, rgbMeanDayNoCor, ~] = cbMccSensorSim(oiDay, sensorSimNoCor, cornerPointsSim);
[~, rgbMeanCWFNoCor, ~] = cbMccSensorSim(oiCWF, sensorSimNoCor, cornerPointsSim);

rgbMeanSimNoCorMidCenter = [rgbMeanANoCor;rgbMeanDayNoCor;rgbMeanCWFNoCor];
% Make sure the simulated sensor data w/o correction DOES NOT match the measurement
ieNewGraphWin; 
hold all;
plot(rgbMeanMeasMidCenter(:,1), rgbMeanSimNoCorMidCenter(:,1),'ro'); identityLine;
plot(rgbMeanMeasMidCenter(:,2), rgbMeanSimNoCorMidCenter(:,2),'go'); identityLine;
plot(rgbMeanMeasMidCenter(:,3), rgbMeanSimNoCorMidCenter(:,3),'bo'); identityLine;

%% Get other 8 positions
illuminantType = {'A', 'day', 'cwf'};
pos = {'topleft', 'topcenter', 'topright',...
       'midleft', 'midright',...
       'botleft', 'botcenter', 'botright'};
cornerPointsMeas = {[900 667 1290 945],...
                    [1859 672 2244 938],...
                    [2914 640 3330 923],...
                    [905 1403 1251 1631],...
                    [2976 1376 3344 1615],...
                    [1061 2057 1392 2277],...
                    [1878 2046 2206 2263],...
                    [2772 2074 3118 2298],...
                    [900 667 1290 945],...
                    [1859 672 2244 938],...
                    [2914 640 3330 923],...
                    [905 1403 1251 1631],...
                    [2976 1376 3344 1615],...
                    [1061 2057 1392 2277],...
                    [1878 2046 2206 2263],...
                    [2772 2074 3118 2298],...
                    [900 667 1290 945],...
                    [1859 672 2244 938],...
                    [2914 640 3330 923],...
                    [905 1403 1251 1631],...
                    [2976 1376 3344 1615],...
                    [1061 2057 1392 2277],...
                    [1878 2046 2206 2263],...
                    [2772 2074 3118 2298]};
                
cornerPointsSim = [75 60 537 370];
nFrames = numel(illuminantType) * numel(pos);
imgNames = cell(1, nFrames);
illuminants = cell(1, nFrames);
% Counter
cnt = 1;
for ii=1:numel(illuminantType)
    thisIllu = illuminantType{ii};
    
    curIlluDir = fullfile(qeDir, thisIllu);
    
    for jj=1:numel(pos)
        thisDngFile = dir(fullfile(curIlluDir, pos{jj}, '*.dng'));
        imgNames{cnt} = fullfile(curIlluDir, pos{jj},thisDngFile(1).name);
        illuminants{cnt} = thisIllu;
        cnt = cnt + 1;
    end
end

%% Step A: No vigneeting, color, BRDF correction
% No lens vignetting correction
[~, ~, ~, rgbMeanMeas8PosNoVig] = cbQEAnalysis(imgNames, illuminants,...
                        cornerPointsMeas, cornerPointsSim,...
                        [], 'method', 'nonnegative');
% ieNewGraphWin; plot(rgbMeanMeas8Pos(193:216,:), rgbMeanMeas8Pos(217:217+24-1,:),'o'); identityLine                 
% Compare it with no color corr sensor sim
tmpA = repmat(rgbMeanANoCor, [8,1]);
tmpDay = repmat(rgbMeanDayNoCor, [8,1]);
tmpCWF = repmat(rgbMeanCWFNoCor, [8, 1]);
rgbMeanSimNoCorRep = [tmpA; tmpDay; tmpCWF];
% Figure: no vignetting, color or BRDF correction
ieNewGraphWin;
hold all
plot(rgbMeanMeas8PosNoVig(:,1), rgbMeanSimNoCorRep(:,1), 'ro');
plot(rgbMeanMeas8PosNoVig(:,2), rgbMeanSimNoCorRep(:,2), 'go');
plot(rgbMeanMeas8PosNoVig(:,3), rgbMeanSimNoCorRep(:,3), 'bo');
identityLine; grid on; axis square; box on;
xlabel('Measurement (dv)'); ylabel('Simulation (dv)');

%% Step B: add lens vignetting correction
% Add lens vignetting correction
[~, ~, ~, rgbMeanMeas8PosVig] = cbQEAnalysis(imgNames, illuminants,...
                        cornerPointsMeas, cornerPointsSim,...
                        vignetting, 'method', 'nonnegative');
                    
% Figure: vignetting correction, no color or BRDF correction
ieNewGraphWin;
hold all
plot(rgbMeanMeas8PosVig(:,1), rgbMeanSimNoCorRep(:,1), 'ro');
plot(rgbMeanMeas8PosVig(:,2), rgbMeanSimNoCorRep(:,2), 'go');
plot(rgbMeanMeas8PosVig(:,3), rgbMeanSimNoCorRep(:,3), 'bo');
identityLine; grid on; axis square; box on
xlabel('Measurement (dv)'); ylabel('Simulation (dv)');

%% Step C: add color filter correction
tmpA = repmat(rgbMeanACor, [8,1]);
tmpDay = repmat(rgbMeanDayCor, [8,1]);
tmpCWF = repmat(rgbMeanCWFCor, [8, 1]);
rgbMeanSimCorRep = [tmpA; tmpDay; tmpCWF];

% Figure: vignetting and color correction, no or BRDF correction
ieNewGraphWin;
hold all
plot(rgbMeanMeas8PosVig(:,1), rgbMeanSimCorRep(:,1), 'ro');
plot(rgbMeanMeas8PosVig(:,2), rgbMeanSimCorRep(:,2), 'go');
plot(rgbMeanMeas8PosVig(:,3), rgbMeanSimCorRep(:,3), 'bo');
identityLine; grid on; axis square; box on
xlabel('Measurement (dv)'); ylabel('Simulation (dv)');

%% Step D: add BRDF correction
load('posRatio.mat')

avgRatioA = zeros(9, 1);
avgRatioCWF = zeros(9, 1);
avgRatioDay = zeros(9, 1);
for ii=1:9    
    avgRatioA(ii) = mean(ratioA{ii}(:));
    avgRatioDay(ii) = mean(ratioDay{ii}(:));
    avgRatioCWF(ii) = mean(ratioCWF{ii}(:));
end

avgRatioA(5) = []; avgRatioDay(5) = []; avgRatioCWF(5) = []; 
avgRatioARep = repmat(repelem(avgRatioA,24), [1, 3]);
avgRatioDayRep = repmat(repelem(avgRatioDay,24), [1, 3]);
avgRatioCWFRep = repmat(repelem(avgRatioCWF,24), [1, 3]);
avgRatioRep = [avgRatioARep; avgRatioDayRep; avgRatioCWFRep];

rgbMeanMeas8PosVigBRDF = rgbMeanMeas8PosVig./avgRatioRep;

ieNewGraphWin;
hold all
plot(rgbMeanMeas8PosVigBRDF(:,1), rgbMeanSimCorRep(:,1), 'ro');
plot(rgbMeanMeas8PosVigBRDF(:,2), rgbMeanSimCorRep(:,2), 'go');
plot(rgbMeanMeas8PosVigBRDF(:,3), rgbMeanSimCorRep(:,3), 'bo');
identityLine; grid on; axis square; box on
xlabel('Measurement (dv)'); ylabel('Simulation (dv)');

%% Step D+: 
imgH = ieHistImage([rgbMeanMeas8PosVigBRDF(:),rgbMeanSimCorRep(:)],...
                'hist type','histcn','scatmethod','voronoi',...
                'edges',[64, 64]);
identityLine; grid on; axis square; box on;
colormap(0.4 + 0.6*gray(512));
xlabel('Measurement (dv)'); ylabel('Simulation (dv)');
