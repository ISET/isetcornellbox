%%
ieInit;

%%
wave = 390:10:710;
patchSize = 32;

%% Get corrected color filter
cfCor = ieReadColorFilter(wave, 'p4aCorrected.mat');
% Vignetting
tmp = load('p4aLensVignet.mat', 'pixel4aLensVignetSlope');
vignetting = tmp.pixel4aLensVignetSlope;

qeDir = fullfile(cboxRootPath, 'local', 'measurement', 'QEcalibration',...
                               'QE');
%%
% In isetcalibrate/data/mcc
lightNameA   = 'illA-20201023.mat'; % Tungsten (A)
lightNameCWF = 'illCWF-20201023.mat'; % CWF
lightNameDay = 'illDay-20201023.mat'; % Daylight

[sceneA, oiA] = cbMccSceneOISim('illuminant', lightNameA, 'wave', wave,...
                                'patch size', patchSize);
[sceneCWF, oiCWF] = cbMccSceneOISim('illuminant', lightNameCWF, 'wave', wave,...
                                'patch size', patchSize);       
[sceneDay, oiDay] = cbMccSceneOISim('illuminant', lightNameDay, 'wave', wave,...
                                'patch size', patchSize); 

%%
% {
illuminantType = {'A', 'day', 'cwf'};
pos = 'midcenter';
cornerPointsMeas = {[1890 1395 2233 1630],...
                    [1890 1395 2233 1630],...
                    [1890 1395 2233 1630]};
%}

nFrames = numel(illuminantType) * numel(pos);
imgNames = cell(1, nFrames);
% Counter
sensorMeasOri = cell(1, 3);
sensorMeasCor = cell(1, 3);
rectsMeas = cell(1, 3);
for ii=1:numel(illuminantType)
    thisIllu = illuminantType{ii};
    
    curIlluDir = fullfile(qeDir, thisIllu);
    
    thisDngFile = dir(fullfile(curIlluDir, pos, '*.dng'));
    thisCornerPoints = cornerPointsMeas{ii};
    [sensorMeasOri{ii}, ~, ~, rectsMeas{ii}] = cbMccChipsDV(fullfile(curIlluDir, pos,thisDngFile(1).name),...
                              'corner point', thisCornerPoints,...
                              'vignetting',vignetting); 
    sensorMeasCor{ii} = sensorSet(sensorMeasOri{ii}, 'color filters', cfCor);
    sensorMeasCor{ii} = sensorSet(sensorMeasCor{ii}, 'ir filter', ones(1, numel(wave)));
end

%%
cornerPointsSim = [165 160 1089 770];
%% Illuminant A
ipA = cbIpCompute(sensorMeasOri{1});
imgA = ipGet(ipA, 'data srgb');
% ieNewGraphWin; imagesc(imgA);

% For corrected sensor
sensorASimCor = sensorSetSizeToFOV(sensorMeasCor{1}, oiGet(oiA, 'fov'), oiA);
sensorASimCor = sensorCompute(sensorASimCor, oiA);
[sensorASimCor, ~, ~, rectsASim] = cbMccChipsDV(sensorASimCor,...
                                                'corner point', cornerPointsSim);
ipASimCor = cbIpCompute(sensorASimCor);
imgASimCor = ipGet(ipASimCor, 'data srgb');
% ieNewGraphWin; imagesc(imgASimCor);

[mccACorr, dEACorr] = mccPatchCompare(imgASimCor, imgA, rectsASim, rectsMeas{1},...
                        'patch size', 128);
% ieNewGraphWin; imshow(mccACorr); title('Illuminant A (after correction)');
ieNewGraphWin; imagesc(dEACorr); axis off; title('Illuminant A deltaE2000 (after correction)');
colormap('gray'); colorbar;caxis([0 14])
% For uncorrected sensor
sensorASimOri = sensorSetSizeToFOV(sensorMeasOri{1}, oiGet(oiA, 'fov'), oiA);
sensorASimOri = sensorCompute(sensorASimOri, oiA);
[sensorASimOri, ~, ~, rectsASim] = cbMccChipsDV(sensorASimOri,...
                                                'corner point', cornerPointsSim);
ipASimOri = cbIpCompute(sensorASimOri);
imgASimOri = ipGet(ipASimOri, 'data srgb');
% ieNewGraphWin; imagesc(imgASimOri);

[mccAOri, dEAOri] = mccPatchCompare(imgASimOri, imgA, rectsASim, rectsMeas{1},...
                        'patch size', 128);
