%% Basic settings
% This is a small number of numerical samples in the aperture.  
nSamples = 500;
apertureMiddleD = 10;   % mm, - Maximum aperture size
% Target focal length, from p4a DNG file
targetFL = 4.38; % mm
targetFOV = 77;  % deg

%%
% lensName = 'mobile.76deg.4.4mm.json';
% lensName = 'wide.56deg.3.0mm.json';
lensName = 'Dogmar.first.json';
lensOne = lensC('filename', lensName);
lensOne.draw
% {
fullName = fullfile(cboxRootPath, 'data', 'lens', lensName);
lensOne.fileWrite(fullName);
%}

%{
% Create an on-center, far-away point
point = psCreate(0,0,-1e6);
wave = lensOne.get('wave');
sensor = filmC('position', [0 0 lensOne.focalLength], ...
    'size', [8 8], ...
    'resolution',[300 300],...
    'wave', wave);
camera = psfCameraC('lens',lensOne,'film',sensor,'pointsource',point);
nLines = 100;
camera.estimatePSF('jitter flag',false, 'n line', nLines);
%}