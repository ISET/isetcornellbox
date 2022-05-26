% QEcolorfilterfitting
% Get colorfilter transformation 
% This is used for analysis when focus distance is 0.55 m

%%
ieInit;
%%
% {
tmp = load('p4aLensVignet_dc_p55_pos1.mat', 'pixel4aLensVignetSlope');
vignetting = tmp.pixel4aLensVignetSlope;
%}
%{
ieNewGraphWin;
imagesc(vignetting);
ieNewGraphWin;
plot(vignetting(1512,:))
%}
%% Corner points for p55
%{
topleft: [1009 474 1434 766]
topcenter: [1884 511 2300 788]
topright: [3086 572 3479 833]

midleft: [970 1410 1333 1656]
midcenter: [1858 1408 2229 1656]
midright: [3165 1410 3553 1664]

botleft: [1117 2117 1460 2345]
botcenter: [1831 2113 2186 2351]
botright: [3142 2148 3519 2395]
%}
%% Initializations
qeDir = fullfile(cboxRootPath, 'local', 'measurement', 'QEcalibration',...
                               'QE', 'p55');
%% Test ground for checking corner points (should be commented out later)
%{
illuminantType = {'A'};
pos = {'botleft'};
nFrames = numel(illuminantType) * numel(pos);
imgNames = cell(1, nFrames);
illuminants = cell(1, nFrames);
% Counter
cnt = 1;
for ii=1:numel(illuminantType)
    thisIllu = illuminantType{ii};
    
    curIlluDir = fullfile(qeDir, thisIllu);
    
    for jj=1:numel(pos)
        thisDngFile = dir(fullfile(curIlluDir, pos{jj}, '*.dng'));
        imgNames{cnt} = fullfile(curIlluDir, pos{jj},thisDngFile(1).name);
        illuminants{cnt} = thisIllu;
        cnt = cnt + 1;
        %{
        thisCornerPoints = [1117 2117 1460 2345];
        cbMccChipsDV(fullfile(curIlluDir, pos{jj},thisDngFile(1).name),...
                              'corner point', thisCornerPoints,...
                              'vignetting',vignetting); 
        %{
            [sensor, info] = sensorDNGRead(fullfile(curIlluDir, pos{jj},thisDngFile(1).name));
            sensorWindow(sensor);
        %}
        %}
    end
end
%}

%% One position and all three illuminants
%% Fit one illuminant only
% {
illuminantType = {'A', 'day', 'cwf'};
pos = {'midcenter'};
cornerPointsMeas = {[1858 1408 2229 1656],...
                    [1858 1408 2229 1656],...
                    [1858 1408 2229 1656]};
%}

cornerPointsSim = [147 115 1086 737];
nFrames = numel(illuminantType) * numel(pos);
imgNames = cell(1, nFrames);
illuminants = cell(1, nFrames);
% Counter
cnt = 1;
for ii=1:numel(illuminantType)
    thisIllu = illuminantType{ii};
    
    curIlluDir = fullfile(qeDir, thisIllu);
    
    for jj=1:numel(pos)
        thisDngFile = dir(fullfile(curIlluDir, pos{jj}, '*.dng'));
        imgNames{cnt} = fullfile(curIlluDir, pos{jj},thisDngFile(1).name);
        illuminants{cnt} = thisIllu;
        cnt = cnt + 1;
    end
end

%
[cQE, mMC2, rgbMeanSimMC, rgbMeanMeasMC] = cbQEAnalysis(imgNames, illuminants,...
                        cornerPointsMeas, cornerPointsSim,...
                        vignetting, 'method', 'nonnegative','fluoremove', true);
rgbMeanSimMCCor = rgbMeanSimMC * mMC2;

