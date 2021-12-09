function sensor = cbSensorCompute(sensor, oi, varargin)
%%
varargin = ieParamFormat(varargin);
p = inputParser;
p.addParameter('vignettcorrection', false, @islogical);
p.parse(varargin{:});
vignettcorr = p.Results.vignettcorrection;
%%
sensor = sensorSetSizeToFOV(sensor, oiGet(oi, 'fov'),...
                            oi);
sensor = sensorCompute(sensor, oi);
if vignettcorr
    volts = sensorGet(sensor, 'volts');
    offsetAnalog = sensorGet(sensor, 'analog Offset');
    dv = sensorGet(sensor, 'dv');
    offsetDV = sensorGet(sensor, 'zero level');
    % volts
    volts(1:2:end, 1:2:end) = vignettcorrHelper(volts(1:2:end, 1:2:end), offsetAnalog);
    volts(1:2:end, 2:2:end) = vignettcorrHelper(volts(1:2:end, 2:2:end), offsetAnalog);
    volts(2:2:end, 1:2:end) = vignettcorrHelper(volts(2:2:end, 1:2:end), offsetAnalog);
    volts(2:2:end, 2:2:end) = vignettcorrHelper(volts(2:2:end, 2:2:end), offsetAnalog);

    sensor = sensorSet(sensor, 'volts', volts);
    % dv
    dv(1:2:end, 1:2:end) = vignettcorrHelper(dv(1:2:end, 1:2:end), offsetDV);
    dv(1:2:end, 2:2:end) = vignettcorrHelper(dv(1:2:end, 2:2:end), offsetDV);
    dv(2:2:end, 1:2:end) = vignettcorrHelper(dv(2:2:end, 1:2:end), offsetDV);
    dv(2:2:end, 2:2:end) = vignettcorrHelper(dv(2:2:end, 2:2:end), offsetDV);
    sensor = sensorSet(sensor, 'dv', floor(dv));
end
end

function data = vignettcorrHelper(data, offset)
    % Take 13% volts and dv off
    dataMax = mean(maxk(data(:), 10));
    data = max(data - 0.08 * (dataMax-offset)- offset, 0);

end