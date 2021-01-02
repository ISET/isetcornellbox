%% Initialize ISET
ieInit;

%% 
img1 = 'IMG_20201212_112601_1.dng'; %% mcc image
img2 = 'IMG_20201211_141901_2.dng'; %% slanted bar
% rectRealPos = [426 164 3350 2698];
rectRealPos = [];
%% Read dng files
[sensorR1, infoR1, ipR1] = cbDNGRead(img1,...
                                    'crop', rectRealPos, 'demosiac', true);
[sensorR2, infoR2, ipR2] = cbDNGRead(img2,...
                                    'crop', rectRealPos, 'demosiac', true);

%% DV analysis
sensorPlot(sensorR1, 'dv hline', [1, 917]);

%% Check image processor
ipWindow(ipR1);
