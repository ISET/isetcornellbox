function [sensor, rgbMean, rects] = cbMccSensorSim(oi, sensor, cornerPoint, varargin)

%%
p = inputParser;
p.addRequired('oi', @isstruct);
p.addRequired('sensor', @isstruct);
p.addRequired('cornerPoint', @ismatrix);
p.parse(oi, sensor, cornerPoint, varargin{:});

%%
% Set sensor to be noise free
sensor = sensorSet(sensor, 'noise flag', 0);
sensor = sensorSet(sensor, 'name', oiGet(oi, 'name'));

% Set sensor size to fov
sensor = sensorSetSizeToFOV(sensor, oiGet(oi, 'fov'), oi);

% Compute sensor data
sensor = sensorCompute(sensor, oi);

%%
[sensor, ~, rgbMean, rects] = cbMccChipsDV(sensor,...
                                        'corner point', cornerPoint);
end