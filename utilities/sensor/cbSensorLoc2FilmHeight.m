function filmHeight = cbSensorLoc2FilmHeight(sensor, pos)

%%
sz = sensorGet(sensor, 'size');
posCentered = pos - sz/2;
filmHeight = sqrt(sum((posCentered * 1.4/1000).^2));
end