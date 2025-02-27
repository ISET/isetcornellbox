% 

%%
ieInit;

%% Initialization
tmp = load('p4aLensVignet_dc_p55_pos1.mat', 'pixel4aLensVignetSlope');
vignetting = tmp.pixel4aLensVignetSlope;

%
qeDir = fullfile(cboxRootPath, 'local', 'measurement', 'QEcalibration',...
                               'QE', 'p55');
%% First check the accuracy in the middle center with everything on 
% Read in mean meas
illuminantType = {'A', 'day', 'cwf'};
pos = {'midcenter'};
cornerPointsMeas = {[1858 1408 2229 1656],...
                    [1858 1408 2229 1656],...
                    [1858 1408 2229 1656]};
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
% Get the black level
blkLvl = sensorGet(sensorSimCor, 'black level');
[~, rgbMeanACor, ~] = cbMccSensorSim(oiA, sensorSimCor, cornerPointsSim);
[~, rgbMeanDayCor, ~] = cbMccSensorSim(oiDay, sensorSimCor, cornerPointsSim);
[~, rgbMeanCWFCor, ~] = cbMccSensorSim(oiCWF, sensorSimCor, cornerPointsSim);

rgbMeanSimCorMidCenter = [rgbMeanACor;rgbMeanDayCor;rgbMeanCWFCor];
% Make sure the simulated sensor data match the measurement
ieNewGraphWin; 
hold all;
plot(rgbMeanMeasMidCenter(:,1) + blkLvl, rgbMeanSimCorMidCenter(:,1)+ blkLvl,'ro', 'MarkerSize', 5); 
plot(rgbMeanMeasMidCenter(:,2)+ blkLvl, rgbMeanSimCorMidCenter(:,2)+ blkLvl,'go', 'MarkerSize', 5);
plot(rgbMeanMeasMidCenter(:,3)+ blkLvl, rgbMeanSimCorMidCenter(:,3)+ blkLvl,'bo', 'MarkerSize', 5);
axis square; box on;
identityLine;
xlabel('Measurement (dv)'); ylabel('Simulation (dv)');
%{
pct = mean(abs(rgbMeanSimCorMidCenter(:) - rgbMeanMeasMidCenter(:))./rgbMeanMeasMidCenter(:));

% Calculate standard deviation
rgbMeanMeasLowerIdx = find(rgbMeanMeasMidCenter(:) <= 400);
rgbMeanMeasHigherIdx = find(rgbMeanMeasMidCenter(:) > 400);
stdLower = std(rgbMeanSimCorMidCenter(rgbMeanMeasLowerIdx) -...
                rgbMeanMeasMidCenter(rgbMeanMeasLowerIdx));
stdHigher = std(rgbMeanSimCorMidCenter(rgbMeanMeasHigherIdx) -...
                rgbMeanMeasMidCenter(rgbMeanMeasHigherIdx));

pctLower = mean(abs(rgbMeanSimCorMidCenter(rgbMeanMeasLowerIdx) -...
                rgbMeanMeasMidCenter(rgbMeanMeasLowerIdx))./rgbMeanMeasMidCenter(rgbMeanMeasLowerIdx)) * 100;

pctHigher = mean(abs(rgbMeanSimCorMidCenter(rgbMeanMeasHigherIdx) -...
                rgbMeanMeasMidCenter(rgbMeanMeasHigherIdx))./rgbMeanMeasMidCenter(rgbMeanMeasHigherIdx)) * 100;

ieNewGraphWin;
hold all;
curIdx = 11;
idx = curIdx;
plot(rgbMeanMeasMidCenter(idx,1), rgbMeanSimCorMidCenter(idx,1),'ro');
plot(rgbMeanMeasMidCenter(idx,2), rgbMeanSimCorMidCenter(idx,2),'go');
plot(rgbMeanMeasMidCenter(idx,3), rgbMeanSimCorMidCenter(idx,3),'bo');
axis square; identityLine;
%}

