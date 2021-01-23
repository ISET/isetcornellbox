% s_cbSlantedEdge
% Real image
filePath = fullfile(cboxRootPath, 'local', '20210105', 'resolution_targets');

%% Distance 1
% Focus back
filePathB = fullfile(filePath, 'distance_1', 'focus_back_1',...
                            'IMG_20210105_181903.dng');
[sensorB1, infoB1, ipB1] = cbDNGRead(filePathB, 'demosaic', true);
ieAddObject(sensorB1);
ipWindow(ipB1);
% Focus front
filePathF = fullfile(filePath, 'distance_1', 'focus_front_1',...
                            'IMG_20210105_182112.dng');
[sensorF1, infoF1, ipF1] = cbDNGRead(filePathF, 'demosaic', true);
ieAddObject(sensorF1);
sensorWindow(sensorF1);
ipWindow(ipF1);

%% Distance 2
%% Focus back2
filePathB = fullfile(filePath, 'distance_2', 'focus_back_2',...
                            'IMG_20210105_182348.dng');
[sensorBack2, infoBack2, ipBack2] = cbDNGRead(filePathB, 'demosaic', true);
ieAddObject(sensorBack2);
ipWindow(ipBack2);

%% Distance 3
% Focus front3
filePathF3 = fullfile(filePath, 'distance_3', 'focus_front_3_3',...
                            'IMG_20210105_183804.dng');
[sensorB3, infoB3, ipB3] = cbDNGRead(filePathF3, 'demosaic', true);
ieAddObject(sensorB3);
sensorWindow(sensorB3);
ipWindow(ipB3);

%%
fName = 'IMG_20210106_171618.dng';
[sensor4, info4, ip4] = cbDNGRead(fName, 'demosaic', true);

ipWindow(ip4);
%%
fName = 'IMG_20210106_171803.dng';
[sensor5, info5, ip5] = cbDNGRead(fName, 'demosaic', true);

ipWindow(ip5);

%% focus 30 cm 0.4s
fName = 'IMG_20210106_171912.dng';
[sensor6, info6, ip6] = cbDNGRead(fName, 'demosaic', true);

ipWindow(ip6);

%% focus in the front 1s exp
fName = 'IMG_20210105_183620.dng';
[sensor7, info7, ip7] = cbDNGRead(fName, 'demosaic', true);

ipWindow(ip7);

%% focus in the front 0.2 exp (used)
fName = 'IMG_20210106_171803.dng';
[sensor9, info9, ip9] = cbDNGRead(fName, 'demosaic', true);
ieAddObject(sensor9);
ipWindow(ip9);
[roiLocs,roi] = ieROISelect(ip9);

roiInt = round(roi.Position);
barImage = vcGetROIData(ip9,roiInt,'sensor space');
c = roiInt(3)+1;
r = roiInt(4)+1;
barImage = reshape(barImage,r,c,3);
% vcNewGraphWin; imagesc(barImage(:,:,1)); axis image; colormap(gray);

% Run the ISO 12233 code.
dx = sensorGet(sensor,'pixel width','mm');

% ISO12233(barImage, deltaX, weight, plotOptions)
mtfData = ISO12233(barImage, dx, [], 'luminance');




