% s_lensShadingEstimation

%% cos4th
% Get fit of: offset + globalScale * (d^4) / (d^2 + x^2 + y^2)^2

dngName = 'IMG_20201102_103619_4.dng';
[sensor1, info] = sensorDNGRead(dngName);
pSz = sensorGet(sensor1, 'pixel size'); % pixel size
sSz = sensorGet(sensor1, 'size'); % Sensor resolution

sensorData = sensorGet(sensor1, 'dv');
sensorData = sensorData - 63.9;
pattern = sensorGet(sensor1, 'pattern');

sensorB = sensorData(1:2:end, 1:2:end);
sensorG1 = sensorData(1:2:end, 2:2:end);
sensorG2 = sensorData(2:2:end, 1:2:end);
sensorR = sensorData(2:2:end, 2:2:end);

%%
samplerate = 2;
[corrMapBNorm, corrMapB, errorB] = cbVignettingFitting(sensorB, samplerate);
[corrMapG1Norm, corrMapG1, errorG1] = cbVignettingFitting(sensorG1, samplerate);
[corrMapG2Norm, corrMapG2, errorG2] = cbVignettingFitting(sensorG2, samplerate);
[corrMapRNorm, corrMapR, errorR] = cbVignettingFitting(sensorR, samplerate);

%{
% Difference between different channels
%
ieNewGraphWin;
imagesc(corrMapBNorm); colormap('gray')

ieNewGraphWin;
imagesc(abs(corrMapBNorm - corrMapG1Norm) ./ corrMapBNorm * 100);

ieNewGraphWin;
imagesc(abs(corrMapBNorm - corrMapG2Norm) ./ corrMapBNorm * 100);

ieNewGraphWin;
imagesc(abs(corrMapBNorm - corrMapRNorm) ./ corrMapBNorm * 100);
%}

%{
% Relative error
ieNewGraphWin;
imagesc(abs(double(sensorB) - corrMapB) ./ double(sensorB) * 100);
%}

% Upsampling
corrMapBNormUpSamp = imresize(corrMapBNorm, 2);
%{
ieNewGraphWin;
imagesc(corrMapBNormUpSamp); colormap('gray')
%}
%%
fName = 'p4aLensVignette.mat';
savePath = fullfile(cboxRootPath, 'local', 'simulation', 'lens_vignetting', fName);
save(savePath, 'corrMapBNormUpSamp', 'corrMapBNorm');