% Now compute the sensor response without color filter correction
sensorSimNoCor = cbDNGRead(imgNames{3}, 'demosaic', false, 'transcolorfilter', false);
[~, rgbMeanANoCor, ~] = cbMccSensorSim(oiA, sensorSimNoCor, cornerPointsSim);
[~, rgbMeanDayNoCor, ~] = cbMccSensorSim(oiDay, sensorSimNoCor, cornerPointsSim);
[~, rgbMeanCWFNoCor, ~] = cbMccSensorSim(oiCWF, sensorSimNoCor, cornerPointsSim);

rgbMeanSimNoCorMidCenter = [rgbMeanANoCor;rgbMeanDayNoCor;rgbMeanCWFNoCor];
% Make sure the simulated sensor data w/o correction DOES NOT match the measurement
ieNewGraphWin; 
hold all;
plot(rgbMeanMeasMidCenter(:,1) + blkLvl, rgbMeanSimNoCorMidCenter(:,1)+ blkLvl,'ro','MarkerSize', 5); identityLine;
plot(rgbMeanMeasMidCenter(:,2)+ blkLvl, rgbMeanSimNoCorMidCenter(:,2)+ blkLvl,'go','MarkerSize', 5); identityLine;
plot(rgbMeanMeasMidCenter(:,3)+ blkLvl, rgbMeanSimNoCorMidCenter(:,3)+ blkLvl,'bo','MarkerSize', 5); identityLine;
axis square; box on;
identityLine;
xlabel('Measurement (dv)'); ylabel('Simulation (dv)');
%{
pctBefore = mean(abs(rgbMeanSimNoCorMidCenter(:) - rgbMeanMeasMidCenter(:))./rgbMeanMeasMidCenter(:));
%}
%% Get other 8 positions
%{
topleft: [1009 474 1434 766]
topcenter: [1884 511 2300 788]
topright: [3086 572 3479 833]

midleft: [970 1410 1333 1656]
midcenter: [1858 1408 2229 1656]
midright: [3165 1410 3553 1664]

botleft: [1117 2117 1460 2345]
botcenter: [1831 2113 2186 2351]
botright: [3142 2148 3519 2395]
%}
illuminantType = {'A', 'cwf', 'day'};
pos = {'topleft', 'topcenter', 'topright',...
       'midleft', 'midright',...
       'botleft', 'botcenter', 'botright'};
cornerPointsMeas = {[1009 474 1434 766],...
                    [1884 511 2300 788],...
                    [3086 572 3479 833],...
                    [970 1410 1333 1656],...
                    [3165 1410 3553 1664],...
                    [1117 2117 1460 2345],...
                    [1831 2113 2186 2351],...
                    [3142 2148 3519 2395],...
                    [1009 474 1434 766],...
                    [1884 511 2300 788],...
                    [3086 572 3479 833],...
                    [970 1410 1333 1656],...
                    [3165 1410 3553 1664],...
                    [1117 2117 1460 2345],...
                    [1831 2113 2186 2351],...
                    [3142 2148 3519 2395],...
                    [1009 474 1434 766],...
                    [1884 511 2300 788],...
                    [3086 572 3479 833],...
                    [970 1410 1333 1656],...
                    [3165 1410 3553 1664],...
                    [1117 2117 1460 2345],...
                    [1831 2113 2186 2351],...
                    [3142 2148 3519 2395]};
                
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
cornerPointsSim = [147 115 1086 737];
[~, ~, ~, rgbMeanMeas8PosNoVig] = cbQEAnalysis(imgNames, illuminants,...
                        cornerPointsMeas, cornerPointsSim,...
                        [], 'method', 'nonnegative');
