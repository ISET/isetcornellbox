%%
ieInit;

%%
tmp = load('p4aLensVignet_dc_p55_pos1.mat', 'pixel4aLensVignetSlope');
vignetting = tmp.pixel4aLensVignetSlope;
% ieNewGraphWin; imagesc(vignetting);
%% initialization
exposures = [10];
nFrames = 15;
nExp = numel(exposures);
intSphereDir = fullfile(cboxRootPath, 'local', 'measurement',...
                                      'integratingsphere',...
                                        'dc_p55_pos1');
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
% cropWindow = [1009 763 15 15];
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
estCG = (thisVarDV-thisMeanDV^2*prnu^2)/thisMeanDV * (1+prnu^2); % (dv/e-)

% Assume analog gain = 1
%{
volt = nElectron * sensorGet(sensor, 'pixel conversion gain');
predDV = volt / sensorGet(sensor, 'pixel voltage swing') * 1024;
%}
vSwing = sensorGet(sensor, 'pixel voltage swing');
assumedCG = (sensorGet(sensor, 'pixel conversion gain') * 1024/vSwing);
ratio = estCG / assumedCG;
fprintf('Ratio: %.4f.\n', ratio);
fprintf('Relative error: %.4f percent \n', abs(estCG-assumedCG)/assumedCG*100);
%% Plot figures

ieNewGraphWin; 
histogram(cropSensorImgs(:), 50, 'BinLimits', [300 360],...
                'facecolor', [0 0.4470 0.7410],...
                'edgecolor', 'none');
grid on; ylabel('Counts'); box on; xlabel('Digital value')

ieNewGraphWin;
histogram(cropSensorImgs(:)/estCG, 50, 'BinLimits', [300 360]/estCG,...
                'facecolor', [0.8500 0.3250 0.0980],...
                'edgecolor', 'none');
grid on; xlabel('# of electrons'); box on;

% Bar
ieNewGraphWin;
X = categorical({'Nominal', 'Estimated'});
bar(X, [assumedCG, estCG]);
%% Deprecated
%{
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
%}
