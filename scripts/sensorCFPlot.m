sensor = sensorCreate('IMX363');

filter = sensorGet(sensor, 'color filters');
irFilter = sensorGet(sensor, 'ir filter');
filter = filter .* [irFilter irFilter irFilter];
sensorTmp = sensorSet(sensor, 'color filters', filter);
sensorPlot(sensorTmp, 'color filters');
sensorPlot(sensor, 'color filters');

cf = ieReadSpectra('p4aCorrected.mat', 390:10:710);
filter_correct = cf .* [irFilter irFilter irFilter];
sensorTmp2 = sensorSet(sensor, 'color filters', filter_correct);
sensorPlot(sensorTmp2, 'color filters');