% ieNewGraphWin; plot(rgbMeanMeas8Pos(193:216,:), rgbMeanMeas8Pos(217:217+24-1,:),'o'); identityLine                 
% Compare it with no color corr sensor sim
tmpA = repmat(rgbMeanANoCor, [8,1]);
tmpDay = repmat(rgbMeanDayNoCor, [8,1]);
tmpCWF = repmat(rgbMeanCWFNoCor, [8, 1]);
rgbMeanSimNoCorRep = [tmpA; tmpCWF; tmpDay];
% Figure: no vignetting, color or BRDF correction
ieNewGraphWin;
hold all
plot(rgbMeanMeas8PosNoVig(:,1)+ blkLvl, rgbMeanSimNoCorRep(:,1)+ blkLvl, 'ro');
plot(rgbMeanMeas8PosNoVig(:,2)+ blkLvl, rgbMeanSimNoCorRep(:,2)+ blkLvl, 'go');
plot(rgbMeanMeas8PosNoVig(:,3)+ blkLvl, rgbMeanSimNoCorRep(:,3)+ blkLvl, 'bo');
identityLine; grid on; axis square; box on;
xlabel('Measurement (dv)'); ylabel('Simulation (dv)');

%% Step B: add color filter correction
tmpA = repmat(rgbMeanACor, [8,1]);
tmpDay = repmat(rgbMeanDayCor, [8,1]);
tmpCWF = repmat(rgbMeanCWFCor, [8, 1]);
rgbMeanSimCorRep = [tmpA; tmpCWF; tmpDay];
% Figure: color correction, no vignetting or BRDF correction
ieNewGraphWin;
hold all
plot(rgbMeanMeas8PosNoVig(:,1)+ blkLvl, rgbMeanSimCorRep(:,1)+ blkLvl, 'ro');
plot(rgbMeanMeas8PosNoVig(:,2)+ blkLvl, rgbMeanSimCorRep(:,2)+ blkLvl, 'go');
plot(rgbMeanMeas8PosNoVig(:,3)+ blkLvl, rgbMeanSimCorRep(:,3)+ blkLvl, 'bo');
identityLine; grid on; axis square; box on
xlabel('Measurement (dv)'); ylabel('Simulation (dv)');

%% Step C: add lens vignetting correction
% Add lens vignetting correction
[~, ~, ~, rgbMeanMeas8PosVig] = cbQEAnalysis(imgNames, illuminants,...
                        cornerPointsMeas, cornerPointsSim,...
                        vignetting, 'method', 'nonnegative');

% Figure: vignetting and color correction, no or BRDF correction
ieNewGraphWin;
hold all
plot(rgbMeanMeas8PosVig(:,1)+ blkLvl, rgbMeanSimCorRep(:,1)+ blkLvl, 'ro');
plot(rgbMeanMeas8PosVig(:,2)+ blkLvl, rgbMeanSimCorRep(:,2)+ blkLvl, 'go');
plot(rgbMeanMeas8PosVig(:,3)+ blkLvl, rgbMeanSimCorRep(:,3)+ blkLvl, 'bo');
identityLine; grid on; axis square; box on
xlabel('Measurement (dv)'); ylabel('Simulation (dv)');

%% Step D: add BRDF correction
posRatioMeas = fullfile(cboxRootPath, 'local', 'measurement',...
                            'Spectralradiometer', 'res', 'posRatio.mat');
load(posRatioMeas);
avgRatioA = zeros(9, 1);
avgRatioCWF = zeros(9, 1);
avgRatioDay = zeros(9, 1);
for ii=1:9    
    avgRatioA(ii) = mean(ratioA{ii}(2:end));
    avgRatioDay(ii) = mean(ratioDay{ii}(2:end));
    avgRatioCWF(ii) = mean(ratioCWF{ii}(2:end));
end

avgRatioA(5) = []; avgRatioDay(5) = []; avgRatioCWF(5) = []; 
avgRatioARep = repmat(repelem(avgRatioA,24), [1, 3]);
avgRatioDayRep = repmat(repelem(avgRatioDay,24), [1, 3]);
avgRatioCWFRep = repmat(repelem(avgRatioCWF,24), [1, 3]);
avgRatioRep = [avgRatioARep; avgRatioCWFRep; avgRatioDayRep];

rgbMeanMeas8PosVigBRDF = rgbMeanMeas8PosVig./avgRatioRep;

