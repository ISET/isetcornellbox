%%
% Validation that ISO is in linear to sensor response
%%
ieInit;

%%
isoList = [55, 99, 198, 299, 395, 798];
fileList = {'IMG_20201102_103619_4.dng',...
            'IMG_20201102_103503_4.dng',...
            'IMG_20201102_103351_4.dng',...
            'IMG_20201102_103156_4.dng',...
            'IMG_20201102_102316_4.dng',...
            'IMG_20201102_101354_4.dng'};

%%
sensorList = cell(numel(fileList), 1);
sensorCropList = cell(numel(fileList), 1);
infoList = cell(numel(fileList), 1);
roi = [500 500 100 100];
meanValueR = zeros(numel(fileList), 1);
meanValueG = zeros(numel(fileList), 1);
meanValueB = zeros(numel(fileList), 1);

for ii=1:numel(sensorList)
    [sensorList{ii}, infoList{ii}, ~] = cbDNGRead(fileList{ii}, 'demosaic', false);
    sensorData = sensorGet(sensorList{ii}, 'dv');
    sensorDataR = sensorData(2:2:end, 2:2:end);
    sensorDataG = sensorData(1:2:end, 2:2:end);
    sensorDataB = sensorData(1:1:end, 1:1:end);
    thisExp = sensorGet(sensorList{ii}, 'exp time');
    meanValueR(ii) = (mean2(imcrop(sensorDataR, roi)) - 64) / thisExp;
    meanValueG(ii) = (mean2(imcrop(sensorDataG, roi)) - 64) / thisExp;
    meanValueB(ii) = (mean2(imcrop(sensorDataB, roi)) - 64) / thisExp;
end

%%
ieNewGraphWin;
hold all
plot(isoList / isoList(1), meanValueR / meanValueR(1), 'ro', 'LineWidth', 3, 'MarkerSize', 10);
plot(isoList / isoList(1), meanValueG / meanValueG(1), 'go', 'LineWidth', 3, 'MarkerSize', 10);
plot(isoList / isoList(1), meanValueB / meanValueB(1), 'bo', 'LineWidth', 3, 'MarkerSize', 10);
identityLine
axis square
grid on; box on;
legend('R', 'G', 'B')
xlabel('Gain in iso'); ylabel('Gain in DV')