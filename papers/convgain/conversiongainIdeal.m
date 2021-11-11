%%
ieInit;

%%
oi = oiCreate('uniform d65');
oi = oiSet(oi, 'mean illuminance', 10);
%%
sensor = sensorCreateIdeal;
sensor = sensorSetSizeToFOV(sensor, oiGet(oi, 'fov')/2, oi);
sensor = sensorCompute(sensor, oi);

eMap = sensorGet(sensor, 'electrons');
eMean = mean(eMap(:));
eVar = var(eMap(:));
eStd = std(eMap(:));

vMap = sensorGet(sensor, 'volts');
vMean = mean(vMap(:));
vVar = var(vMap(:));

cg = vMean/vVar;

e2v = sensorGet(sensor, 'pixel conversion gain');
vPred = cg * vMean * e2v;
ratio = vMean / vPred;
fprintf('Ratio: %.4f\n', ratio);

%%
sensorCB = cbSensorCreate;
sensorCB = sensorSet(sensorCB, 'exp time', 0.06);
% sensorCB = sensorSet(sensorCB, 'dsnu level', 0);
% sensorCB = sensorSet(sensorCB, 'pixel dark voltage', 0);
% sensorCB = sensorSet(sensorCB, 'pixel read noise', 0);
% sensorCB = sensorSet(sensorCB, 'prnu level', 0);
% sensorCB = sensorSet(sensorCB, 'noise flag', 1);
sensorCB = sensorSetSizeToFOV(sensorCB, oiGet(oi, 'fov')/2, oi);
sensorCB = sensorCompute(sensorCB, oi);

eMapCB = sensorGet(sensorCB, 'electrons') - 64/1024 * 0.4591/sensorGet(sensorCB, 'pixel conversion gain'); 
% ieNewGraphWin; imagesc(eMapCB);
eMapCBG = eMapCB(1:2:end, 2:2:end);
% ieNewGraphWin; imagesc(eMapCBG);
eMeanCBG = mean(eMapCBG(:));
eVarCBG = var(eMapCBG(:));

vMapCB = sensorGet(sensorCB, 'volts'); 
% ieNewGraphWin; imagesc(vMapCB);
vMapCBG = vMapCB(1:2:end, 2:2:end);
% ieNewGraphWin; imagesc(vMapCB);
vMeanCBG = mean(vMapCBG(:));
vVarCBG = var(vMapCBG(:));


vSwing = sensorGet(sensorCB, 'pixel voltage swing');
dvMapCB = sensorGet(sensorCB, 'dv') - sensorGet(sensorCB, 'blacklevel');
dvMapCBG = dvMapCB(1:2:end, 2:2:end);
% ieNewGraphWin; imagesc(dvMapCBG);
dvMeanCBG = mean(dvMapCBG(:));
dvVarCBG = var(dvMapCBG(:));

cbPRNU = sensorGet(sensorCB, 'prnu level')/100;

estCG = dvMeanCBG * (1+cbPRNU^2)/(dvVarCBG - dvMeanCBG^2*cbPRNU^2);
realCG = 1/(sensorGet(sensorCB, 'pixel conversion gain') * 1024/vSwing);
ratio = estCG / realCG;
fprintf('Ratio: %.4f\n', ratio);

%%
%{
Notes:
1. When just photon noise, they match
%}
