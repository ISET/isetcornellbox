function [correctedQE, mTrans, rgbMeanSim, rgbMeanMeas] = cbQEAnalysis(imgNames, illuminants,...
                                              cropCornersMeas,...
                                              cropCornersSim,...
                                              vignetting, varargin)
%{
    imgNames = {'IMG_20201024_123128.dng', 'IMG_20201024_122900.dng',...
                'IMG_20201024_122631.dng'};
    illuminants = {'A', 'CWF', 'Day'};
    cropCornersMeas = {[38 222; 316 224; 314 41; 40 40],...
                       [62 218; 337 222; 337 38; 63 37],...
                       [73 218; 344 222; 344 39; 73 36]};
    roiRectsMeas = {[1860  2010  350  255],...
                    [1860  2010  370  290],...
                    [1860  2010  370  290]};
    cropCornerSim = [69 397; 536 401; 538 83; 66 80];
    tmp = load('p4aLensVignet.mat', 'pixel4aLensVignet');
    vignetting = tmp.pixel4aLensVignet;
    [correctedQE, mTrans] = cbQEAnalysis(imgNames, illuminants,...
                                         cropCornersMeas, roiRectsMeas,...
                                         cropCornerSim,...
                                         vignetting); 
%}
%%
%% parser
varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('imgNames', @iscell);
p.addRequired('illuminants', @iscell);
p.addRequired('cropCornersMeas', @iscell);
p.addRequired('cropCornersSim', @isnumeric); % Should be on the same location
p.addRequired('vignetting', @isnumeric);

p.addParameter('patchsize', 32, @isnumeric);
p.addParameter('method', 'nonnegative', @ischar);
p.addParameter('fluoremove', false, @islogical);
p.parse(imgNames, illuminants, cropCornersMeas,...
            cropCornersSim, vignetting, varargin{:});
patchSize = p.Results.patchsize;
method = p.Results.method;
fluoremove = p.Results.fluoremove;
%%
nFrames = numel(imgNames);

%% Precompute the illumination scene and oi
wave = 390:10:710;
% In isetcalibrate/data/mcc
% lightNameA   = '20201023-illA-Average.mat'; % Tungsten (A)
lightNameA   = 'illA-20201023.mat'; % Tungsten (A)
lightNameCWF = 'illCWF-20201023.mat'; % CWF
lightNameDay = 'illDay-20201023.mat'; % Daylight

[sceneA, oiA] = cbMccSceneOISim('illuminant', lightNameA, 'wave', wave,...
                                'patch size', patchSize);
[sceneCWF, oiCWF] = cbMccSceneOISim('illuminant', lightNameCWF, 'wave', wave,...
                                'patch size', patchSize);       
[sceneDay, oiDay] = cbMccSceneOISim('illuminant', lightNameDay, 'wave', wave,...
                                'patch size', patchSize); 

%{
sceneWindow(sceneA);
sceneWindow(sceneCWF);
sceneWindow(sceneDay);
%}
%%
rgbMeanMeas = zeros(nFrames * 24, 3);
rgbMeanSim = zeros(nFrames * 24, 3);

for ii=1:numel(imgNames)
    thisCropMeas = cropCornersMeas{ii};
    thisIllu = illuminants{ii};
    % Get the mean rgb for this sensor
    [thisSensorMeas, thisInfo, thisRGBMeanMeas, ~] = cbMccChipsDV(imgNames{ii},...
                                                              'corner point', thisCropMeas,...
                                                              'vignetting', vignetting);
    if fluoremove
        fluoInd = [3 6 10 11 14 19];
        thisRGBMeanMeas(fluoInd,:) = 0;
    end
    % Pad the rgb meas values
    rgbMeanMeas((ii-1) * 24+1:ii*24,:) = thisRGBMeanMeas;
    
    %% Simulate corresponding sensor response
    thisSensorSim = thisSensorMeas;
    switch ieParamFormat(thisIllu)
        case 'a'
            oi = oiA;
        case 'cwf'
            oi = oiCWF;
        case {'day', 'daylight'}
            oi = oiDay;
    end
    [thisSensorSim, thisRGBMeanSim, ~] = cbMccSensorSim(oi, thisSensorSim, cropCornersSim);
    
    if fluoremove
        fluoInd = [3 6 10 11 14 19];
        thisRGBMeanSim(fluoInd,:) = 0;
    end
    
    % Pad the rgb sim values
    rgbMeanSim((ii-1) * 24+1:ii*24,:) = thisRGBMeanSim;
end




mTrans = cbMccFit(rgbMeanSim, rgbMeanMeas, 'method', method);
% cbMccPredEval('measurement', rgbMeanMeas, 'prediction', min(rgbMeanSim * mTrans, 1024));
correctedQE = [];
%%
end