function [rawImg, expTimes, infoList1, infoList2, avgImg, avgRawImg, dsnu] = dsnuAnalysis(files)

%% Load in the files
rawImg = cell(1, numel(files));
infoList1 = cell(1, numel(files));
infoList2 = cell(1, numel(files));
expTimes = zeros(1, numel(files));
for ii = 1:numel(rawImg)
    thisImgPath = fullfile(files(ii).folder, files(ii).name);
    rawImg{ii} = dcrawRead(thisImgPath);
    infoList1{ii} = dcrawInfo(thisImgPath);
    infoList2{ii} = imfinfo(thisImgPath);
    expTimes(ii) = infoList2{ii}.ExposureTime;
end

%% Check std for one frame
avgRawImg = zeros(1, numel(files));
avgImg = zeros(size(rawImg{1}));
for ii = 1:numel(rawImg)
    avgRawImg(ii) = mean(double(rawImg{ii}(:)));
    avgImg = avgImg + double(rawImg{ii});
end

avgImg = avgImg / (numel(rawImg));
dsnu = std(avgImg(:));

end