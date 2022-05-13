function [sensor, info, rgbMean, rects] = cbMccChipsDV(sensorData, varargin)

%%
varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('sensorData', @(x)(ischar(x)||isstruct(x))); % File name or a sensor struct
p.addParameter('cornerpoint', [],@ismatrix);
p.addParameter('blackboarder', true, @isbool);
p.addParameter('vignetting', [], @ismatrix);
p.parse(sensorData, varargin{:});
cornerPoint = p.Results.cornerpoint;
blackBorder = p.Results.blackboarder;
vignetting = p.Results.vignetting;

if numel(cornerPoint) == 4 %% Assuming it tells the top left and bottom right
    % [xmin, ymin, xmax, ymax].
    % The right order would be:
    % []
    cornerPoint = [cornerPoint(1) cornerPoint(4);
                   cornerPoint(3) cornerPoint(4);
                   cornerPoint(3) cornerPoint(2);
                   cornerPoint(1) cornerPoint(2)];
               
end

%% Read DNG file
if ischar(sensorData)
    [sensor, info] = sensorDNGRead(sensorData);
else
    sensor = sensorData;
    info = [];
end

if ~isempty(vignetting)
    blkLvl = sensorGet(sensor, 'black level');
    correctedDV = uint16((double(sensorGet(sensor, 'dv')) - blkLvl)./vignetting + blkLvl);
    sensor = sensorSet(sensor, 'dv', correctedDV);
end

if ~isempty(cornerPoint)
    crop = [cornerPoint(4),cornerPoint(8),cornerPoint(2) - cornerPoint(1),...
                    cornerPoint(6) - cornerPoint(7)];
    sensor = sensorCrop(sensor, crop);
    
    cornerPoint(:,1) = cornerPoint(:,1) - cornerPoint(4, 1) + 1;
    cornerPoint(:,2) = cornerPoint(:,2) - cornerPoint(4, 2) + 1;
    
    [rgbMean, rects] = cbMccRGBMean(sensor, cornerPoint, blackBorder);
    rgbMean = rgbMean - sensorGet(sensor,'black level');
    %{
        sensorWindow(sensor);
        chartRectsDraw(sensor,rects);  % Visualize the rectangles
    %}
end


end