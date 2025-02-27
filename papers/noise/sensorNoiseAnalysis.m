% Noise analysis

%%
ieInit;

%%
sensorDir = fullfile(cboxRootPath, 'local',...
                    'figures', 'qualitative');
%%
% Center
% {
% Measurement
sensorMeasPath = fullfile(sensorDir, 'sensorMeasCtr.mat');
load(sensorMeasPath, 'sensorMeasCtr');

% Simulation
sensorSimPath = fullfile(sensorDir, 'sensorSimCtr.mat');
load(sensorSimPath, 'sensorSimCtr');
%}
%{
% Measurement
sensorMeasPath = fullfile(sensorDir, 'thisSensorMeas.mat');
p = load(sensorMeasPath, 'thisSensorMeas');
sensorMeasCtr = p.thisSensorMeas;
% Simulation
sensorSimPath = fullfile(sensorDir, 'thisSensorSim.mat');
p = load(sensorSimPath, 'thisSensorSim');
sensorSimCtr = p.thisSensorSim;
%}

%% Parameter initialization
nROI = 500;
width = 10; height = 10;
%% Simulation

roiSelectsSim = cbSensorUniformROISample(sensorSimCtr,...
                                        'nsamples', nROI,...
                                        'sz', [width, height]);

[udataSelectsSim, prevImgROISim] = cbRoiSelect(sensorSimCtr, roiSelectsSim);

%{
roiSelectsSim = cell(1, nROI);
% [x(horizon), y(vertical), w, h];
roiSelectsSim{1} = [638, 546, width, height];
roiSelectsSim{2} = [2654, 1924, width, height];
roiSelectsSim{3} = [2579, 634, width, height];
roiSelectsSim{4} = [2090, 1904, width, height];
roiSelectsSim{5} = [1512, 2067, width, height];
roiSelectsSim{6} = [1526, 1196, width, height];
roiSelectsSim{7} = [1687, 794, width, height];
% roiSelectsSim{8} = [2000, 1500, width, height];
% roiSelectsSim{9} = [2000, 2000, width, height];

for ii=1:nROI
    res = cbSensorROIIsUniform(sensorSimCtr, roiSelectsSim{ii});
    fprintf('Checking if ROI %d is uniform...',ii);
    if ~res
        fprintf('ROI #%d is not an uniform patch\n', ii)
    else
        fprintf('Yes it is!\n')
    end
end

[udataSelectsSim, prevImgROISim] = cbRoiSelect(sensorSimCtr, roiSelectsSim);
%}
% ieNewGraphWin; imshow(prevImgROISim);

%% Measurement

roiSelectsMeas = cbSensorUniformROISample(sensorMeasCtr,...
                                            'nsamples', nROI,...
                                            'sz', [width, height]);

[udataSelectsMeas, prevImgROIMeas] = cbRoiSelect(sensorMeasCtr, roiSelectsMeas);


%{
roiSelectsMeas = cell(1, nROI);
% [x(horizon), y(vertical), w, h];
roiSelectsMeas{1} = [872, 851, width, height];
roiSelectsMeas{2} = [2018, 1052, width, height];
roiSelectsMeas{3} = [3193, 995, width, height];
roiSelectsMeas{4} = [2072, 2327, width, height];
roiSelectsMeas{5} = [1568, 1934, width, height];
roiSelectsMeas{6} = [962, 2887, width, height];
roiSelectsMeas{7} = [2777, 1190, width, height];
% roiSelectsMeas{8} = [2000, 1500, width, height];
% roiSelectsMeas{9} = [2000, 2000, width, height];
for ii=1:nROI
    res = cbSensorROIIsUniform(sensorMeasCtr, roiSelectsMeas{ii});
    fprintf('Checking if ROI %d is uniform...',ii);
    if ~res
        fprintf('ROI #%d is not an uniform patch\n', ii)
    else
        fprintf('Yes it is!\n')
    end
end

[udataSelectsMeas, prevImgROIMeas] = cbRoiSelect(sensorMeasCtr, roiSelectsMeas);
%}
% ieNewGraphWin; imshow(prevImgROIMeas);

%% Draw noise comparison curve
stdMeas = zeros(1, nROI); meanMeas = zeros(1, nROI);
stdSim = zeros(1, nROI); meanSim = zeros(1, nROI);
ieNewGraphWin; hold all;
for ii=1:nROI
    stdMeas(ii) = udataSelectsMeas{ii}.std(2);
    meanMeas(ii) = udataSelectsMeas{ii}.mean(2);
    stdSim(ii) = udataSelectsSim{ii}.std(2);
    meanSim(ii) = udataSelectsSim{ii}.mean(2);