%{
sensorA = cbDNGRead(imgNames{1}, 'demosaic', false);
sensorADV = sensorGet(sensorA, 'dv');
sensorAG1 = sensorADV(1:2:end, 2:2:end);
sensorAG2 = sensorADV(2:2:end, 1:2:end);
ieNewGraphWin; imagesc(abs(sensorAG1 - sensorAG2)./sensorAG2 * 100);
caxis([-1 1]); c = colorbar; c.Ruler.TickLabelFormat='%g%%';

sensorDay = cbDNGRead(imgNames{2}, 'demosaic', false);
sensorDayDV = sensorGet(sensorDay, 'dv');
sensorDayG1 = sensorDayDV(1:2:end, 2:2:end);
sensorDayG2 = sensorDayDV(2:2:end, 1:2:end);
ieNewGraphWin; imagesc(abs(sensorDayG1 - sensorDayG2)./sensorDayG2 * 100);
caxis([-1 1]); c = colorbar; c.Ruler.TickLabelFormat='%g%%';

sensorCWF = cbDNGRead(imgNames{3}, 'demosaic', false);
sensorCWFDV = sensorGet(sensorCWF, 'dv');
sensorCWFG1 = sensorCWFDV(1:2:end, 2:2:end);
sensorCWFG2 = sensorCWFDV(2:2:end, 1:2:end);
ieNewGraphWin; imagesc(abs(sensorCWFG1 - sensorCWFG2)./sensorCWFG2 * 100);
caxis([-1 1]); c = colorbar; c.Ruler.TickLabelFormat='%g%%';
%}
%% Analysis

ieNewGraphWin; hold all
plot(rgbMeanMeasMC(:,1), rgbMeanSimMCCor(:,1), 'ro', 'MarkerSize', 5); 
plot(rgbMeanMeasMC(:,2), rgbMeanSimMCCor(:,2), 'go', 'MarkerSize', 5); 
plot(rgbMeanMeasMC(:,3), rgbMeanSimMCCor(:,3), 'bo', 'MarkerSize', 5);
axis square; box on;
xlabel('Measurement (dv)'); ylabel('Simulation (dv)');
identityLine;

ieNewGraphWin; hold all
plot(rgbMeanMeasMC(:,1), rgbMeanSimMC(:,1), 'ro', 'MarkerSize', 5); 
plot(rgbMeanMeasMC(:,2), rgbMeanSimMC(:,2), 'go', 'MarkerSize', 5); 
plot(rgbMeanMeasMC(:,3), rgbMeanSimMC(:,3), 'bo', 'MarkerSize', 5); 
axis square; box on;
xlabel('Measurement (dv)'); ylabel('Simulation (dv)');
identityLine;

%% Fit one illuminant only
%{
topleft: [1009 474 1434 766]
topcenter: [1884 511 2300 788]
topright: [3086 572 3479 833]

midleft: [970 1410 1333 1656]
midcenter: [1858 1408 2229 1656]
midright: [3165 1410 3553 1664]

botleft: [1117 2117 1460 2345]
botcenter: [1831 2113 2186 2351]
botright: [3142 2148 3519 2395]
%}
% {
illuminantType = {'A'};
pos = {'topleft', 'topcenter', 'topright',...
       'midleft', 'midcenter', 'midright',...
       'botleft', 'botcenter', 'botright'};
cornerPointsMeas = {[1009 474 1434 766],...
                    [1884 511 2300 788],...
                    [3086 572 3479 833],...
                    [970 1410 1333 1656],...
                    [1858 1408 2229 1656],...
                    [3165 1410 3553 1664],...
                    [1117 2117 1460 2345],...
                    [1831 2113 2186 2351],...
                    [3142 2148 3519 2395]};
%}

