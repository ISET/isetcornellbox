function [res, mseFlat, msePoly] = isUniformPatch(patch, varargin)
%
% Synopsis:
%   res = isUniformPatch(patch, varargin)
%
% Inputs:
%   patch - a 2d patch
%
% Returns:
%   res   - whether it can be treated as uniform patch or not
%
% Description:
%   Determine whether a patch can be treated as an uniform patch. The judge
%   is done by fitting the patch in two ways: one is a constant surface (flat)
%   or a 2D polynomial. 20% of the point will be taken out in advance for
%   cross-validation.

%%
p = inputParser;
p.addRequired('patch', @isnumeric);
p.parse(patch, varargin{:});

patch = p.Results.patch;

%%
[h, w] = size(patch);
xNorm = ((1:w) - w/2)/(w/2); yNorm = ((1:h) - h/2)/(h/2);
[xxNorm, yyNorm] = meshgrid(xNorm, yNorm);

% Determine the point to be used for validation
valInd = randi([1, h * w], [1, floor(0.2 * h * w)]);

% For constant surface, it will be the mean
flatSurface = mean(patch(setdiff(1:numel(patch), valInd)));

polySurface = fit([xxNorm(:), yyNorm(:)], patch(:), 'poly22',...
                                                'Exclude', valInd);
d = reshape(polySurface([xxNorm(:), yyNorm(:)]), h, w);
% ieNewGraphWin; plot(polySurface, [xxNorm(:), yyNorm(:)], patch(:));
polyVal = d(valInd);

%% Compute the MSE and decide
mseFlat = sqrt(sum((patch(valInd) - flatSurface).^2));
msePoly = sqrt(sum((patch(valInd) - polyVal).^2));

if mseFlat <= msePoly * 1.10 % Give some tolerance
    res = true;
else
    res = false;
end


    

