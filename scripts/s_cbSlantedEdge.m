% s_cbSlantedEdge
% Real image
filePath = fullfile(cboxRootPath, 'local', '20210105', 'resolution_targets');

%% Distance 1
% Focus back
filePathB = fullfile(filePath, 'distance_1', 'focus_back_1',...
                            'IMG_20210105_181903.dng');
[sensorR1, info1, ipR1] = cbDNGRead(filePathB, 'demosaic', true);
ieAddObject(sensorR1);
ipWindow(ipR1);
%{
[roiLocs,roi] = ieROISelect(ipR1);
roiInt1 = round(roi.Position);
%}
roiInt1 = [1685 1892 84 96];
barImage = vcGetROIData(ipR1,roiInt1,'sensor space');
c = roiInt1(3)+1;
r = roiInt1(4)+1;
barImage = reshape(barImage,r,c,3);
% vcNewGraphWin; imagesc(barImage(:,:,1)); axis image; colormap(gray);

% Run the ISO 12233 code.
dx = sensorGet(sensorR1,'pixel width','mm');

% ISO12233(barImage, deltaX, weight, plotOptions)
mtfData = ISO12233(barImage, dx, [], 'luminance');

%% focus in the front 0.2 exp (used)
fName = 'IMG_20210106_171803.dng';
[sensorR2, infoR2, ipR2] = cbDNGRead(fName, 'demosaic', true);
ieAddObject(sensorR2);
ipWindow(ipR2);
%{
[roiLocs,roi] = ieROISelect(ip9);
roiInt2 = round(roi.Position);
%}
roiInt2 = [1744 1691 155 247];
barImage = vcGetROIData(ipR2,roiInt2,'sensor space');
c = roiInt2(3)+1;
r = roiInt2(4)+1;
barImage = reshape(barImage,r,c,3);
% vcNewGraphWin; imagesc(barImage(:,:,1)); axis image; colormap(gray);

% Run the ISO 12233 code.
dx = sensorGet(sensor,'pixel width','mm');

% ISO12233(barImage, deltaX, weight, plotOptions)
mtfData = ISO12233(barImage, dx, [], 'luminance');




