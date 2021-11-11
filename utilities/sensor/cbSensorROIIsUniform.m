function res = cbSensorROIIsUniform(sensor, roi)
% Check if a patch on sensor is uniform patch

%%
p = inputParser;
p.addRequired('sensor', @isstruct);
p.addRequired('roi', @isnumeric);

if mod(roi(3), 2) == 0
    roi(3) = roi(3) - 1;
end
if mod(roi(4), 2) == 0
    roi(4) = roi(4) - 1;
end
%%
sensor = sensorSet(sensor, 'roi', roi);
dv = sensorGet(sensor, 'roi dv');

% Get the green channel
dvG = dv(:,2);
dvG = dvG(~isnan(dvG));
dvG = reshape(dvG, (roi(4) + 1), (roi(3) + 1)/2);
res = isUniformPatch(dvG);
end