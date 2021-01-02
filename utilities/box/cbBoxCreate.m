function thisR = cbBoxCreate(varargin)
% Build basic cornell box scene with measured light and reflectance
%
% Synopsis:
%   thisR = cbBoxCreate
%
% Inputs:
%   N/A
%
% Returns:
%   thisR   - recipe of cornell box
%
%% Read recipe
thisR = piRecipeDefault('scene name', 'cornell box reference');
%% Remove current existing lights
piLightDelete(thisR, 'all');
%% Turn the object to area light
areaLight = piLightCreate('type', 'area');
lightName = 'cbox-lights-1';
areaLight = piLightSet(areaLight, [], 'lightspectrum', lightName);

assetName = 'AreaLight_O';
thisR.set('asset', assetName, 'obj2light', areaLight);
%{
wave = 400:10:700;
lgt = ieReadSpectra(lightName, wave);
ieNewGraphWin;
plot(wave, lgt);
%}
%% Load spetral reflectance
wave = 400:10:700;
refl = ieReadSpectra('cboxSurfaces', wave);
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
matList = {'LeftWall', 'RightWall', 'BackWall', 'TopWall',...
            'BottomWall', 'CubeLarge', 'CubeSmall'};
reflList = [rRefl gRefl wRefl wRefl wRefl wRefl wRefl];
for ii=1:numel(matList)
    thisR = cbAssignMaterial(thisR, matList{ii}, reflList(:, ii));
end
end