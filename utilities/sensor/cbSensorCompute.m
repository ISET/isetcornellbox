function sensor = cbSensorCompute(sensor, oi)
sensor = sensorSetSizeToFOV(sensor, oiGet(oi, 'fov'),...
                            oi);
sensor = sensorCompute(sensor, oi);
end