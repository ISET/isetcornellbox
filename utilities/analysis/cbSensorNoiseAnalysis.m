function [stdMedian, coverList, meanMedian,indexBin] = cbSensorNoiseAnalysis(meanData, stdData, edges)

[counts, ~, bins] = histcounts(meanData, edges);
% Indicies in each bin
valididx = reshape(find(bins), [], 1);
indexBin = accumarray( reshape(bins(valididx), [], 1), valididx, [], @(V){V.'});

stdMedian = zeros(1, numel(edges)-1);
meanMedian = zeros(1, numel(edges)-1);
coverList = zeros(2, numel(edges)-1); % Coverage

for ii=1:numel(edges)
    if ii>numel(indexBin) || isempty(indexBin{ii})
        continue;
    end
    thisMeanList = meanData(indexBin{ii});
    thisStdList = stdData(indexBin{ii});
    stdMedian(ii) = median(thisStdList);
    meanMedian(ii) = mean(thisMeanList);
    % Calculate 90% coverage
    stdSorted = sort(thisStdList);
    beginInd = ceil(numel(stdSorted)*0.05);
    endInd = floor(numel(stdSorted)*0.95);
    coverList(1,ii) = stdSorted(beginInd);
    coverList(2, ii)= stdSorted(endInd);
end
end