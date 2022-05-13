function sensor = cbSensorCorrect(sensor, varargin)
% Load sensor parameters 

%%
varargin = ieParamFormat(varargin);
p = inputParser;
p.addParameter('transcolorfilter', true, @islogical);

p.parse(varargin{:});
transColorFilter = p.Results.transcolorfilter;
%% Initialization
dsnu = 0.00038;
darkVoltRate = 0.000021;
readNoiseVolt = 2.2555e-04;
prnu = 0.544447;
% convGain = (7.6512e-5) /0.1707 * 0.1677; 
% prnu = 0.7; % This was the reported number
%% Set sensor noise values
sensor = sensorSet(sensor, 'dsnu level', dsnu);
sensor = sensorSet(sensor, 'pixel dark voltage', darkVoltRate);
sensor = sensorSet(sensor, 'pixel read noise volts', readNoiseVolt);
sensor = sensorSet(sensor, 'prnu level', prnu);
% sensor = sensorSet(sensor, 'conversion gain', convGain);
%% Correct QE
if transColorFilter
    wave = 400:10:700;
    cf = ieReadSpectra('p4aCorrected.mat', wave);
    sensor = sensorSet(sensor, 'wave', wave);
    sensor = sensorSet(sensor, 'color filters', cf);
    sensor = sensorSet(sensor, 'ir filter', ones(1, numel(wave)));
end
end