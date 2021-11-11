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
% prnu = 0.7;
%% Set sensor noise values
sensor = sensorSet(sensor, 'dsnu level', dsnu);
sensor = sensorSet(sensor, 'pixel dark voltage', darkVoltRate);
sensor = sensorSet(sensor, 'pixel read noise volts', readNoiseVolt);
sensor = sensorSet(sensor, 'prnu level', prnu);
%% Correct QE
if transColorFilter
    wave = 390:10:710;
    cf = ieReadSpectra('p4aCorrected.mat', wave);
    sensor = sensorSet(sensor, 'color filters', cf);
    sensor = sensorSet(sensor, 'ir filter', ones(1, numel(wave)));
end
end