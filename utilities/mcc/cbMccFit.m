function L = cbMccFit(rgbMeanS, rgbMeanR, varargin)
%%
varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('rgbMeanS', @ismatrix);
p.addRequired('rgbMeanR', @ismatrix);
p.addParameter('method', '', @ischar);
p.parse(rgbMeanS, rgbMeanR, varargin{:});
method = p.Results.method;
%%
switch method
    case ''
        L = pinv(rgbMeanS) * rgbMeanR;
    case {'diag', 'diagonal'}
        L = eye(3);
        for ii=1:3
            L(ii, ii) = rgbMeanS(:, ii) \ rgbMeanR(:, ii);
        end
    case {'nonnegative'}
        sensor = sensorCreate('IMX363');
        cfS = sensorGet(sensor, 'color filters');
        % argmin_x = 0.5|Cx-d|^2 st Ax <= b
        C = rgbMeanS; d = rgbMeanR;
        A = -cfS; b = zeros(size(A, 1), 1);
        lb = zeros(size(A, 2), 1);
        x1 = lsqlin(C, d(:, 1), A, b, [], [], lb);
        x2 = lsqlin(C, d(:, 2), A, b, [], [], lb);
        x3 = lsqlin(C, d(:, 3), A, b, [], [], lb);
        L = [x1 x2 x3];
end