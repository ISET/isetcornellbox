function sensor = cbSensorCreate(varargin)
%%
%%
varargin = ieParamFormat(varargin);
p = inputParser;
p.addParameter('transcolorfilter', true, @islogical);

p.parse(varargin{:});
transColorFilter = p.Results.transcolorfilter;

%%
sensor = sensorCreate('IMX363');
% Set sensor noise values
sensor = sensorSet(sensor, 'dsnu level', 0.000038);
sensor = sensorSet(sensor, 'pixel dark voltage', 0.000021);
sensor = sensorSet(sensor, 'pixel read noise', 0.000226);
sensor = sensorSet(sensor, 'prnu level', 0.544447);
if transColorFilter
    wave = 390:10:710;
    cf = ieReadSpectra('p4aCorrected.mat', wave);
    sensor = sensorSet(sensor, 'color filters', cf);
    sensor = sensorSet(sensor, 'ir filter', ones(1, numel(wave)));
end
end