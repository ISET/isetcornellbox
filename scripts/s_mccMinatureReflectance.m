%% Estimate the surface reflectances of the small MCC
%
% The radiance data for the MCC were collected in the Gretag Box under
% three different illuminants.  The files in isetcalibrate/data/mcc store
% the radiances from the 24 x 3 patches and the three illuminants.
% 
% So add isetcalibrate to your path and run this
%
% Our conclusions is that the measurements HB made are very close to the
% ones we made.  And that we think the lighting in his case was probably
% more uniform than ours.  So we are going to stick with the
% MiniatureMacbethChart measurements.
%
% BW/ZLY/JEF
%
% See also
%   s_p4aRadianceMCC and tls_p4aSpectralQE
%

%%

% Set this to the directory where you have placed the radiance data
dataDir = fullfile(icalRootPath,'data','mcc');

fname = '20201023-mccRadianceData.mat'; 
dataFile = fullfile(dataDir,fname);
[radiance, wavelength] = ieReadSpectra(dataFile);

radianceA   = radiance(:,1:24);
radianceCWF = radiance(:,25:48);
radianceDay = radiance(:,49:72);

plotRadiance(wavelength,radianceA);    title('Illuminant A');
plotRadiance(wavelength,radianceCWF);  title('Illuminant CWF');
plotRadiance(wavelength,radianceDay);  title('Illuminant Day');

%% Load the illuminants for the three

fname = '20201023-illuminant-A.mat';
dataFile = fullfile(dataDir,fname);
load(dataFile,'radiance');
illA = mean(radiance,2);
outFile = fullfile(dataDir,'20201023-illA-Average');
ieSaveSpectralFile(wavelength,illA,'Average of 6 illA measures',outFile);

fname = '20201023-illuminant-CWF.mat';
dataFile = fullfile(dataDir,fname);
load(dataFile,'radiance');
illCWF = mean(radiance,2);
outFile = fullfile(dataDir,'20201023-illCWF-Average');
ieSaveSpectralFile(wavelength,illCWF,'Average of 3 illCWF measures',outFile);

fname = '20201023-illuminant-Day.mat';
dataFile = fullfile(dataDir,fname);
load(dataFile,'radiance');
illDay = mean(radiance,2);
outFile = fullfile(dataDir,'20201023-illDay-Average');
ieSaveSpectralFile(wavelength,illDay,'Average of 1 illDay measures',outFile);

%%

fname = '20201023-illA-Average';
dataFile = fullfile(dataDir,fname);
illA = ieReadSpectra(dataFile);

fname = '20201023-illCWF-Average';
dataFile = fullfile(dataDir,fname);
illCWF = ieReadSpectra(dataFile);

fname = '20201023-illuminant-Day.mat';
dataFile = fullfile(dataDir,fname);
illDay = ieReadSpectra(dataFile);

plotRadiance(wavelength,[illA(:),illCWF(:),illDay(:)]);


%% Estimate the reflectance separately, 3 times

reflectanceA = diag(1./illA)*radianceA;    % A tungsten
plotReflectance(wavelength,reflectanceA);
outFile = fullfile(dataDir,'reflectanceIllA');
ieSaveSpectralFile(wavelength,reflectanceA,'Estimated reflectance under illuminant A from the Gretag box',outFile);


reflectanceCWF = diag(1./illCWF)*radianceCWF;
plotReflectance(wavelength,reflectanceCWF);

reflectanceDay = diag(1./illDay)*radianceDay;
plotReflectance(wavelength,reflectanceDay);

%% HB measured these

wave = 400:10:700;
mccHenrykB = ieReadSpectra('MiniatureMacbethChart',wave);
plotReflectance(wave,mccHenrykB);
refA = ieReadSpectra('reflectanceIllA',wave);

scatter(refA(:), mccHenrykB(:))

for ii=1:24
    plot(refA(:,ii), mccHenrykB(:,ii),'o');
    set(gca,'xlim',[0 1],'ylim',[0 1]);
    xlabel('New'); ylabel('HB');
    identityLine;
    title(sprintf('Chip %d',ii));
    drawnow;
    pause
end







