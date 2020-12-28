%% cbLensCandidates
% A collection of potential lens model that can be used for pixel phone
% approximation. Also used for helping ZLY get familiar with isetlens.

%% Init
ieInit;

%% Basic
% This is a small number of numerical samples in the aperture.  
nSamples = 500;
apertureMiddleD = 10;   % mm, - Maximum aperture size

%% Create two lenses. Use the first lens for learning
% lensFileNameOne = 'reversed.telephoto.42deg.100mm.dat';
lensFileNameOne = 'dgauss.22deg.3.0mm.dat';
% lensFileNameOne = 'fisheye.87deg.12.5mm.json';
lensOne = lensC('filename', lensFileNameOne,...
                'apertureSample', [nSamples nSamples],...
                'apertureMiddleD', apertureMiddleD);
% lensOne.draw;
%{
% Light rays illustrate Cardinal points
%}
%{
lensFileNameTwo = 'reversed.telephoto.37deg.100mm.dat';
lensTwo = lensC('filename', lensFileNameTwo,...
                'apertureSample', [nSamples nSamples],...
                'apertureMiddleD', apertureMiddleD);
lensTwo.get('bbm', 'effectivefocallength')
lensTwo.draw;
%}
%{
%% Section: figure out focal length difference (DONE)
% Explanaiton: current lenC.focalLength is actually the image point for a
% point source in object space. Might change it(?)
lensOne.bbmCreate;
fl = lensOne.focalLength;
%}

%% Section: scale the focal length (DONE)
% Specify a desired lens
% https://www.dxomark.com/google-pixel-4a-camera-review-excellent-single-camera-smartphone/
% {
curFL = mean(lensOne.get('bbm', 'effective focal length'));
% https://www.edmundoptics.com/knowledge-center/application-notes/imaging/understanding-focal-length-and-field-of-view/
newFOV = 77; % Pixel phone rear camera
filmSz = 1.4 * 4000 / 1000; % mm

[scaleFactor, desiredFL] = lensOne.fovScale(newFOV, filmSz);
lensOne.scale(scaleFactor);
fovCheck = lensOne.get('fov', filmSz);
%}

%% Section: learn how the bbm works (PARTIALY DONE)
fL = lensOne.get('bbm', 'effectivefocallength');
imageFocalPoint = lensOne.get('bbm', 'imageFocalPoint');

%% Section: Modify estimatePSF function so that the ray trace can be visualized

% Ray trace the points to the film
%  Check that the points converge at some distance in front of the
%  sensor (to illustrate this convergence we place the sensor far away
%  from the lens).

% Create an on-center, far-away point
point = psCreate(0,0,-1e6);
pointTwo = psCreate(0, -1, -10);

wave = lensOne.get('wave');
sensor = filmC('position', [0 0 lensOne.focalLength], ...
    'size', [filmSz filmSz], ...
    'resolution',[300 300],...
    'wave', wave);
camera = psfCameraC('lens',lensOne,'film',sensor,'pointsource',pointTwo);
nLines = 100;
camera.estimatePSF('jitter flag',false, 'n line', nLines);

%{
%% Visualize PSF
oi = camera.oiCreate;
oiWindow(oi);
%}

%% Write out the lens file
lensName = strcat('dgauss.77deg.', num2str(desiredFL), 'mm.json');
fullName = fullfile(ilensRootPath, 'data', 'lens', lensName);
lensOne.fileWrite(fullName);

%%
lensTwo = lensC('file name', lensName);
lensTwo.draw;

%%
pointThree = psCreate(0, -1, -3);

wave = lensTwo.get('wave');
sensor = filmC('position', [0 0 lensTwo.focalLength], ...
    'size', [filmSz filmSz], ...
    'resolution',[300 300],...
    'wave', wave);
camera = psfCameraC('lens',lensTwo,'film',sensor,'pointsource',pointThree);
nLines = 200;
camera.estimatePSF('jitter flag',false, 'n line', nLines);
%% TODO: check aspherics structure