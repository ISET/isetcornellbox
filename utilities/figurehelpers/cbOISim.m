function oi = cbOISim(varargin)
% Simulate the whole pipeline
%%
varargin = ieParamFormat(varargin);
p = inputParser;
p.addParameter('from', [0 0.125 -0.40], @isnumeric); % This is the place where we can see more
p.addParameter('to', [0 0.125, 0.6], @isnumeric); % The camera is horizontal%%
p.addParameter('resolution', [189 252], @isnumeric); % Original res: 3024 x 4032
p.addParameter('nraysperpixel', 128, @isnumeric);
p.addParameter('nbounces', 3, @isnumeric);
p.addParameter('label', 'CornellBox', @ischar);
p.parse(varargin{:});

from = p.Results.from;
to = p.Results.to;
resolution = p.Results.resolution;
nRaysPerPixel = p.Results.nraysperpixel;
nBounces = p.Results.nbounces;
label = p.Results.label;
%% Create Cornell Box recipe
thisR = cbBoxCreate('from', from, 'to', to);
%{
%% Adjust the position of the camera
% The origin is in the bottom center of the box, the depth of the box is 
% 30 cm, the camera is 25 cm from the front edge. The position of the 
% camera should be set to 25 + 15 = 40 cm from the origin
from = thisR.get('from');
newFrom = [0 0.115 -0.40];% This is the place where we can see more
thisR.set('from', newFrom);
newTo = newFrom + [0 0 1]; % The camera is horizontal
thisR.set('to', newTo);
%}

%% Add MCC
%{
assetTreeName = 'mccCB';
[~, rootST1] = thisR.set('asset', 'root', 'graft with materials', assetTreeName);
thisR.set('asset', rootST1.name, 'world rotate', [0 0 2]);
T1 = thisR.set('asset', rootST1.name, 'world translate', [0.012 0.003 0.125]);
%}
assetTreeNameMCC = 'mccCB';
mccCB = piAssetLoad(assetTreeNameMCC);
piRecipeMerge(thisR, mccCB.thisR, 'node name', mccCB.mergeNode);
thisR.set('asset', 'MCC_B', 'world position', [0 0.035,0.125]);
thisR.set('asset', 'MCC_B', 'world rotation', [0 0 2]);


%% Add bunny
assetTreeNameBunny = 'bunny';

bunnychart = piAssetLoad(assetTreeNameBunny);
% Merge bunny into the cornell box
piRecipeMerge(thisR,bunnychart.thisR,'node name',bunnychart.mergeNode);
bunnyMatName = thisR.get('assets', '001_Bunny_O', 'material name');

wave = 400:10:700;
refl = ieReadSpectra('cboxSurfaces', wave);
wRefl = refl(:, 3);
thisR = cbAssignMaterial(thisR, bunnyMatName, wRefl);

thisR.set('asset', '001_Bunny_O', 'world position', [0.095 0.059 0]);
thisR.set('asset', '001_Bunny_O', 'scale', 1.5);
% thisR.set('asset', bunnychart.mergeNode, 'world rotate', [0 -35 0]);
% thisR.assets.show
%}
%% Specify rendering settings
thisR.set('film resolution',resolution);
thisR.set('rays per pixel',nRaysPerPixel);
thisR.set('nbounces',nBounces);
thisR.set('fov', 50);
thisR.set('film diagonal', 7.056);
% Write and render
piWrite(thisR);
% Render
[scene, result] = piRender(thisR, 'render type', 'radiance', 'scale illuminance', false);
sceneName = label;
scene = sceneSet(scene, 'name', sceneName);
%{
sceneWindow(scene);
sceneSet(scene, 'gamma', 0.5);
%}
%% Create OI
oi = oiCreate;
oi = oiSet(oi, 'fov', 77);
oi = oiCompute(oi, scene);
% oiWindow(oi);



end