% Temp
%{
illuminantType = {'day'};
pos = {'topleft'};
cornerPointsMeas = {};
%} 
cornerPointsSim = [147 115 1086 737];
nFrames = numel(illuminantType) * numel(pos);
imgNames = cell(1, nFrames);
illuminants = cell(1, nFrames);
% Counter
cnt = 1;
for ii=1:numel(illuminantType)
    thisIllu = illuminantType{ii};
    
    curIlluDir = fullfile(qeDir, thisIllu);
    
    for jj=1:numel(pos)
        thisDngFile = dir(fullfile(curIlluDir, pos{jj}, '*.dng'));
        imgNames{cnt} = fullfile(curIlluDir, pos{jj},thisDngFile(1).name);
        illuminants{cnt} = thisIllu;
        cnt = cnt + 1;
        %{
        thisCornerPoints = [900 667 1290 945];
        cbMccChipsDV(fullfile(curIlluDir, pos{jj},thisDngFile(1).name),...
                              'corner point', thisCornerPoints,...
                              'vignetting',vignetting); 
        %{
            [sensor, info] = sensorDNGRead(fullfile(curIlluDir, pos{jj},thisDngFile(1).name));
            sensorWindow(sensor);
        %}
        %}
    end
end

%
[cQE, mOneIllu, rgbMeanSimOneIllu, rgbMeanMeasOneIllu] = cbQEAnalysis(imgNames, illuminants,...
                        cornerPointsMeas, cornerPointsSim,...
                        vignetting, 'method', 'nonnegative');
rgbMeanSimOneIlluCor = rgbMeanSimOneIllu * mOneIllu;
%
%{
cf = sensorGet(sensor, 'colorfilters');
ieNewGraphWin;
plot(cf * mOneIllu);
%}
%{
wave = 400:10:700;
illuA = ieReadSpectra('illA-20201023', wave);
illuCWF = ieReadSpectra('illCWF-20201023', wave);
illuDay = ieReadSpectra('illDay-20201023', wave);

ieNewGraphWin; plot(wave, illuA); title('A');
ieNewGraphWin; plot(wave, illuCWF); title('CWF');
ieNewGraphWin; plot(wave, illuDay); title('Day');
%}

%{
ieNewGraphWin; hold all
plot(rgbMeanSimOneIlluCor(:,1), rgbMeanMeasOneIllu(:,1), 'ro'); 
plot(rgbMeanSimOneIlluCor(:,2), rgbMeanMeasOneIllu(:,2), 'go'); 
plot(rgbMeanSimOneIlluCor(:,3), rgbMeanMeasOneIllu(:,3), 'bo'); 
identityLine;
%}

%{
ieNewGraphWin; hold all
plot(rgbMeanSimOneIllu(:,1), rgbMeanMeasOneIllu(:,1), 'ro'); 
plot(rgbMeanSimOneIllu(:,2), rgbMeanMeasOneIllu(:,2), 'go'); 
plot(rgbMeanSimOneIllu(:,3), rgbMeanMeasOneIllu(:,3), 'bo'); 
identityLine;
%}

%% Analysis
posRatioMeas = fullfile(cboxRootPath, 'local', 'measurement',...
                            'Spectralradiometer', 'res', 'posRatio.mat');
pr = load(posRatioMeas);
% First place vs nth place
ieNewGraphWin;
for n = 1:9
first = (n-1)*24+1; last = first + 23;
centerFirst = (5-1)*24+1; centerLast = centerFirst + 23;
subplot(3, 3, n)
hold all
plot(rgbMeanMeasOneIllu(centerFirst:centerLast,1),...
    rgbMeanMeasOneIllu(first:last,1), 'ro', 'MarkerSize', 5); identityLine;
plot(rgbMeanMeasOneIllu(centerFirst:centerLast,2),...
    rgbMeanMeasOneIllu(first:last,2), 'go', 'MarkerSize', 5); identityLine;
plot(rgbMeanMeasOneIllu(centerFirst:centerLast,3),...
    rgbMeanMeasOneIllu(first:last,3), 'bo', 'MarkerSize', 5); identityLine;
xlabel(pos{5}); ylabel(pos{n});
axis square; box on
if illuminantType{1} == 'A'
    refline([mean(pr.ratioA{n}(2:end)) 0]);
elseif isequal(illuminantType{1}, 'cwf')
    refline([mean(pr.ratioCWF{n}(2:end)) 0]);
