function [prevImgSim, prevImgMeas, sensorSim, sensorMeas, oi, ipSim, ipMeas] = cbSensorSim(oi, varargin)
%%
varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('oi');
p.addParameter('measimgpath', '', @ischar);
p.addParameter('illuscale', 0.5, @isnumeric);
p.addParameter('noiseflag', 2, @isnumeric);
p.addParameter('vignetting', 1, @isnumeric);
p.parse(oi, varargin{:});

measImgPath = p.Results.measimgpath;
illuScale = p.Results.illuscale;
noiseFlag = p.Results.noiseflag;
vignetting = p.Results.vignetting;
%%
meanIllu = oiGet(oi, 'mean illuminance');
oi = oiSet(oi, 'mean illuminance', meanIllu * illuScale);

%% Create real image and sensor
if ~isempty(measImgPath)
    % measPos1Path = fullfile(cboxRootPath, 'local', 'measurement', 'camerapos', 'pos1');
    % centerImg = fullfile(measPos1Path, 'center', 'IMG_20210105_151748.dng');
    [sensorMeas, inforMeas, ipMeas] = cbDNGRead(measImgPath, 'demosaic', true);
    
    sensorSim = sensorMeas;
    sensorSim = sensorSetSizeToFOV(sensorSim, oiGet(oi, 'fov'), oi);
    sensorSim = sensorSet(sensorSim, 'noise flag', noiseFlag);
    sensorSim = sensorCompute(sensorSim, oi);
    % sensorSim = sensorSet(sensorSim, 'volts', sensorGet(sensorSim, 'volts')./vignetting);

    prevImgMeas = ipGet(ipMeas, 'srgb');
    % ieNewGraphWin; imshow(prevImgMeas);
else
    sensorSim = cbSensorCreate('IMX363');
    sensorSim = sensorSetSizeToFOV(sensorSim, oiGet(oi, 'fov'), oi);
    sensorSim = sensorSet(sensorSim, 'noise flag', noiseFlag);
    sensorSim = sensorCompute(sensorSim, oi);
    % sensorSim = sensorSet(sensorSim, 'volts', sensorGet(sensorSim, 'volts')./vignetting);

    prevImgMeas = [];
    ipMeas = [];
end

ipSim = ipCreate;
ipSim = ipSet(ipSim, 'render demosaic only', true);
ipSim = ipSet(ipSim, 'scale display output', false);
ipSim = ipCompute(ipSim, sensorSim);

prevImgSim = ipGet(ipSim, 'srgb');
% ieNewGraphWin; imshow(prevImgSim);

end