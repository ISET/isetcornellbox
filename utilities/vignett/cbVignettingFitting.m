function [dataUpSNorm, dataUpS]= cbVignettingFitting(data, varargin)
%{

%}
%%
p = inputParser;
p.addRequired('data',@isnumeric);
p.addParameter('type', 'slope', @ischar); % slope or raw
p.addParameter('channel', 'G', @ischar)
p.parse(data, varargin{:});
type = p.Results.type;
channel = p.Results.channel;
%% Use matlab curve fitting toolbox
% Downsample the data, as the lens shading should be smooth
dataDownS = imresize(data,1/16);

% Normalize the data
dataDownS = double(dataDownS)/2^10;
[h, w] = size(dataDownS);
xNorm = ((1:w) - w/2)/(w/2); yNorm = ((1:h) - h/2)/(h/2);
[xxNorm, yyNorm] = meshgrid(xNorm, yNorm);
%
if isequal(type, 'slope')
    [~, gy] = gradient(dataDownS);
    switch channel 
        case 'G'
            excludedP = find(abs(gy) > 0.03);
        case 'R'
            excludedP = find(abs(gy) > 0.01);
        case 'B'
            excludedP = find(abs(gy) > 0.02);
    end
        
else
    excludedP = [];
end
% Use 10 samples as K nearest neighbour fitting
span = 10; spanPerc = span/(h * w);
% Local fitting algorithm lowess
sf = fit([xxNorm(:), yyNorm(:)], dataDownS(:), 'lowess', 'Span', spanPerc,...
                                                'Exclude', excludedP);
% plot(sf, [xxNorm(:), yyNorm(:)], data(:))
d = reshape(sf([xxNorm(:), yyNorm(:)]), h, w);

% Upsampling it back to original size
dataUpS = imresize(d, size(data));
dataUpSNorm = dataUpS/max(dataUpS(:));
%{
% Evaluation
thisRow = uint8(linspace(1, size(data, 1), 20));
ieNewGraphWin;
for ii = 1:numel(thisRow)
plot(double(data(thisRow(ii),:))/2^10, 'b.'); hold on; 
plot(dataUpS(thisRow(ii), :), 'r-', 'LineWidth', 5);
end

ieNewGraphWin; imagesc(dataUpSNorm);
%}

%}

%% Deprecated methods.
%{
data = double(data)/2^10;
[h, w] = size(data);
xNorm = ((1:w) - w/2); yNorm = ((1:h) - h/2);
[xxNorm, yyNorm] = meshgrid(xNorm, yNorm);
yxCorrd = [yyNorm(:), xxNorm(:)];
dataVec = data(:);
polynomialDeg = 4;
sf = polyfitn(yxCorrd, dataVec, polynomialDeg);

res = reshape(polyvaln(sf, yxCorrd), h, w);

ieNewGraphWin; plot(res(100, :)); hold on; plot(data(100,:));
%}
%{
data = double(data)/2^10;

x = double((1:size(data,2))-size(data,2)/2)/(size(data,2)/2);
y = double((1:size(data,1))-size(data,1)/2)/(size(data,1)/2)*size(data,1)/size(data,2);

[X, Y] = meshgrid(x,y);
XY(:,:,1) = X;
XY(:,:,2) = Y;

fitX = X(1:samplerate:end,1:samplerate:end);
fitY = Y(1:samplerate:end,1:samplerate:end);
fitZ = data(1:samplerate:end,1:samplerate:end);
fitXY(:,:,1) = fitX;
fitXY(:,:,2) = fitY;

%     fun = @(A,fitXY)(A(1)+A(2)*cos(sqrt((fitXY(:,:,1).^2+fitXY(:,:,2).^2)/A(3))));
fun = @(A,fitXY)(A(1)+A(2)*(A(3)./(fitXY(:,:,1).^2+fitXY(:,:,2).^2+A(3))).^2);
[A, resnorm, residual] = lsqcurvefit(fun, [max(fitZ(:)) 0.1 5], fitXY, fitZ);

corrMap = fun(A, XY);
corrMap = corrMap * 2^10;
data = data * 2^10;
error = sqrt(immse(data, corrMap));
corrMapNorm = corrMap / max(corrMap(:));
%}
end