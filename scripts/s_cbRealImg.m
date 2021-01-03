%% Initialize ISET
ieInit;

%% 
img1 = 'IMG_20201212_112601_1.dng'; %% mcc image
img2 = 'IMG_20201211_141901_2.dng'; %% slanted bar
rectRealPos = [426 164 3350 2698];
% rectRealPos = [];
%% Read dng files
[sensorR1, infoR1, ipR1] = cbDNGRead(img1,...
                                    'crop', rectRealPos, 'demosiac', true);
[sensorR2, infoR2, ipR2] = cbDNGRead(img2,...
                                    'crop', rectRealPos, 'demosaic', true);

%% DV analysis
sensorPlot(sensorR1, 'dv hline', [1, 917]);

%% Check image processor
% {
ipWindow(ipR1);
ieAddObject(sensorR2);
ipWindow(ipR2);
%}

%% Get image data
ipR2Rot = ipRotate(ipR2);
ipWindow(ipR2Rot);

% Manually select slanted bar region
[roiLocs,roi] = ieROISelect(ipR2Rot);
mrect = round(roi.Position);
% Get bar image
barImage = vcGetROIData(ipR2Rot, mrect, 'sensor space');
c = mrect(3)+1; r = mrect(4)+1;
barImage = reshape(barImage,r,c,3);
% ieNewGraphWin; imagesc(barImage(:,:,1)); axis image; colormap(gray);

% Get pixel size
dx = sensorGet(sensorR2, 'pixel width', 'mm');

weight = [];
mtfData = ISO12233(barImage, dx, weight, 'none');

%% Plot mtfData
ieNewGraphWin;
c = {'r','g','b','k'};
for ii = 1:4
h = plot(mtfData.freq,mtfData.mtf(:, ii),['-',c{ii}]);
hold on
end
nfreq = mtfData.nyquistf;
l = line([nfreq ,nfreq],[0.1,0],'color',c{ii});
text(300, 0.8, sprintf('MTF50: %.2f', mtfData.mtf50), 'FontSize', 20);
xlabel('lines/mm');
ylabel('Relative amplitude');
title('MTF for different pixel sizes');
hold off; grid on

set(gca, 'xlim', [0 400], 'ylim', [0 1.5])

