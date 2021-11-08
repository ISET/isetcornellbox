%%
ieInit;

%% initialization
% exposures = [60, 30, 20, 15, 10]; % For dc
exposures = [5];
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
ieNewGraphWin; imagesc(meanSensorImgsG1{1});
%}
%% Select a crop
cropWindow = [768 996 20 20];
meanLocalWin = imcrop(meanSensorImgsG1{1}, cropWindow);
% ieNewGraphWin; imagesc(meanLocalWin);
% ieNewGraphWin; plot(meanLocalWin(:) - mean(meanLocalWin(:)),'o')
meanDVNoPRNU = mean(meanLocalWin(:));
localPRNU = meanLocalWin/meanDVNoPRNU;
% ieNewGraphWin; imagesc(localPRNU);

%%
offset = sensorGet(sensor, 'black level');
thisFrame = 1;
thisSensorData = sensorImgs{1, thisFrame}(2:2:end, 1:2:end);
% Take the window crop and correct with local PRNU
thislocalWin = imcrop(thisSensorData, cropWindow);
thislocalWin = (thislocalWin - offset);
% ieNewGraphWin; imagesc(thislocalWin);

thisMeanDV = mean(thislocalWin(:));
thisStdDV = std(thislocalWin(:));
alphaRatio = thisMeanDV/(thisStdDV^2);
nElectron = alphaRatio * thisMeanDV;

% Assume analog gain = 1
volt = nElectron * sensorGet(sensor, 'pixel conversion gain');
predDV = volt / sensorGet(sensor, 'pixel voltage swing') * (1024-offset);


