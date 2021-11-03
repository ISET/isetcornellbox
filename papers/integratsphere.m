%{
(1) Load frames with different exposure time
%}

%%
ieInit;

%% initialization
% exposures = [60, 30, 20, 15, 10]; % For dc
exposures = [30, 20, 15, 10, 5];
nFrames = 10;
nExp = numel(exposures);
intSphereDir = fullfile(cboxRootPath, 'local', 'measurement',...
                                      'integratingsphere', 'ac');

sensorImgs = cell(nExp, nFrames);

for ii = 1:nExp
    thisExpDir = fullfile(intSphereDir, num2str(exposures(ii)));
    thisExpDngs = dir(fullfile(thisExpDir, '*.dng'));
    for jj = 1:nFrames    
        [sensor, info] = sensorDNGRead(fullfile(thisExpDir, thisExpDngs(jj).name));
        sensorImgs{ii, jj} = single(sensorGet(sensor, 'dv'));
    end
end


%%
meanSensorImgs = average2DCell(sensorImgs, 2);
meanSensorImgsR = cell(1, nExp);
meanSensorImgsG1 = cell(1, nExp);
meanSensorImgsG2 = cell(1, nExp);
meanSensorImgsB = cell(1, nExp);

for ii=1:nExp
    meanSensorImgsR{ii} = meanSensorImgs{ii}(2:2:end, 2:2:end);
    meanSensorImgsG1{ii} = meanSensorImgs{ii}(1:2:end, 2:2:end);
    meanSensorImgsG2{ii} = meanSensorImgs{ii}(2:2:end, 1:2:end);
    meanSensorImgsB{ii} = meanSensorImgs{ii}(1:2:end, 1:2:end);
end
%{
meanAllArea = zeros(1, nExp);
ieNewGraphWin;
hold all
for ii = 1:nExp
    meanAllArea(ii) = mean(meanSensorImgs{ii}(:));
    plot(1/exposures(ii), meanAllArea(ii), 'o')
end
p = polyfit(1./exposures, meanAllArea, 1);
%}



%{
pos = [700, 800];
thisDVG1 = zeros(1, nExp);
for ii = 1:nExp
    thisDVG1(ii) = meanSensorImgsG1{ii}(pos(2), pos(1));
end
ieNewGraphWin;
plot(1./exposures, thisDVG1, 'o'); hold on

p = polyfit(1./exposures, thisDVG1, 1);


thisOffset = offsetMapG1(pos(2), pos(1));
thisSlope = slopeMapG1(pos(2), pos(1));
expT = linspace(0, 1/exposures(end), 10);
plot(expT, thisOffset+thisSlope*(expT));

vignett = slopeMapG1/max(slopeMapG1(:));
thisVignett = vignett(pos(2), pos(1));
thisOffset/thisVignett

tmp = offsetMapG1./vignett;
ieNewGraphWin; imagesc(tmp);
tmp(pos(2), pos(1))


%
ieNewGraphWin; imagesc(meanSensorImgsG1{1} - meanSensorImgsG1{2});
%}

%% Slide for 5x5 windows and calculate mean digital values
wSz = 5;
kernel = ones(wSz)/wSz^2;
meanLocalWindowR = cell(1, nExp);
meanLocalWindowG1 = cell(1, nExp);
meanLocalWindowG2 = cell(1, nExp);
meanLocalWindowB = cell(1, nExp);

sSz = size(meanSensorImgsR{1});
for ii=1:nExp
    meanLocalWindowR{ii} = conv2(meanSensorImgsR{ii}, kernel, 'valid');
    meanLocalWindowG1{ii} = conv2(meanSensorImgsG1{ii}, kernel, 'valid');
    meanLocalWindowG2{ii} = conv2(meanSensorImgsG2{ii}, kernel, 'valid');
    meanLocalWindowB{ii} = conv2(meanSensorImgsB{ii}, kernel, 'valid');
end

%% Apply linear fitting for everypixel
[offsetMapR, slopeMapR] = cbIntSphereAnalyze(meanLocalWindowR, 1./exposures);
[offsetMapG1, slopeMapG1] = cbIntSphereAnalyze(meanLocalWindowG1, 1./exposures);
[offsetMapG2, slopeMapG2] = cbIntSphereAnalyze(meanLocalWindowG2, 1./exposures);
[offsetMapB, slopeMapB] = cbIntSphereAnalyze(meanLocalWindowB, 1./exposures);


%{
ieNewGraphWin;
imagesc(offsetMapR);
mesh(offsetMapR);
ieNewGraphWin;
imagesc(slopeMapG1/max(slopeMapG1(:)));
%}
%%
pos = [750,1000];
dvs = meanLocalWindowG1;
ieNewGraphWin;
hold all
for ii = 1:nExp
    res = slopeMapG1(pos(1), pos(2)) * 1/exposures(ii) + offsetMapG1(pos(1), pos(2));
    realDv = meanLocalWindowG1{ii}(pos(1), pos(2));
    plot(res, realDv, 'o'); identityLine
end
%% Save path
saveDir = fullfile(intSphereDir,'res');
if ~exist(saveDir, 'dir')
    mkdir(saveDir);
end
saveName = 'offset_slope_60_ac.mat';
save(fullfile(saveDir, saveName),...
    'offsetMapR', 'offsetMapG1', 'offsetMapG2', 'offsetMapB',...
    'slopeMapR', 'slopeMapG1', 'slopeMapG2', 'slopeMapB');