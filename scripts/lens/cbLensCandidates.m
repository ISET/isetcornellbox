%% cbLensCandidates
% A collection of potential lens model that can be used for pixel phone
% approximation. Also used for helping ZLY get familiar with isetlens.

%% Init
ieInit;

%% Create two lenses
lensFileNameOne = 'reversed.telephoto.42deg.100mm.dat';
thislens = lensC('filename', lensFileNameOne);
thislens.draw;

lensFileNameTwo = 'reversed.telephoto.37deg.100mm.dat';
thislens2 = lensC('filename', lensFileNameTwo);
thislens2.draw;

%% Use the first lens to get myself familiar with isetlens

% Create an on-center, far-away point
point = psCreate(0,0,-10000); % Not sure where to use it.

% This is a small number of numerical samples in the aperture.  
nSamples = 351;
apertureMiddleD = 8;   % mm, - Maximum aperture size: How would this applied?

lensOne = lensC('apertureSample', [nSamples nSamples], ...
            'fileName', lensFileNameOne,...
            'apertureMiddleD', apertureMiddleD);

lensOne.draw
lens.bbmCreate;

%% Create a scaled lens
% Specify a desired lens
% https://www.dxomark.com/google-pixel-4a-camera-review-excellent-single-camera-smartphone/
desiredFL = 27; % mm. 

scaledLensOne = lensC('apertureSample', [nSamples nSamples], ...
            'fileName', lensFileNameOne,...
            'apertureMiddleD', apertureMiddleD);
scaleFactor = desiredFL / scaledLensOne.focalLength;

% Apply scaling
for ii = 1:numel(scaledLensOne.surfaceArray)
    scaledLensOne.surfaceArray(ii).sRadius = scaledLensOne.surfaceArray(ii).sRadius * scaleFactor;
    scaledLensOne.surfaceArray(ii).sCenter = scaledLensOne.surfaceArray(ii).sCenter * scaleFactor;
    scaledLensOne.surfaceArray(ii).apertureD = scaledLensOne.surfaceArray(ii).apertureD * scaleFactor;
end

scaledLensOne.bbmCreate;
scaledLensOne.focalLength = desiredFL;
scaledLensOne.name = sprintf('reversed.telephoto.42deg.%.1fmm', desiredFL);
scaledLensOne.draw

% Confirm focal length
fL = scaledLensOne.get('bbm', 'effectivefocallength');
imageFocalPoint = scaledLensOne.get('bbm', 'imageFocalPoint');

%% Ray trace the points to the film
%  Check that the points converge at some distance in front of the
%  sensor (to illustrate this convergence we place the sensor far away
%  from the lens).

wave = lens.get('wave');
sensor = filmC('position', [0 0 0], ...
    'size', [5 5], ...
    'resolution',[300 300],...
    'wave', wave);
camera = psfCameraC('lens',scaledLensOne,'film',sensor,'pointsource',point);
camera.estimatePSF(true);

%%
oi = camera.oiCreate;
oiWindow(oi);
oiPlot(oi,'illuminance mesh linear');