function [scene, oi] = cbMccSceneOISim(varargin)

%%
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
% scene
scene = sceneCreate('macbeth', patchSize, wave,...
                        mccName);
preserveMean = false;
scene = sceneAdjustIlluminant(scene, illuminant, preserveMean);
scene = sceneSet(scene, 'name', illuminant);

% oi
oi = oiCreate;
oi = oiCompute(oi, scene);
oi = oiSet(oi, 'name', illuminant);
end