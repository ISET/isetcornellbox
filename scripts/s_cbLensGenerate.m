% s_cbLensGenerate
%% Init
ieInit;

%% Basic settings
% This is a small number of numerical samples in the aperture.  
nSamples = 500;
apertureMiddleD = 1.5; 

% Target focal length, from p4a DNG file
targetFL = 4.38; % mm
targetFOV = 77;  % deg
%% Lens option 1
% A double gaussian lens
lensFileName1 = 'dgauss.22deg.3.0mm.json';
% Create lens
lensOne = lensC('filename', lensFileName1,...
                'apertureSample', [nSamples nSamples],...
                'apertureMiddleD', apertureMiddleD);
% lensOne.draw;
% Get current focal length
curFL = mean(lensOne.get('bbm', 'effective focal length'));
lensOne.scale(targetFL / curFL);
% Get required film size
filmSz = mean(lensOne.filmSizeFromFOV(targetFOV));
% Check fov
fovCheck = lensOne.get('fov', filmSz);
% Check focal length
flCheck = lensOne.get('bbm', 'effectivefocallength');
apertureMiddleD = 1.5;            
lensOne.set('middleaperturediameter', apertureMiddleD);
%{
% Create an on-center, far-away point
point = psCreate(0,0,-1e6);
wave = lensOne.get('wave');
sensor = filmC('position', [0 0 lensOne.focalLength], ...
    'size', [filmSz filmSz], ...
    'resolution',[300 300],...
    'wave', wave);
camera = psfCameraC('lens',lensOne,'film',sensor,'pointsource',point);
nLines = 100;
camera.estimatePSF('jitter flag',false, 'n line', nLines);
%}
% Save lens
lensName = sprintf('dgauss.%ddeg.%.2fmm.json', targetFOV, targetFL);
fullName = fullfile(cboxRootPath, 'data', 'lens', lensName);
lensOne.fileWrite(fullName);

%% Lens option 2
% Wide angle lens
lensFileName2 = 'wide.56deg.3.0mm.json';
% Create lens
lensTwo = lensC('filename', lensFileName2,...
                'apertureSample', [nSamples nSamples],...
                'apertureMiddleD', apertureMiddleD);
            % Get current focal length
curFL = mean(lensTwo.get('bbm', 'effective focal length'));
lensTwo.scale(targetFL / curFL);
% Get required film size
filmSz = mean(lensTwo.filmSizeFromFOV(targetFOV));
% Check fov
fovCheck = lensTwo.get('fov', filmSz);
% Check focal length
flCheck = lensTwo.get('bbm', 'effectivefocallength');
apertureMiddleD = 1.5;            
lensTwo.set('middleaperturediameter', apertureMiddleD);
%{
% Create an on-center, far-away point
point = psCreate(0,0,-1e6);
wave = lensTwo.get('wave');
sensor = filmC('position', [0 0 lensTwo.focalLength], ...
    'size', [filmSz filmSz], ...
    'resolution',[300 300],...
    'wave', wave);
camera = psfCameraC('lens',lensTwo,'film',sensor,'pointsource',point);
nLines = 100;
camera.estimatePSF('jitter flag',false, 'n line', nLines);
%}
lensName = sprintf('wide.%ddeg.%.2fmm.json', targetFOV, targetFL);
fullName = fullfile(cboxRootPath, 'data', 'lens', lensName);
lensTwo.fileWrite(fullName);

%% Lens option 3
% Dogmar lens
lensFileName3 = 'Dogmar.first.json';
% Create lens
lensThree = lensC('filename', lensFileName3,...
                'apertureSample', [nSamples nSamples],...
                'apertureMiddleD', apertureMiddleD);
            % Get current focal length
curFL = mean(lensThree.get('bbm', 'effective focal length'));
lensThree.scale(targetFL / curFL);
% Get required film size
filmSz = mean(lensThree.filmSizeFromFOV(targetFOV));
% Check fov
fovCheck = lensThree.get('fov', filmSz);
% Check focal length
flCheck = lensThree.get('bbm', 'effectivefocallength');
apertureMiddleD = 1.5;            
lensThree.set('middleaperturediameter', apertureMiddleD);
lensThree.draw;
%{
% Create an on-center, far-away point
point = psCreate(0,0,-1e6);
wave = lensThree.get('wave');
sensor = filmC('position', [0 0 lensThree.focalLength], ...
    'size', [filmSz filmSz], ...
    'resolution',[300 300],...
    'wave', wave);
camera = psfCameraC('lens',lensThree,'film',sensor,'pointsource',point);
nLines = 100;
camera.estimatePSF('jitter flag',false, 'n line', nLines);
%}
lensName = sprintf('dogmar.%ddeg.%.2fmm.json', targetFOV, targetFL);
fullName = fullfile(cboxRootPath, 'data', 'lens', lensName);
lensThree.fileWrite(fullName);

%% Lens option 4
% Dogmar lens
lensFileName4 = 'tessar.test.json';
% Create lens
lensFour = lensC('filename', lensFileName4,...
                'apertureSample', [nSamples nSamples],...
                'apertureMiddleD', apertureMiddleD);
            % Get current focal length
curFL = mean(lensFour.get('bbm', 'effective focal length'));
lensFour.scale(targetFL / curFL);
% Get required film size
filmSz = mean(lensFour.filmSizeFromFOV(targetFOV));
% Check fov
fovCheck = lensFour.get('fov', filmSz);
% Check focal length
flCheck = lensFour.get('bbm', 'effectivefocallength');           
lensFour.set('middleaperturediameter', apertureMiddleD);
lensFour.draw;
%{
% Create an on-center, far-away point
point = psCreate(0,0,-1e6);
wave = lensFour.get('wave');
sensor = filmC('position', [0 0 lensFour.focalLength], ...
    'size', [filmSz filmSz], ...
    'resolution',[300 300],...
    'wave', wave);
camera = psfCameraC('lens',lensFour,'film',sensor,'pointsource',point);
nLines = 100;
camera.estimatePSF('jitter flag',false, 'n line', nLines);
%}
lensName = sprintf('tessar.test.%ddeg.%.2fmm.json', targetFOV, targetFL);
fullName = fullfile(cboxRootPath, 'data', 'lens', lensName);
lensFour.fileWrite(fullName);