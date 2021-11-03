% Directional reflectance measurement

%% Initialization
wave = 400:10:700;
pos = {'topleft', 'topcenter', 'topright',...
       'midleft', 'midcenter', 'midright',...
       'botleft', 'botcenter', 'botright'};
illuType = {'A', 'cwf', 'day'};   

%%
ratioA = cell(1, 9);
ratioCWF = cell(1, 9);
ratioDay = cell(1, 9);
mcIllu = cell(1, 3);
curIllu = cell(3, 9);
%%
mcInd = 5;

for ii=1:numel(illuType)
    thisIllu = illuType{ii};
    cnt = 1;

    mc = ieReadSpectra(['midcenter-',thisIllu], wave);
    for jj=1:numel(pos)
        cur = ieReadSpectra([pos{jj}, '-', thisIllu], wave);
        if ii == 1
            ratioA{cnt} = cur./mc;
        elseif ii == 2
            ratioCWF{cnt} = cur./mc;
        else
            ratioDay{cnt} = cur./mc;
        end
        curIllu{ii, jj} = cur;
        cnt = cnt + 1;
    end
end

%{
thisIllu = 3;
ieNewGraphWin;
hold all;
for ii=1:9
plot(wave, curIllu{thisIllu, ii});
end
box on; grid on;
xlabel('Wavelength (nm)'); ylabel('Irradiance (Watt/nm/m^2)')
%}
%% Save results
specMeasDir = fullfile(cboxRootPath, 'local', 'measurement', 'Spectralradiometer', 'res');

if ~exist(specMeasDir, 'dir')
    mkdir(specMeasDir);
end

fName = 'posRatio.mat';

save(fullfile(specMeasDir, fName), 'ratioA', 'ratioCWF', 'ratioDay');