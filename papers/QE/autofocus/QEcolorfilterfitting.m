% Note:
% This code is deprecated as it uses autofocus feature with unknown focus
% distance.

% Please check QEcolorfilterfittingP55, where the images were captured with
% focus distance of 0.55m

% QEcolorfilterfitting
% Get colorfilter transformation 

%%
ieInit;
%%
% {
tmp = load('p4aLensVignet.mat', 'pixel4aLensVignetSlope');
vignetting = tmp.pixel4aLensVignetSlope;
%}
%{
ieNewGraphWin;
imagesc(vignetting);
ieNewGraphWin;
plot(vignetting(1512,:))
%}
%% Corner points for auto focus
%{
topleft: [900 667 1290 945]
topcenter: [1859 672 2244 938]
topright: [2914 640 3330 923]

midleft: [905 1403 1251 1631]
midcenter: [1890 1395 2233 1630]
midright: [2976 1376 3344 1615]

botleft: [1061 2057 1392 2277]
botcenter: [1878 2046 2206 2263]
botright: [2772 2074 3118 2298]
%}
%% Initializations
qeDir = fullfile(cboxRootPath, 'local', 'measurement', 'QEcalibration',...
                               'QE');
%% Test ground for checking corner points
% {
illuminantType = {'A'};
pos = {'topleft', 'topcenter', 'topright',...
       'midleft', 'midcenter', 'midright',...
       'botleft', 'botcenter', 'botright'};
%}
%% Fit one illuminant only
% {
illuminantType = {'A'};
pos = {'topleft', 'topcenter', 'topright',...
       'midleft', 'midcenter', 'midright',...
       'botleft', 'botcenter', 'botright'};
cornerPointsMeas = {[900 667 1290 945],...
                    [1859 672 2244 938],...
                    [2914 640 3330 923],...
                    [905 1403 1251 1631],...
                    [1890 1395 2233 1630],...
                    [2976 1376 3344 1615],...
                    [1061 2057 1392 2277],...
                    [1878 2046 2206 2263],...
                    [2772 2074 3118 2298]};
%}

% Temp
%{
illuminantType = {'day'};
pos = {'topleft'};
cornerPointsMeas = {};
%} 
cornerPointsSim = [165 160 1089 770];
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

%% One position and all three illuminants
%% Fit one illuminant only
% {
illuminantType = {'A', 'day', 'cwf'};
pos = {'midcenter'};
cornerPointsMeas = {[1890 1395 2233 1630],...
                    [1890 1395 2233 1630],...
                    [1890 1395 2233 1630]};
%}

cornerPointsSim = [165 160 1089 770];
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
[cQE, mMC, rgbMeanSimMC, rgbMeanMeasMC] = cbQEAnalysis(imgNames, illuminants,...
                        cornerPointsMeas, cornerPointsSim,...
                        vignetting, 'method', 'nonnegative','fluoremove', true);
rgbMeanSimMCCor = rgbMeanSimMC * mMC;

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
