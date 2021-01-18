% slantedBarTest
%%
ieInit;

%% slanted bar
thisR = cbBoxCreate;
thisR.set('film resolution',[320 320]);
nRaysPerPixel = 320;
thisR.set('rays per pixel',nRaysPerPixel);
thisR.set('nbounces',5);
thisR.set('diffraction', true);
%% Remove cubes
thisR.set('assets', 'CubeSmall_B', 'chop');
thisR.set('assets', 'CubeLarge_B', 'chop');

%% Add slanted edge
assetTreeName = 'slantedbar';
[~, rootST1] = thisR.set('asset', 'root', 'graft with materials', assetTreeName);
% T1 = thisR.set('asset', rootST1.name, 'world translate', [-0.0375 0 0.10]); % 7 cm from left side
T1 = thisR.set('asset', rootST1.name, 'world translate', [0 0 0.10]); 

lensname = '2el.XXdeg.6.0mm_test.json';
lensOne = lensC('filename', lensname);
lensOne.set('middleaperturediameter', 1.5);
fl = mean(lensOne.get('bbm', 'effective focal length'));
%%
% lensOne.draw;
%{
% Create an on-center, far-away point
point = psCreate(0,0,-600);
wave = lensOne.get('wave');
sensor = filmC('position', [0 0 lensOne.focalLength], ...
    'size', [filmSz filmSz], ...
    'resolution',[300 300],...
    'wave', wave);
camera = psfCameraC('lens',lensOne,'film',sensor,'pointsource',point);
nLines = 100;
camera.estimatePSF('jitter flag',false, 'n line', nLines);
%}
thisR.camera = piCameraCreate('omni', 'lensFile', lensname);
thisR.set('aperture diameter', 0.001);
thisR.set('film diagonal', 7.6); % mm
thisR.set('film distance', 0.00613);
% thisR.set('focus distance', 0.6);

piWrite(thisR);

%%
[oi, result] = piRender(thisR, 'render type', 'radiance');
oiName = sprintf('CBLens_aperture_0.001mm');
oi = oiSet(oi, 'name', oiName);
oiWindow(oi);
oiSet(oi, 'gamma', 0.5);
% Save oi
% {
oiSavePath = fullfile(cboxRootPath, 'local', 'simulation', 'resolution_target', strcat(oiName, '.mat'));
save(oiSavePath, 'oi');
%}

%%
thisR.set('aperture diameter', 0.1);
piWrite(thisR);

%%
[oi, result] = piRender(thisR, 'render type', 'radiance');
oiName = sprintf('CBLens_aperture_0.1mm');
oi = oiSet(oi, 'name', oiName);
oiWindow(oi);
oiSet(oi, 'gamma', 0.5);
% Save oi
% {
oiSavePath = fullfile(cboxRootPath, 'local', 'simulation', 'resolution_target', strcat(oiName, '.mat'));
save(oiSavePath, 'oi');
%}

%%
thisR.set('aperture diameter', 0.05);
piWrite(thisR);

%%
[oi, result] = piRender(thisR, 'render type', 'radiance');
oiName = sprintf('CBLens_aperture_0.05mm');
oi = oiSet(oi, 'name', oiName);
oiWindow(oi);
oiSet(oi, 'gamma', 0.5);
% Save oi
% {
oiSavePath = fullfile(cboxRootPath, 'local', 'simulation', 'resolution_target', strcat(oiName, '.mat'));
save(oiSavePath, 'oi');
%}
%%
%{
d_ob = 600; % mm
d_im = 1/(1/fl - 1/d_ob);

% (R1 + R2) / (R1 - R2) = 2(n^2 - 1) / (n + 2) * (i + o) / (i - o)
n = 1.649999976158142;
d_ob = 600; % mm
k = 2 * (n^2 - 1) / (n + 2) * (d_im + d_ob) / (d_im - d_ob);
ratio = (k + 1) / (k - 1); % R1 / R2;
R1 = 8.039999961853027;
R2 = R1 / ratio;
%}