end
% Measurement
p1 = plot(meanMeas, stdMeas, 'o');
p1.MarkerEdgeColor = [0 0.4470 0.7410];
p1.MarkerSize = 8;
% Simulation
p2 = plot(meanSim, stdSim, 'o');
p2.MarkerEdgeColor = [0.8500 0.3250 0.0980];
p2.MarkerSize = 8;

l = legend('Measured', 'Simulated');
l.FontSize = 10;
ylabel('Standard deviation (dv)'); xlabel('Mean value (dv)');
axis square; box on; grid on; ylim([0 20]); xlim([0 800]);

%{
d = polyfit(stdMeas, meanMeas, 2);
meanPred = polyval(d,stdMeas);
plot(stdMeas, meanPred,'g-');
%}
edges = [0 65 100:100:700];
[stdMedianMeas, coverListMeas, meanMedianMeas,ibMeas] = cbSensorNoiseAnalysis(meanMeas, stdMeas, edges);
[stdMedianSim, coverListSim, meanMedianSim,ibSim] = cbSensorNoiseAnalysis(meanSim, stdSim, edges);
ieNewGraphWin;
hold all;
errorbar(meanMedianMeas(2:end), stdMedianMeas(2:end),...
        stdMedianMeas(2:end)-coverListMeas(1,2:end),...
        coverListMeas(2,2:end)-stdMedianMeas(2:end), 'b-o');
errorbar(meanMedianSim(2:end), stdMedianSim(2:end),...
        stdMedianSim(2:end)-coverListSim(1,2:end),...
        coverListSim(2,2:end)-stdMedianSim(2:end), 'r-o');
grid on; box on; 
xlabel('Mean value (dv)'); ylabel('Standard deviation');
ylim([0 14]);
%% Draw the ROI comparison (old thoughts)
%{
% Mean RGB
ieNewGraphWin; hold all
title('Mean RGB: I am not the final result yet!!')
for ii = 1:nROI
    plot(udataSelectsMeas{ii}.mean(1), udataSelectsSim{ii}.mean(1), 'ro',...
                                'MarkerSize', 8, 'LineWidth', 2);
    plot(udataSelectsMeas{ii}.mean(2), udataSelectsSim{ii}.mean(2), 'go',...
                                'MarkerSize', 8, 'LineWidth', 2);  
    plot(udataSelectsMeas{ii}.mean(3), udataSelectsSim{ii}.mean(3), 'bo',...
                                'MarkerSize', 8, 'LineWidth', 2);                              
end
identityLine; axis square; box on;
xlabel('Measured'); ylabel('Simulated')

% STD
ieNewGraphWin; hold all
title('STD RGB: I am not the final result yet!!')
for ii = 1:nROI
    plot(udataSelectsMeas{ii}.std(1), udataSelectsSim{ii}.std(1), 'ro',...
                                'MarkerSize', 8, 'LineWidth', 2);
    plot(udataSelectsMeas{ii}.std(2), udataSelectsSim{ii}.std(2), 'go',...
                                'MarkerSize', 8, 'LineWidth', 2);  
    plot(udataSelectsMeas{ii}.std(3), udataSelectsSim{ii}.std(3), 'bo',...
                                'MarkerSize', 8, 'LineWidth', 2);                              
end
identityLine; axis square; box on;
xlabel('Measured'); ylabel('Simulated')

% STD/mean: Coefficient variation

ieNewGraphWin; hold all
title('Coefficient Variation RGB: I am not the final result yet!!')
for ii = 1:nROI
    cvMeas = udataSelectsMeas{ii}.std ./ udataSelectsMeas{ii}.mean;
    cvSim = udataSelectsSim{ii}.std ./udataSelectsSim{ii}.mean;
    plot(cvMeas(1),...
         cvSim(1), 'ro',...
                                'MarkerSize', 8, 'LineWidth', 2);
    plot(cvMeas(2),...
         cvSim(2), 'go',...
                                'MarkerSize', 8, 'LineWidth', 2);  
    plot(cvMeas(3),...
         cvSim(3), 'bo',...
                                'MarkerSize', 8, 'LineWidth', 2);                              
end
xlim([0 0.2]), ylim([0 0.2]); identityLine; axis square; box on; 
xlabel('Measured'); ylabel('Simulated')
%}