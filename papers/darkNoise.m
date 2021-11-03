% Dark noise analysis script

%%
ieInit;

%% Inspect dark current
darkCurrentPath = fullfile(cboxRootPath, 'local', 'measurement',...
                            'darkness', 'darkcurrentrate');
                        
exposures = [100 50 25 12 6];

nExposures = numel(exposures);
nFrames = 5;

darkCurrentmeanValue = zeros(nExposures, nFrames);
darkCurrentDngData = cell(nExposures, nFrames);
for ii = 1:numel(exposures)
    
    thisExpPath = fullfile(darkCurrentPath, num2str(exposures(ii)));
    darkCurrentDng = dir(fullfile(thisExpPath, '*.dng'));
    
    for jj = 1:numel(darkCurrentDng)
        thisDngFullPath = fullfile(darkCurrentDng(ii).folder, darkCurrentDng(ii).name);
        [sensor, ~, ~] = cbDNGRead(thisDngFullPath, 'demosaic', false);
        darkCurrentDngData{ii, jj} = sensorGet(sensor, 'dv');
        darkCurrentmeanValue(ii, jj) = mean(darkCurrentDngData{ii, jj}(:));
    end
end

ieNewGraphWin; plot(darkCurrentmeanValue); ylim([63, 65]);

darkCurrentDVs = mean(darkCurrentmeanValue, 2);

ieNewGraphWin; plot(1./exposures, darkCurrentDVs, 'o-'); ylim([64.18, 64.2]);

% Fit the dark current rate
P = polyfit(1./exposures,darkCurrentDVs,1);

voltSwing = sensorGet(sensor, 'pixel voltage swing');
bits = sensorGet(sensor, 'nbits');
dv2volts = voltSwing / (2^bits - 64);
darkCurrentRate = P(1) * dv2volts;

%% Inspect read noise & DSNU
rnDSNUPath = fullfile(cboxRootPath, 'local', 'measurement',...
                            'darkness', 'readnoise_dsnu', '74945');
rnDSNUFiles = dir(fullfile(rnDSNUPath, '*.dng'));
nFrames = numel(rnDSNUFiles);
rnDSNUDngData = cell(1, nFrames);
readnoiseStdDV = zeros(1, nFrames);

% Read data
for ii=1:nFrames
    [sensor, ~, ~] = cbDNGRead(fullfile(rnDSNUFiles(ii).folder, rnDSNUFiles(ii).name),...
                                'demosaic', false);
    rnDSNUDngData{ii} = double(sensorGet(sensor,'dv'));
end

% First have the averaged img that represents offset (DSNU)
meanDSNUImg = zeros(size(rnDSNUDngData{1}));
for ii=1:nFrames
    meanDSNUImg = meanDSNUImg + rnDSNUDngData{ii};
end
meanDSNUImg = meanDSNUImg / nFrames;
ieNewGraphWin; imagesc(meanDSNUImg);
dsnuEst = std(meanDSNUImg, 1, 'all');
dsnuVolt = dv2volts * dsnuEst;

% Estimate read noise by subtracting the mean value
for ii=1:nFrames
    readnoiseStdDV(ii) = std(rnDSNUDngData{ii} - meanDSNUImg, 1, 'all');
end

readnoiseDV = mean(readnoiseStdDV(:));
readnoiseVolt = dv2volts * readnoiseDV;

%% Inspect PRNU
slopePath = fullfile(cboxRootPath, 'local', 'measurement',...
                     'integratingsphere', 'ac', 'res', 'offset_slope_60_ac.mat');
load(slopePath);
ieNewGraphWin; imagesc(slopeMapG1);
% Get a 15 by 15 window local for standard deviation calculation
rect = [799 972 25 25];
slopeWindow = imcrop(slopeMapG1, rect);
% ieNewGraphWin; imagesc(slopeWindow);
PRNU = std(slopeWindow(:))/mean(slopeWindow(:)) * 100;
%% Display all the noise values
fprintf('DSNU: %f\n', dsnuVolt);
fprintf('Read noise: %f\n', readnoiseVolt);
fprintf('Dark current rate: %f\n', darkCurrentRate);
fprintf('PRNU(reference): %f\n', PRNU);