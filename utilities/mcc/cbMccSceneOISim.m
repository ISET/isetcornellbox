function [scene, oi] = cbMccSceneOISim(varargin)
% Create a simulated macbeth image scene and oi
%
% The OI is the the sensor irradiance we expect.
%
% See also
%

varargin = ieParamFormat(varargin);
p = inputParser;
p.addParameter('illuminant', '20201023-illA-Average.mat', @ischar);
p.addParameter('wave', 400:10:700, @isvector);
p.addParameter('patchsize', 32, @isnumeric);
p.addParameter('mccname', 'MiniatureMacbethChart', @ischar);
p.parse(varargin{:});
illuminant = p.Results.illuminant;
wave       = p.Results.wave;
patchSize  = p.Results.patchsize;
mccName    = p.Results.mccname; 

%% Compute scene and oi

% MCC scene
scene = sceneCreate('macbeth', patchSize, wave,...
                        mccName, true);
scene = sceneSet(scene, 'fov', sceneGet(scene, 'fov') * 2);
preserveMean = false;
scene = sceneAdjustIlluminant(scene, illuminant, preserveMean);
scene = sceneSet(scene, 'name', illuminant);

% MCC oi - we skip all lens vignetting effects
oi = oiCreate('default');
oi = oiSet(oi, 'bitdepth', 64);
oi = oiSet(oi,'optics offaxis method','skip');
oi = oiCompute(oi, scene);
oi = oiSet(oi, 'name', illuminant);

end