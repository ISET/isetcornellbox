%% Estimate the illuminant SPD from the Cornell Box and the red/green/white reflectances
%
%  These were measurements of the white calibration target made on October
%  4, 2020 in the lab.
%
% We put the white target in the bigger Cornell box, turned on the light,
% and measured twice in the middle and once at the edge of the target.
%

%%
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


