function [sensor, info, rgbMean, rects] = cbMccChipsDV(sensorData, varargin)

%%
varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('sensorData', @(x)(ischar(x)||isstruct(x))); % File name or a sensor struct
p.addParameter('cornerpoint', [],@ismatrix);
p.addParameter('crop', [], @isvector);
p.addParameter('blackboarder', true, @isbool);
p.parse(sensorData, varargin{:});
crop = p.Results.crop;
cornerPoint = p.Results.cornerpoint;
blackBorder = p.Results.blackboarder;

%% Read DNG file
if ischar(sensorData)
    [sensor, info] = sensorDNGRead(sensorData, 'crop', crop);
else
    sensor = sensorData;
    info = [];
end

if ~isempty(cornerPoint)
    [rects, mLocs, pSize] = chartRectangles(cornerPoint,4,6,0.5,blackBorder);
    nPixel = round(pSize(1)/4);
    rgbMean = chartRectsData(sensor,mLocs,nPixel,false,'dv'); %returns digital values
    rgbMean = rgbMean - sensorGet(sensor,'black level');
end
end