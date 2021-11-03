function [udataSelects, prevImgROI] = cbRoiSelect(sensor, roiSelects)

%%
sensorTmp = sensor;
nROI = numel(roiSelects);
udataSelects = cell(1, nROI);
for ii = 1:nROI
    sensorTmp = sensorSet(sensorTmp, 'roi', roiSelects{ii});
    udataSelects{ii} = sensorStats(sensorTmp, 'basic', 'dv');
end

ip = ipCreate;
ip = ipSet(ip, 'render demosaic only', true);
ip = ipCompute(ip, sensor);
% ipWindow(ip);

prevImg = ipGet(ip, 'srgb');
% ieNewGraphWin; imshow(prevImg);

%% Draw rects
prevImgROI = prevImg;
for ii = 1:nROI
    prevImgROI = insertShape(prevImgROI, 'rectangle', roiSelects{ii}, 'LineWidth', 8,...
                                     'Color', 'yellow');
end
end