ieNewGraphWin;
hold all
plot(rgbMeanMeas8PosVigBRDF(:,1)+ blkLvl, rgbMeanSimCorRep(:,1)+ blkLvl, 'ro');
plot(rgbMeanMeas8PosVigBRDF(:,2)+ blkLvl, rgbMeanSimCorRep(:,2)+ blkLvl, 'go');
plot(rgbMeanMeas8PosVigBRDF(:,3)+ blkLvl, rgbMeanSimCorRep(:,3)+ blkLvl, 'bo');
identityLine; grid on; axis square; box on
xlabel('Measurement (dv)'); ylabel('Simulation (dv)');

%% Step D+: hist
edges = [60:20:1000];
%{
ieNewGraphWin;
hold all;
histogram(rgbMeanMeas8PosVig(:), edges, 'FaceColor', [0 0.4470 0.7410],...
                                    'FaceAlpha', 0.4,...
                                    'LineWidth', 3);
histogram(rgbMeanSimCorRep(:), edges, 'FaceColor', [0.8500 0.3250 0.0980],...
                                    'FaceAlpha', 0.4,...
                                    'LineWidth', 3);
grid on; box on; axis square;
xlabel('Digital values'); ylabel('Counts');
ylim([0 900]); yticks(0:300:900);
xlim([0 1000]); xticks(0:200:1000);
legend('Measured', 'Simulated');
% Save hist path
saveHistPath = fullfile(cboxRootPath, 'local', 'data', 'hist.mat');
rgbMeanMeas = rgbMeanMeas8PosVig;
rgbMeanSim = rgbMeanSimCorRep;
bins = edges;
save(saveHistPath, 'rgbMeanMeas', 'rgbMeanSim', 'bins');
%}

ieNewGraphWin;
nBins = 30; alpha = 0.5;
hMeas = histogram(rgbMeanMeas(:),edges);
hMeas.FaceColor = [0.8 0.1 0.2];
hMeas.FaceAlpha = alpha;
hMeas.EdgeColor = hMeas.FaceColor;
hMeas.EdgeAlpha = hMeas.FaceAlpha;
hold on;

hSim = histogram(rgbMeanSim(:),edges);
hSim.FaceColor = [0.1 0.3 0.7];
hSim.FaceAlpha = alpha;
hSim.EdgeColor = hSim.FaceColor;
hSim.EdgeAlpha = hSim.FaceAlpha;
grid on
xlabel('Mean value (dv)');
ylabel('Number')
lgn = legend('Measured','Simulated');
lgn.FontSize = 18;
%{
[imgH, xy, cmap] = ieHistImage([log10(rgbMeanMeas8PosVigBRDF(:)),...
                        log10(rgbMeanSimCorRep(:))],...
                'hist type','scatplot','scatmethod','voronoi',...
                'edges',[32, 32],...
                'plotflag', true);
[imgH, xy, cmap] = ieHistImage([rgbMeanMeas8PosVigBRDF(:)+ blkLvl,...
                       rgbMeanSimCorRep(:)+ blkLvl],...
                'hist type','scatplot','scatmethod','voronoi',...
                'edges',[32, 32],...
                'plotflag', true);
% cmap = cmap.^0.5;
cmap(1,:) = [0.35, 0.35, 0.35];
colormap(cmap);
ieNewGraphWin; imagesc(xy{1}, xy{2}, imgH);axis xy;colorbar;
grid on; axis square;
identityLine; grid on; axis square; box on; xlim([7.098 800]); ylim([7.098 800]);
xticks([200:200:800]);yticks([200:200:800]);

newMap = jet(512);
newMap(1,:)=[0.5, 0.5, 0.5];
colormap(newMap);
%}
%{
dataMax = max(imgH(:));
dataMin = min(imgH(imgH~=0));
centerPoint = 1;
scalingIntensity = 5;

x = 1:length(cMap); 
x = x - (centerPoint-dataMin)*length(x)/(dataMax-dataMin);
x = scalingIntensity * x/max(abs(x));

x = sign(x).* exp(abs(x));
x = x - min(x); x = x*511/max(x)+1; 
newMap = interp1(x, cMap, 1:512);
colormap(newMap);

xlabel('Measurement (dv)'); ylabel('Simulation (dv)');
%}


