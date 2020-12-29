%% Estimate the illuminant SPD from the Cornell Box and the red/green/white reflectances
%
%  These were measurements made on December 11, 2020 in the lab.
%
%  We put the several paper targets in the Gretag light booth.  We measured
%  with the internal light on and with the tungsten studio lamp on.

%% December 28, 2020

chdir(fullfile(cboxRootPath,'data','raw','11-Dec-2020'));

%% Not sure what both lights means.  Maybe studio and MCC?

% These spd look like the Tungsten (studio) lamp on the Gretag Light booth
[lgt(:,1),wave,] = ieReadSpectra('spd-11-Dec-2020-13-29-32.mat');
[lgt(:,2)] = ieReadSpectra('spd-11-Dec-2020-13-29-03.mat');
[lgt(:,3)] = ieReadSpectra('spd-11-Dec-2020-13-29-32.mat');
lgt = mean(lgt,2);

ieNewGraphWin;
plotRadiance(wave,lgt);
% plotReflectance(wave,whiteRadiance./lgt);

% These look like good reflectance estimates
[redRadiance,wave] = ieReadSpectra('red-bothlights-1.mat');
[greenRadiance] = ieReadSpectra('green-bothlights-1.mat');
[whiteRadiance] = ieReadSpectra('white-bothlights-1');

plotRadiance(wave,lgt)
plotReflectance(wave, greenRadiance ./ lgt);
plotReflectance(wave, redRadiance ./ lgt);
plotReflectance(wave, whiteRadiance ./ lgt); set(gca,'ylim',[0 1]);

%% So let's go with these reflectances for now

gRef = greenRadiance ./ lgt;
rRef = redRadiance   ./ lgt;
wRef = whiteRadiance ./lgt;
data = [rRef(:),gRef(:),wRef(:)];

comment = 'Red, Green, White reflectance estimates from Dec 11.  cboxSpectra.m';
thisFile = fullfile(cboxRootPath,'data','surfaces','cboxSurfaces.mat');
ieSaveSpectralFile(wave,data,comment,thisFile);

[cbSurf,wave] = ieReadSpectra(thisFile);
ieNewGraphWin;
plotReflectance(wave,cbSurf);

%{
  % The older one was cboxSurfaces.mat
  [tmp,wave] = ieReadSpectra('cboxWalls.mat');
  plotReflectance(wave,tmp);
%}

%% Not great estimates from measurements within the cornell box
%{
lgt = ieReadSpectra('cbox-lights-1.mat');
plotRadiance(wave,lgt);

[redRadiance,wave] = ieReadSpectra('cbox-redbackwall-1.mat');
[greenRadiance]    = ieReadSpectra('cbox-green-backwall-1.mat');
[whiteRadiance]    = ieReadSpectra('cbox-whitebackwall-1.mat');
ieNewGraphWin;

plotReflectance(wave,whiteRadiance ./ lgt); set(gca,'ylim',[0 1])
plotReflectance(wave,greenRadiance ./ lgt); set(gca,'ylim',[0 1])
plotReflectance(wave,redRadiance ./ lgt);   set(gca,'ylim',[0 1])
%}

%% OLD - Deprecated measurements.  Seem pretty bad, actually.

%  These were measurements of the white calibration target made on October
%  4, 2020 in the lab.
%
%  We put the white target in the bigger Cornell box, turned on the light,
%  and measured twice in the middle and once at the edge of the target.
%

dataDir = '/Volumes/GoogleDrive/My Drive/Data/Cornell box/Spectral calibrations/04-Oct-2020/cbox-light';

% These are the lights
spdFiles = dir(fullfile(dataDir,'*.mat'));

wave = 380:5:780;
spd = zeros(numel(wave),numel(spdFiles));
for ii=1:numel(spdFiles)
    spd(:,ii) = ieReadSpectra(fullfile(spdFiles(ii).folder,spdFiles(ii).name),wave);
end

plotRadiance(wave,spd);
set(gca,'yscale','log')

%% Save the illuminant SPD

% We use the first two from the same location.
data = mean(spd(:,[1,2]),2);
ieSaveSpectralFile(wave,data,'PR 670 measures from a white calibration target of the CBOX illuminant','cboxIlluminant');

%{
 tst = ieReadSpectra('cboxIlluminant'); plotRadiance(wave,tst)
%}

%% Surfaces
dataDir = '/Volumes/GoogleDrive/My Drive/Data/Cornell box/Spectral calibrations/04-Oct-2020/cbox-mini';
spdFiles = dir(fullfile(dataDir,'*.mat'));
illuminantSPD = ieReadSpectra('cboxIlluminant');

%% Green surface

greenRadiance = ieReadSpectra(fullfile(spdFiles(ii).folder,'green-wall-middle.mat'),wave);

ieNewGraphWin;
plot(wave,greenRadiance,'g',wave,illuminantSPD,'k--')

greenReflect = greenRadiance ./ illuminantSPD;
plotReflectance(wave,greenReflect);

%% Red surface
redRadiance = ieReadSpectra(fullfile(spdFiles(ii).folder,'red-wall-topmiddle.mat'),wave);

ieNewGraphWin;
plot(wave,redRadiance,'r',wave,illuminantSPD,'k--')

redReflect = redRadiance ./ illuminantSPD;
plotReflectance(wave,redReflect);

%% White surface

whiteRadiance = ieReadSpectra(fullfile(spdFiles(ii).folder,'white-wall-back-top.mat'),wave);
whiteReflect = whiteRadiance ./ illuminantSPD;
plotRadiance(wave,whiteRadiance);

ieNewGraphWin;
plot(wave,whiteRadiance,'b',wave,illuminantSPD,'k--');
set(gca,'yscale','log')

plotReflectance(wave,whiteReflect);

%% Save the reflectances

data = [redReflect(:),greenReflect(:),whiteReflect(:)];
comment = 'CBOX reflectances.  Red, Green, White walls.  More or less accurate to 700';
plotReflectance(wave,data);
ieSaveSpectralFile(wave,data,comment,'cboxWalls');

%% END