else
    refline([mean(pr.ratioDay{n}(2:end)) 0]);
end
title(sprintf('Illuminant: %s - Position %s', illuminantType{1}, pos{n}))
end
%}

%% Color filter Comparison
sensor = sensorCreate('IMX363');
cf = sensorGet(sensor, 'color filters');
ir = sensorGet(sensor, 'irfilter');

filterOri = cf .* repmat(ir, [1, 3]);
filterCorr = filterOri * mMC;
%{
wave = sensorGet(sensor,'wave');
ieNewGraphWin;
hold all;
plot(wave, cf(:,1), 'r-');
plot(wave, cf(:,2), 'g-');
plot(wave, cf(:,3), 'b-');
box on; xlim([400 700]); ylim([0 1]); grid on;
plot(wave, ir, 'k-');
xlabel('Wavelength (nm)'); ylabel('Transmissivity');
legend('R', 'G', 'B', 'NIR');
%}
%{
wave = sensorGet(sensor,'wave');
ieNewGraphWin;
hold all;
plot(wave, filterOri(:,1), 'r--');
plot(wave, filterOri(:,2), 'g--');
plot(wave, filterOri(:,3), 'b--');
box on; xlim([400 700]); ylim([0 1]); grid on;
xlabel('Wavelength (nm)'); ylabel('Transmissivity');
legend('R-nominal', 'G-nominal', 'B-nominal');
axis square;

ieNewGraphWin;
hold all;
box on; xlim([400 700]); ylim([0 1]); grid on;
plot(wave, filterCorr(:,1), 'r');
plot(wave, filterCorr(:,2), 'g');
plot(wave, filterCorr(:,3), 'b');
xlabel('Wavelength (nm)'); ylabel('Transmissivity');
legend('R-corrected', 'G-corrected', 'B-corrected');
axis square;
%}
%% Save results
cfSavePath = fullfile(cboxRootPath, 'data', 'color', 'p4aCorrected.mat');
sensorCorr = sensorSet(sensor, 'color filters', filterCorr);
sensorCorr = sensorSet(sensorCorr, 'ir filter', ones(1, size(ir, 1)));
ieSaveColorFilter(sensorCorr, cfSavePath);

%% Other plots
wave = 390:10:710;
% In isetcalibrate/data/mcc
lightNameA   = 'illA-20201023.mat'; % Tungsten (A)
lightNameCWF = 'illCWF-20201023.mat'; % CWF
lightNameDay = 'illDay-20201023.mat'; % Daylight

spdA = ieReadSpectra(lightNameA, wave);
spdCWF = ieReadSpectra(lightNameCWF, wave);
spdDay = ieReadSpectra(lightNameDay, wave);
% A
ieNewGraphWin;
hold all
plot(wave, spdA); 
% xlabel('Wavelength (nm)'); ylabel('Radiance (Watt/sr/nm/m^2)');
% title('Illuminant A'); xlim([400 700]); box on; grid on;
% CWF
% ieNewGraphWin;
plot(wave, spdCWF); 
% xlabel('Wavelength (nm)'); ylabel('Radiance (Watt/sr/nm/m^2)');
% title('Illuminant CWF'); xlim([400 700]); box on; grid on;
% Day
% ieNewGraphWin;
plot(wave, spdDay); 
legend('Illuminant A', 'Illuminant CWF', 'Illuminant Day');
xlabel('Wavelength (nm)'); ylabel('Radiance (Watt/sr/nm/m^2)');
title('Illuminants'); xlim([400 700]); box on; grid on;

%% MCC reflectance
mccName = 'MiniatureMacbethChart';wave = 400:10:700;
refl = ieReadSpectra(mccName, wave);

ieNewGraphWin; plot(wave, refl, 'LineWidth', 8);
xlabel('Wavelength (nm)'); ylabel('Reflectance');
title('Macbeth Colorchecker Reflectance'); xlim([400 700]);
box on; grid on;
