%% s_cbOI
% Create optical image for Cornell Box simulation

%% Initialize ISET and Docker

ieInit;
if ~piDockerExists, piDockerConfig; end

%%
thisR = piRecipeDefault('scene name', 'cornell box reference');

thisR.set('film resolution',[2048 2048]);
thisR.set('rays per pixel',2048);
thisR.set('fov',45);
thisR.set('nbounces',5); 
%%
piLightDelete(thisR, 'all');

% thisR.assets.show
%% Turn the object to area light

areaLight = piLightCreate('type', 'area');
lightName = 'Tungsten';
areaLight = piLightSet(areaLight, [], 'lightspectrum', lightName);
areaLight = piLightSet(areaLight, [], 'spectrum scale', 3e-1);

assetName = 'AreaLight_O';
thisR.set('asset', assetName, 'obj2light', areaLight);
%{
% Write and render
piWrite(thisR);
scene = piRender(thisR, 'render type', 'radiance');
scene = sceneSet(scene, 'name', 'Obj2Arealight');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');
%}

%% Add bunny
assetTreeName = 'bunny';
rootST = thisR.set('asset', 'root', 'graft with materials', assetTreeName);
thisR.get('asset', 'Bunny_O', 'world position')

% thisR.assets.show
thisR.set('asset', rootST.name, 'world translate', [0.05 0 -0.05]);

%{
piWrite(thisR);
[scene, res] = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');
%}
thisR.set('asset', rootST.name, 'chop');
%% Add Coordinate
assetTreeName = 'coordinate';
rootST2 = thisR.set('asset', 'root', 'graft with materials', assetTreeName);
thisR.set('asset', rootST2.name, 'world translate', [0 0.1 0]);
% thisR.assets.show
%{
piWrite(thisR);
[scene, res] = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');
%}

thisR.set('asset', rootST2.name, 'chop');
%% Add Slanted bar
assetTreeName = 'slantedbar';
rootST3 = thisR.set('asset', 'root', 'graft with materials', assetTreeName);

T1 = thisR.set('asset', rootST3.name, 'world translate', [0 0 0.1]);
% thisR.assets.show
% thisR.set('asset', T1.name, 'delete');
%{
piWrite(thisR);
[scene, res] = piRender(thisR, 'render type', 'radiance');
sceneWindow(scene);
sceneSet(scene, 'render flag', 'hdr');
%}

%% Build a lens
% lensfile = 'reversed.telephoto.77deg.3.5201mm.json';
lensfile  = 'dgauss.77deg.3.5201mm.json';  
fprintf('Using lens: %s\n',lensfile);
thisR.camera = piCameraCreate('omni','lensFile',lensfile);
thisR.set('aperture diameter', 2.5);
thisR.set('film diagonal',5); % mm
%{
%% Save the recipe information
piWrite(thisR);

% Render 
%
% There is no lens, just a pinhole.  In that case, we are rendering a
% scene. If we had a lens, we would be rendering an optical image.
[oi, result] = piRender(thisR, 'render type', 'radiance');
oi = oiSet(oi, 'name', 'CB Lens');
oiWindow(oi);
oiSet(oi, 'gamma', 0.5);
%}

%% Load spetral reflectance
wave = 400:10:700;
refl = ieReadSpectra('cboxWalls', wave);
% How did we measure reflectance for red and green wall?
rRefl = refl(:, 1);
gRefl = refl(:, 2);
% wRefl2 = refl(:, 3);
wRefl = ieReadSpectra('CBWhiteSurface.mat', wave);

%{
ieNewGraphWin;
hold all
plot(wave, rRefl, 'r');
plot(wave, gRefl, 'g');
plot(wave, wRefl, 'k');
plot(wave, wRefl2, 'b');
%}

%% Material list
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
%% Load light SPD
lghtAsset = thisR.get('asset', 'AreaLight_O');
lightShape = lghtAsset.lght{1}.shape;

areaLight = piLightCreate('type', 'area');
lightName = 'BoxLampSPD';
areaLight = piLightSet(areaLight, [], 'lightspectrum', lightName);
areaLight = piLightSet(areaLight, [], 'spectrum scale', 3e-1);
areaLight = piLightSet(areaLight, [], 'shape', lightShape);
thisR.set('asset', 'AreaLight_O', 'lght', areaLight);

%% Write and render
piWrite(thisR);

% Render 
[oi, result] = piRender(thisR, 'render type', 'radiance');
oi = oiSet(oi, 'name', 'CBLens_first_attempt');


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

oiWindow(oi);
oiSet(oi, 'gamma', 0.5);
%% Save oi
oiSavePath = fullfile(cboxRootPath, 'local', 'CBLens_first_attempt.mat');
save(oiSavePath, 'oi');