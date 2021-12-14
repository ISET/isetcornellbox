function thisR = cbAssignMaterial(thisR, mat, refl, varargin)
% Use measured reflectance on Cornell Box surface
% 
% Synopsis:
%   thisR = cbAssignMaterial(thisR, mat, refl, varargin)
%
% Brief description:
%   Assume matte materials in Cornell Box   
%
% Inputs:
%   thisR   - recipe
%   mat     - material name
%   refl    - reflectance
%
% Optional key/val pair:
%   wave    - sample wavelength (Default: 400:10:700)
%
% Returns:
%   thisR   - recipe
%% Input parser
p = inputParser;
p.addRequired('thisR', @(x)isequal(class(x), 'recipe'));
p.addRequired('mat', @ischar);
p.addRequired('refl', @isvector);
p.addParameter('wave', 400:10:700, @isvector);
p.parse(thisR, mat, refl, varargin{:});
wave = p.Results.wave;

%% Check if wave and reflectance size match
if ~isequal(numel(wave), numel(refl))
    error('Size of wavelength: %d does not match size of reflectance: %d',...
                    numel(wave), numel(refl))
end

%%
curKdSPD = piMaterialCreateSPD(wave, refl);

switch ieParamFormat(mat)
    case {'cubelarge', 'cubesmall'}
        curKsSPD = 0.5 * piMaterialCreateSPD(wave, refl);
        newMat = piMaterialCreate(mat, 'type', 'uber',...
                        'kr value', curKsSPD,...
                        'kd value', curKdSPD);
    case {'leftwall', 'rightwall'}
        curKsSPD = 0.1 * piMaterialCreateSPD(wave, refl);
        newMat = piMaterialCreate(mat, 'type', 'uber',...
            'ks value', curKsSPD,...
            'kd value', curKdSPD);
    case {'bunnymat'}
        curKsSPD = 0.01 * piMaterialCreateSPD(wave, refl);
        newMat = piMaterialCreate(mat, 'type', 'uber',...
                        'kr value', curKsSPD,...
                        'kd value', curKdSPD);
    case {'shieldmat'}
        newMat = piMaterialCreate(mat, 'type', 'matte', 'kd value', curKdSPD);
    otherwise
        newMat = piMaterialCreate(mat, 'type', 'matte', 'kd value', curKdSPD);
end

thisR.set('material', mat, newMat);

% Print info
fprintf('Assigned reflectance to: %s\n', mat);
end