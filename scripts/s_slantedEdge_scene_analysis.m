% s_slantedEdge_scene_analysis
%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%%
load('CBLens_slantedEdge_scene_correct.mat', 'scene');

scene = sceneSet(scene, 'fov', 77);
scene = sceneSet(scene, 'distance', 0.5);
pSize = 1.4e-6;
%%
%{
% Apply diffuser blur
oi = oiCreate;
oi = oiSet(oi, 'diffuser method', 'blur');
oi = oiSet(oi, 'diffuser blur', [0.95e-6, 0.95e-6]);
oi = oiSet(oi, 'f number', 1.73);
oi = oiSet(oi, 'optics focal length', 0.00438);
%}
% {
wvf0 = wvfCreate;
% f-number
fNumber = 1.73;
fLength = 0.00438;
wvf0 = wvfSet(wvf0,'focal length', fLength);    % Meters
wvf0 = wvfSet(wvf0,'pupil diameter', fLength / fNumber * 1e3);     % Millimeters
wvf0 = wvfSet(wvf0, 'umperdegree', 78.5285);
% wvf0 = wvfSet(wvf0,'z pupil diameter', fLength / fNumber * 1e3);
wvf0 = wvfSet(wvf0,'zcoeffs',1,'defocus');
% We need to calculate the pointspread explicitly
wvf0 = wvfComputePSF(wvf0);

% Finally, we convert the wavefront representation to a shift-invariant
% optical image with this routine.

oi = wvf2oi(wvf0);
%}
oi = oiSet(oi, 'off axis method', 'skip');
%%
scene = sceneAdjustPixelSize(scene, oi, pSize);
oi = oiCompute(oi, scene);

rect = [506 379 4031 3023];
oiCp = oiCrop(oi, rect);
oiWindow(oiCp)
oiSet(oiCp, 'gamma', 0.5);
%%
fName = 'p4aLensVignette.mat';
load(fName, 'corrMapBNormUpSamp', 'corrMapBNorm');
oiCp.data.photons = oiCp.data.photons .* corrMapBNormUpSamp;
%%
sensor = sensorCreate('IMX363');
sensor = sensorSetSizeToFOV(sensor, oiGet(oiCp, 'fov'), oiCp);
sensor = sensorSet(sensor, 'noise flag', 2);
sensor = sensorSet(sensor, 'prnu sigma', 1.894);
sensor = sensorSet(sensor, 'dsnu sigma', 6.36e-4);
% Load sensor QE
wave = sensorGet(sensor, 'wave');
cf = ieReadSpectra('p4aCorrected.mat', wave);
sensor = sensorSet(sensor, 'color filters', cf);

sensor = sensorSet(sensor, 'exp time', 0.0141 * 1.2);
sensor = sensorCompute(sensor, oiCp);
% sensorWindow(sensor);
ieAddObject(sensor);
ip = ipCreate;
ip = ipSet(ip, 'render demosaic only', true);
ip = ipCompute(ip, sensor);
ipWindow(ip);
%% Select region for ISO12233
%{
[roiLocs,roi] = ieROISelect(ip);
roiInt = round(roi.Position);
%}
roiInt = [1977 1819 111 141];
barImage = vcGetROIData(ip,roiInt,'sensor space');
c = roiInt(3)+1;
r = roiInt(4)+1;
barImage = reshape(barImage,r,c,3);
% vcNewGraphWin; imagesc(barImage(:,:,1)); axis image; colormap(gray);

% Run the ISO 12233 code.
dx = sensorGet(sensor,'pixel width','mm');

% ISO12233(barImage, deltaX, weight, plotOptions)
mtfData = ISO12233(barImage, dx, [], 'luminance');
%% Focus at 30 cm, image is blurrier
oi2 = oi;
oi2 = oiSet(oi2, 'diffuser blur', [3.75e-6, 3.75e-6]);
oi2 = oiCompute(oi2, scene);
oiCp2 = oiCrop(oi2, rect);
% oiWindow(oiCp2)
% oiSet(oiCp2, 'gamma', 0.5);
%%
oiCp2.data.photons = oiCp2.data.photons .* corrMapBNormUpSamp;
%%
sensor2 = sensor;
sensor2 = sensorCompute(sensor2, oiCp2);
% sensorWindow(sensor);
ieAddObject(sensor2);
ip2 = ipCreate;
ip2 = ipSet(ip2, 'render demosaic only', true);
ip2 = ipCompute(ip2, sensor2);
ipWindow(ip2);

%% Select region for ISO12233
%{
[roiLocs,roi] = ieROISelect(ip2);
roiInt2 = round(roi.Position);
%}
roiInt2 = [2508 2354 110 142];
barImage = vcGetROIData(ip2,roiInt2,'sensor space');
c = roiInt2(3)+1;
r = roiInt2(4)+1;
barImage = reshape(barImage,r,c,3);
% vcNewGraphWin; imagesc(barImage(:,:,1)); axis image; colormap(gray);

% Run the ISO 12233 code.
dx = sensorGet(sensor,'pixel width','mm');

% ISO12233(barImage, deltaX, weight, plotOptions)
mtfData = ISO12233(barImage, dx, [], 'luminance');