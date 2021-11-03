function [mccTemplate, deltaEMap] = mccPatchCompare(imgL, imgS, rectL, rectS,varargin)

%%
varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('imgL', @isnumeric);
p.addRequired('imgS', @isnumeric);
p.addRequired('rectL', @isnumeric);
p.addRequired('rectS', @isnumeric);
p.addParameter('patchsize', 32, @isscalar);
p.parse(imgL, imgS, rectL, rectS, varargin{:});

patchSize = p.Results.patchsize;

%%
mccTemplate = zeros(patchSize * 4, patchSize * 6, 3);
cnt = 1;
deltaEMap = zeros(patchSize * 4, patchSize * 6);

for ii=1:6
    cStart = (ii-1) * patchSize + 1;
    for jj=1:4
        thisPatchL = imcrop(imgL, rectL(cnt,:));
        meanPatchL = mean(thisPatchL, [1, 2]);
        thisPatchL = imresize(meanPatchL, [patchSize, patchSize]);
        rStart = (jj-1) * patchSize + 1;
        mccTemplate(rStart:rStart + patchSize-1, cStart:cStart + patchSize-1,:)=thisPatchL;
        
        thisPatchS = imcrop(imgS, rectS(cnt,:));
        meanPatchS = mean(thisPatchS, [1, 2]);
        thisPatchS = imresize(meanPatchS, [patchSize, patchSize]/2);
        mccTemplate(rStart+patchSize/2:rStart + patchSize-1, cStart+patchSize/2:cStart + patchSize-1,:)=thisPatchS;
        
        %% Calculate DeltaE
        LABPatchL = squeeze(xyz2lab(srgb2xyz(meanPatchL)))';
        LABPatchS = squeeze(xyz2lab(srgb2xyz(meanPatchS)))';
        dE00 = deltaE2000(LABPatchL, LABPatchS);
        thisDE = imresize(dE00, [patchSize, patchSize]);
        deltaEMap(rStart:rStart + patchSize-1, cStart:cStart + patchSize-1) = thisDE;
        
        cnt = cnt + 1;
    end
end
% ieNewGraphWin; imagesc(mccTemplate);
%%
end