% Note: this method is deprecated, was just used to compare the difference

% vignettingFittingSingleImg
% 
% Fit the lens vignetting with single exp
%%

dngDir = fullfile(cboxRootPath, 'local', 'measurement', 'integratingsphere',...
                                 'dc_p55_pos1', 'res');
                             
dngFileList = dir(fullfile(dngDir, '*.dng'));


for ii = 1:numel(dngFileList)
    thisName = fullfile(dngDir, dngFileList(ii).name);
    [sensor, info] = sensorDNGRead(thisName);

    if ii == 1
        sz = sensorGet(sensor, 'size'); % Sensor resolution
        sensorG1 = zeros(sz / 2);
    end
    
    sensorData = sensorGet(sensor, 'dv');
    sensorData = sensorData - sensorGet(sensor, 'blacklevel');
    sensorG1 = sensorG1 + double(sensorData(1:2:end, 2:2:end));
    
    
    %{
    pSz = sensorGet(sensor, 'pixel size'); % pixel size
    sSz = sensorGet(sensor, 'size'); % Sensor resolution
    pattern = sensorGet(sensor, 'pattern');
    sensorB = sensorData(1:2:end, 1:2:end);
    sensorG2 = sensorData(2:2:end, 1:2:end);
    sensorR = sensorData(2:2:end, 2:2:end);
    %}
end
% Take average
sensorG1 = sensorG1 / numel(dngFileList);
%%

[lensVignetG1Norm, lensVignetG1] = cbVignettingFitting(sensorG1, 'type', 'raw');

%{
[lensVignetBNorm, lensVignetB] = cbVignettingFitting(sensorB);

[lensVignetG2Norm, lensVignetG2] = cbVignettingFitting(sensorG2);
[lensVignetRNorm, lensVignetR] = cbVignettingFitting(sensorR);

ieNewGraphWin; imagesc(lensVignetG1Norm)
ieNewGraphWin; imagesc(lensVignetBNorm)
%}
[w, h] = size(sensorG1);

pixel4aLensVignetSingleExp = imresize(lensVignetG1Norm, 2);
ieNewGraphWin; imagesc(pixel4aLensVignetSingleExp);

%{
% Evaluation
rows = uint8(linspace(1, size(lensVignetG1, 1), 30));
ieNewGraphWin;
for ii = 1:numel(rows)
hold all;
plot(double(sensorG1(rows(ii),:)), 'b.');  
plot(lensVignetG1(rows(ii), :) * 2^10, 'r-', 'LineWidth', 5);
end
%}
%% Save results
fName = 'p4aLensVignet.mat';
savePath = fullfile(cboxRootPath, 'data', 'lens', 'vignetting', fName);
save(savePath, 'pixel4aLensVignetSingleExp');