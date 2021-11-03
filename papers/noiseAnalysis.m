% Noise analysis

%% Initialization
sensorSimCtr;

nROI = 5;
%% Simulation

roiSelectsSim = cell(1, nROI);
% [x(horizon), y(vertical), w, h];
width = 15; height = 15;
roiSelectsSim{1} = [722, 418, width, height];
roiSelectsSim{2} = [1478, 550, width, height];
roiSelectsSim{3} = [2579, 634, width, height];
roiSelectsSim{4} = [2090, 1904, width, height];
roiSelectsSim{5} = [1512, 2067, width, height];
% roiSelectsSim{6} = [1500, 2000, width, height];
% roiSelectsSim{7} = [2000, 1000, width, height];
% roiSelectsSim{8} = [2000, 1500, width, height];
% roiSelectsSim{9} = [2000, 2000, width, height];

[udataSelectsSim, prevImgROISim] = cbRoiSelect(sensorSimCtr, roiSelectsSim);
% ieNewGraphWin; imshow(prevImgROISim);

%% Measurement
roiSelectsMeas = cell(1, nROI);
% [x(horizon), y(vertical), w, h];
roiSelectsMeas{1} = [908, 553, width, height];
roiSelectsMeas{2} = [1946, 797, width, height];
roiSelectsMeas{3} = [3193, 995, width, height];
roiSelectsMeas{4} = [2732, 2356, width, height];
roiSelectsMeas{5} = [1980, 2551, width, height];
% roiSelectsMeas{6} = [1500, 2000, width, height];
% roiSelectsMeas{7} = [2000, 1000, width, height];
% roiSelectsMeas{8} = [2000, 1500, width, height];
% roiSelectsMeas{9} = [2000, 2000, width, height];

[udataSelectsMeas, prevImgROIMeas] = cbRoiSelect(sensorMeasCtr, roiSelectsMeas);
% ieNewGraphWin; imshow(prevImgROIMeas);

%% Draw the comparison

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