% ieNewGraphWin; imshow(mccAOri); title('Illuminant A (before correction)');
ieNewGraphWin; imagesc(dEAOri); axis off;title('Illuminant A deltaE2000 (before correction)');
colormap('gray'); colorbar; caxis([0 14]) 

%% Illuminant Day
ipDay = cbIpCompute(sensorMeasOri{2});
imgDay = ipGet(ipDay, 'data srgb');

% For corrected sensor
sensorDaySimCor = sensorSetSizeToFOV(sensorMeasCor{2}, oiGet(oiDay, 'fov'), oiDay);
sensorDaySimCor = sensorCompute(sensorDaySimCor, oiDay);
[sensorDaySimCor, ~, ~, rectsDaySim] = cbMccChipsDV(sensorDaySimCor,...
                                                'corner point', cornerPointsSim);
ipDaySimCor = cbIpCompute(sensorDaySimCor);
imgDaySimCor = ipGet(ipDaySimCor, 'data srgb');

[mccDayCorr, dEDayCorr] = mccPatchCompare(imgDaySimCor, imgDay, rectsDaySim, rectsMeas{2},...
                        'patch size', 128);
% ieNewGraphWin; imshow(mccDayCorr); title('Illuminant Day (after correction)');
ieNewGraphWin; imagesc(dEDayCorr); axis off; title('Illuminant Day deltaE2000 (after correction)');
colormap('gray'); colorbar;caxis([0 20])

% For uncorrected sensor
sensorDaySimOri = sensorSetSizeToFOV(sensorMeasOri{2}, oiGet(oiDay, 'fov'), oiDay);
sensorDaySimOri = sensorCompute(sensorDaySimOri, oiDay);
[sensorDaySimOri, ~, ~, rectsDaySim] = cbMccChipsDV(sensorDaySimOri,...
                                                'corner point', cornerPointsSim);
ipDaySimOri = cbIpCompute(sensorDaySimOri);
imgDaySimOri = ipGet(ipDaySimOri, 'data srgb');

[mccDayOri, dEDayOri] = mccPatchCompare(imgDaySimOri, imgDay, rectsDaySim, rectsMeas{2},...
                        'patch size', 128);
% ieNewGraphWin; imshow(mccDayOri); title('Illuminant Day (before correction)');
ieNewGraphWin; imagesc(dEDayOri); axis off; title('Illuminant Day deltaE2000 (before correction)');
colormap('gray'); colorbar;caxis([0 20]);
%% Illuminant CWF
ipCWF = cbIpCompute(sensorMeasOri{3});
imgCWF = ipGet(ipCWF, 'data srgb');

% For corrected sensor
sensorCWFSimCor = sensorSetSizeToFOV(sensorMeasCor{3}, oiGet(oiCWF, 'fov'), oiCWF);
sensorCWFSimCor = sensorCompute(sensorCWFSimCor, oiCWF);
[sensorCWFSimCor, ~, ~, rectsCWFSim] = cbMccChipsDV(sensorCWFSimCor,...
                                                'corner point', cornerPointsSim);
ipCWFSimCor = cbIpCompute(sensorCWFSimCor);
imgCWFSimCor = ipGet(ipCWFSimCor, 'data srgb');

[mccCWFCorr, dECWFCorr] = mccPatchCompare(imgCWFSimCor, imgCWF, rectsCWFSim, rectsMeas{3},...
                        'patch size', 128);
% ieNewGraphWin; imshow(mccCWFCorr); title('Illuminant CWF (after correction)');
ieNewGraphWin; imagesc(dECWFCorr); axis off; title('Illuminant CWF deltaE2000 (after correction)');
colormap('gray'); colorbar;caxis([0 14]);

% For uncorrected sensor
sensorCWFSimOri = sensorSetSizeToFOV(sensorMeasOri{3}, oiGet(oiCWF, 'fov'), oiCWF);
sensorCWFSimOri = sensorCompute(sensorCWFSimOri, oiCWF);
[sensorCWFSimOri, ~, ~, rectsCWFSim] = cbMccChipsDV(sensorCWFSimOri,...
                                                'corner point', cornerPointsSim);
ipCWFSimOri = cbIpCompute(sensorCWFSimOri);
imgCWFSimOri = ipGet(ipCWFSimOri, 'data srgb');

[mccCWFOri, dECWFOri]= mccPatchCompare(imgCWFSimOri, imgCWF, rectsCWFSim, rectsMeas{3},...
                        'patch size', 128);
% ieNewGraphWin; imshow(mccCWFOri); title('Illuminant CWF (before correction)');
ieNewGraphWin; imagesc(dECWFOri); axis off; title('Illuminant CWF deltaE2000 (before correction)');
colormap('gray'); colorbar; caxis([0 14]);