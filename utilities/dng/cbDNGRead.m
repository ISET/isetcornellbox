function [sensor, info, ip] = cbDNGRead(imgName, varargin)
% A small wrapper of DNG file read and ip compute
%
% Synopsis:
%   [sensor, info, ip] = cbDNGRead(imgPath, varargin)
%
% Inputs:
%   imgName - DNG file name
%
% Optional key/val pair:
%   crop     - crop region (Default is [])
%   demosiac - whether demosaic sensor data
%
% Returns:
%   sensor  - DNG file loaded in sensor
%   info    - DNG info struct
%   ip      - IP with demosaicking only
%%
varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('imgName', @ischar);
vFunc = @(x)(isnumeric(x) || isa(x,'images.roi.Rectangle'));
p.addParameter('crop',[],vFunc);
p.addParameter('demosaic', false, @islogical);
p.addParameter('transcolorfilter', true, @islogical);
p.parse(imgName, varargin{:})
crop = p.Results.crop;
demos = p.Results.demosaic;
transColorFilter = p.Results.transcolorfilter;
%% Read sensor
[sensor, info] = sensorDNGRead(imgName, 'crop',crop);
sensor = cbSensorCorrect(sensor, 'transcolorfilter', transColorFilter);

%% Process image
if demos
    ip = ipCreate;
    ip = ipSet(ip, 'render demosaic only', true);
    ip = ipSet(ip, 'scale display output', false);
    ip = ipCompute(ip, sensor);
else
    ip = [];
end
end