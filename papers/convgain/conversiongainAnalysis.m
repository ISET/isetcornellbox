%%
ieInit;

%%
tmp = load('p4aLensVignet.mat', 'pixel4aLensVignetSlope');
vignetting = tmp.pixel4aLensVignetSlope;
% ieNewGraphWin; imagesc(vignetting);
%% initialization
exposures = [10];
nFrames = 10;
nExp = numel(exposures);
intSphereDir = fullfile(cboxRootPath, 'local', 'measurement',...
                                      'integratingsphere', 'ac');
% intSphereDir = fullfile(cboxRootPath, 'local', 'measurement',...
%                                       'QEcalibration', 'QE','60_repeat', 'A',...
%                                       'midcenter');                                  

sensorImgs = cell(nExp, nFrames);

for ii = 1:nExp
    thisExpDir = fullfile(intSphereDir, num2str(exposures(ii)));
    thisExpDngs = dir(fullfile(thisExpDir, '*.dng'));
    for jj = 1:nFrames    
        [sensor, info] = sensorDNGRead(fullfile(thisExpDir, thisExpDngs(jj).name));
        sensorImgs{ii, jj} = double(sensorGet(sensor, 'dv'));
    end
end

%%
cropWindow = [980 759 10 10];
%{
tmp = imresize(vignetting, 0.5);
ieNewGraphWin; imagesc(tmp);
crptmp = imcrop(tmp, cropWindow);
ieNewGraphWin; imagesc(crptmp)
%}

offset = sensorGet(sensor, 'black level');
cropSensorImgs = [];
for ii=1:nFrames
    thisFrame = ii;
    % Take the window crop and correct with local PRNU
    thisG = sensorImgs{1, thisFrame}(2:2:end, 1:2:end)-offset;
    thisSensorData = thisG./imresize(vignetting, 0.5);
    thislocalWin = imcrop(thisSensorData, cropWindow);
    cropSensorImgs = [cropSensorImgs;thislocalWin];
end

% ieNewGraphWin; imagesc(thislocalWin);
% size(cropSensorImgs)
thisMeanDV = mean(cropSensorImgs(:));
thisVarDV = var(cropSensorImgs(:));
sensorCB = cbSensorCreate;
prnu = sensorGet(sensorCB, 'prnu level')/100;
estCG = thisMeanDV * (1+prnu^2)/(thisVarDV-thisMeanDV^2*prnu^2);
% nElectron = estCG * thisMeanDV;

% Assume analog gain = 1
%{
volt = nElectron * sensorGet(sensor, 'pixel conversion gain');
predDV = volt / sensorGet(sensor, 'pixel voltage swing') * 1024;
%}
vSwing = sensorGet(sensor, 'pixel voltage swing');
assumedCG = 1/(sensorGet(sensor, 'pixel conversion gain') * 1024/vSwing);
ratio = estCG / assumedCG;
fprintf('Ratio: %.4f\n', ratio);


%%
meanSensorImgs = average2DCell(sensorImgs, 2);
meanSensorImgsR = cell(1, nExp);
meanSensorImgsG1 = cell(1, nExp);
meanSensorImgsG2 = cell(1, nExp);
meanSensorImgsB = cell(1, nExp);

for ii=1:nExp
    meanSensorImgsG1{ii} = (meanSensorImgs{ii}(1:2:end, 2:2:end)-64)./imresize(vignetting, 0.5);
end

%{
ieNewGraphWin; imagesc(meanSensorImgsG1{1}); colormap('gray');
ieNewGraphWin; plot(meanSensorImgsG1{1}(1000,:))
%}
%% Select a crop

meanLocalWin = imcrop(meanSensorImgsG1{1}, cropWindow);
% ieNewGraphWin; imagesc(meanLocalWin);
% ieNewGraphWin; plot(meanLocalWin(:) - mean(meanLocalWin(:)),'o')
meanDVNoPRNU = mean(meanLocalWin(:));
% ieNewGraphWin; imagesc(localPRNU);


%% Try isUniformPatch function
% res = isUniformPatch(meanLocalWin);
