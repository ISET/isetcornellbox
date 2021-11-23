% vignettingFittingIntSphere
% 
% Fit the lens vignetting with the slope of integrating sphere
% Used to generate lens vignetting figures.

% Note: the estimated offset and slope was for camera focused at 0.55 m
%% Init
ieInit;

%% Param specification
% Resolution of image
width = 4032; height = 3024;

%%

dataDir = fullfile(cboxRootPath, 'local', 'measurement', 'integratingsphere',...
                                 'dc_p55_pos1', 'res');
dataName = 'offset_slope_dc_p55_pos1.mat';

load(fullfile(dataDir, dataName));

% ieNewGraphWin; imagesc(slopeMapG1);
%% Fit for green channel
slopeMapG1Resample = imresize(slopeMapG1, [height, width]/2);

[lensVignetG1Norm, lensVignetG1] = cbVignettingFitting(slopeMapG1Resample);
%{
ieNewGraphWin; imagesc(lensVignetG1Norm)
%}

pixel4aLensVignetSlope = imresize(lensVignetG1Norm, [height, width]);

%{
% Evaluation
rows = uint16(linspace(1, size(lensVignetG1, 1), 6));
ieNewGraphWin;
for ii = 1:numel(rows)
hold all;
plot(double(slopeMapG1Resample(rows(ii),:))/max(lensVignetG1(:))/2^10, 'b.');  
plot(lensVignetG1Norm(rows(ii), :), 'r-', 'LineWidth', 5);
end
box on; grid on; 
xlabel('Position'); ylabel('Slope (dv/sec)');
xlim([0 2016]);
%}

%{
% Generate figure
ieNewGraphWin; imagesc(pixel4aLensVignetSlope); axis off; colormap('gray');
colorbar; caxis([0.3 1])
%}



%% Fit for red and blue channel
slopeMapRResample = imresize(slopeMapR, [height, width]/2);
[lensVignetRNorm, lensVignetR] = cbVignettingFitting(slopeMapRResample, 'channel', 'R');
pixel4aLensVignetSlopeR = imresize(lensVignetRNorm, [height, width]);

slopeMapBResample = imresize(slopeMapB, [height, width]/2);
[lensVignetBNorm, lensVignetB] = cbVignettingFitting(slopeMapBResample, 'channel', 'B');
pixel4aLensVignetSlopeB = imresize(lensVignetBNorm, [height, width]);

%{
% Generate figure
ieNewGraphWin; imagesc(pixel4aLensVignetSlopeR); axis off; colormap('gray');
colorbar; caxis([0.3 1])

ieNewGraphWin; imagesc(pixel4aLensVignetSlopeB); axis off; colormap('gray');
colorbar; caxis([0.3 1])
%}
% Check the difference
%{
% Generate figure
ieNewGraphWin; imagesc(abs(pixel4aLensVignetSlopeR-pixel4aLensVignetSlope)./ pixel4aLensVignetSlope* 100)
axis off; colormap('gray'); c = colorbar; c.Ruler.TickLabelFormat='%g%%';
caxis([0 5])

ieNewGraphWin; imagesc(abs(pixel4aLensVignetSlopeB-pixel4aLensVignetSlope)./pixel4aLensVignetSlope * 100)
axis off; colormap('gray'); c = colorbar; c.Ruler.TickLabelFormat='%g%%';
caxis([0 5])

%}

%% Save results
fName = 'p4aLensVignet_dc_p55_pos1.mat';
savePath = fullfile(dataDir, fName);
save(savePath, 'pixel4aLensVignetSlope');

