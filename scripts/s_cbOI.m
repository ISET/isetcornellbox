%% s_cbOI
% Create optical image for Cornell Box simulation

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%%
thisR = piRecipeDefault('scene name', 'cornell box reference');

thisR.set('film resolution',[320 320]);
nRaysPerPixel = 128;
thisR.set('rays per pixel',nRaysPerPixel);
thisR.set('nbounces',5); 
%%
piLightDelete(thisR, 'all');
% thisR.assets.show
%% Turn the object to area light

areaLight = piLightCreate('type', 'area');
% lightName = 'BoxLampSPD';
lightName = 'cbox-lights-1';
areaLight = piLightSet(areaLight, [], 'lightspectrum', lightName);
areaLight = piLightSet(areaLight, [], 'spectrum scale', 1);

assetName = 'AreaLight_O';
thisR.set('asset', assetName, 'obj2light', areaLight);
%{
wave = 400:10:700;
lName0 = 'BoxLampSPD';
lName1 = 'cbox-lights-1';
lName2 = 'cbox-lights-2';

l0 = ieReadSpectra(lName0, wave);
l1 = ieReadSpectra(lName1, wave);
l2 = ieReadSpectra(lName2, wave);
ratio = l0 ./ l1;

ieNewGraphWin;
hold all
plot(wave, l0, 'r');
plot(wave, l1, 'g');
plot(wave, l2, 'b');

ieNewGraphWin;
plot(wave, ratio);
%}

%% Load spetral reflectance
wave = 400:10:700;
refl = ieReadSpectra('cboxSurfaces', wave);
% How did we measure reflectance for red and green wall?
rRefl = refl(:, 1);
gRefl = refl(:, 2);
wRefl = refl(:, 3);

%{
ieNewGraphWin;
hold all
plot(wave, rRefl, 'r');
plot(wave, gRefl, 'g');
plot(wave, wRefl, 'k');
%}

%% Load spectral reflectance
piMaterialList(thisR);

rWallMat = 'LeftWall';
gWallMat = 'RightWall';
bkWallMat = 'BackWall';
tWallMat = 'TopWall';
btmWallMat = 'BottomWall';


rReflSPD = piMaterialCreateSPD(wave, rRefl);
gReflSPD = piMaterialCreateSPD(wave, gRefl);
wReflSPD = piMaterialCreateSPD(wave, wRefl);

% Set spectral reflectance
thisR.set('material', rWallMat, 'kd value', rReflSPD);
% thisR.get('material', rWallMat, 'kd value')
thisR.set('material', gWallMat, 'kd value', gReflSPD);
thisR.set('material', bkWallMat, 'kd value', wReflSPD);
thisR.set('material', tWallMat, 'kd value', wReflSPD);
thisR.set('material', btmWallMat, 'kd value', wReflSPD);

% thisR.assets.show

%% Remove the two cubes
assetName = 'CubeSmall_B';
thisR.set('asset', assetName, 'chop');
assetName = 'CubeLarge_B';
thisR.set('asset', assetName, 'chop');

%% Add bunny
assetTreeName = 'bunny';
rootST = thisR.set('asset', 'root', 'graft with materials', assetTreeName);
thisR.get('asset', 'Bunny_O', 'world position')
% thisR.assets.show
thisR.set('asset', rootST.name, 'world translate', [0.05 0 -0.05]);
thisR.set('asset', rootST.name, 'chop');
%% Add Coordinate
assetTreeName = 'coordinate';
rootST2 = thisR.set('asset', 'root', 'graft with materials', assetTreeName);
thisR.set('asset', rootST2.name, 'world translate', [0 0.1 0]);
thisR.set('asset', rootST2.name, 'chop');
%% Add Slanted bar
assetTreeName = 'slantedbar';
rootST3 = thisR.set('asset', 'root', 'graft with materials', assetTreeName);
T1 = thisR.set('asset', rootST3.name, 'world translate', [0 0 0.1]);
% thisR.assets.show
% thisR.set('asset', T1.name, 'delete');
thisR.set('asset', rootST3.name, 'chop');
%% Add MCC
assetTreeName = 'mccCB';
rootST4 = thisR.set('asset', 'root', 'graft with materials', assetTreeName);
T2 = thisR.set('asset', rootST4.name, 'world translate', [0 0 0.1]);
% thisR.assets.show
% thisR.set('asset', rootST4.name, 'chop');
%% In the case of using pinhole
% Do a quick rendering to get the scaling factor
thisR.set('film resolution',[320 320]);
nRaysPerPixel = 32;
thisR.set('rays per pixel',nRaysPerPixel);
thisR.set('nbounces',5); 

% Write and render
piWrite(thisR);

[scene, result] = piRender(thisR, 'render type', 'radiance', 'scale illuminance', false);
sceneName = 'CBPinhole';
scene = sceneSet(scene, 'name', sceneName);

% Normalize the max peakLuminance with nRaysPerPixel
meanLuminance = sceneGet(scene, 'mean luminance');
% scale = meanLuminance / nRaysPerPixel;
% Get mean of top peak luminance
sceneIllu = sceneGet(scene, 'luminance');
sceneIlluSort = sort(sceneIllu(:), 'descend');
peakLuminance = mean(sceneIlluSort(1:50));

% Load light spd
lgt = ieReadSpectra(lightName, wave);
%{
ieNewGraphWin;
plot(wave, lgt);
%}
% Get luminance of light
realLuminance = ieLuminanceFromEnergy(lgt, wave);

% Calculate the scaling factor (ratio/raysperpixel)
scaleFactor = peakLuminance / realLuminance;
%{
% Scale the whole scene
scene = sceneSet(scene, 'max luminance', peakLuminance / scaleFactor);
sceneWindow(scene);
sceneSet(scene, 'gamma', 0.5);
%}
sfPerRay = scaleFactor / nRaysPerPixel;
%% In the case of using lens
% {
%% Specify new rendering setting
thisR.set('film resolution',[320 320]);
nRaysPerPixel = 128;
thisR.set('rays per pixel',nRaysPerPixel);
thisR.set('nbounces',5); 
%% Build a lens
% lensfile = 'reversed.telephoto.77deg.3.5201mm.json';
lensfile  = 'dgauss.77deg.3.5201mm.json';  
fprintf('Using lens: %s\n',lensfile);
thisR.camera = piCameraCreate('omni','lensFile',lensfile);
thisR.set('aperture diameter', 2.5);
thisR.set('film diagonal',5); % mm

%% Write and render
piWrite(thisR);

% Render 
[oi, result] = piRender(thisR, 'render type', 'radiance', 'scale illuminance', false);
oiName = 'CBLens_MCC';
oiSet(oi, 'name', oiName);

%%
meanIllu = oiGet(oi, 'mean illuminance');
% Scale illuminance
scaleFactorOI = sfPerRay * nRaysPerPixel;
oi = oiSet(oi, 'mean illuminance', meanIllu / scaleFactorOI);
%{
%% Scale oi
lampSPD = ieReadSpectra(lightName, wave);
lampIllu = ieLuminanceFromEnergy(lampSPD, wave);
%{
ieNewGraphWin;
hold all;
plot(wave, lampSPD);
%}
% Get max irradiance region
illu = oiGet(oi, 'illuminance');
peakIlluminance = max(illu(:));
oi = oiAdjustIlluminance(oi, lampIllu, 'max');
%}
oiWindow(oi);
oiSet(oi, 'gamma', 0.5);
%}
%% Save oi
%{
oiSavePath = fullfile(cboxRootPath, 'local', strcat(oiName, '.mat'));
save(oiSavePath, 'oi');
%}