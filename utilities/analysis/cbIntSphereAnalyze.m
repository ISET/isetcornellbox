function [offsetMap, slopeMap] = cbIntSphereAnalyze(meanLocalWindow, expTime)

%%
sz = size(meanLocalWindow{1});
offsetMap = zeros(sz);
slopeMap = zeros(sz);

for ii = 1:sz(1)
    for jj = 1:sz(2)
        thisData = zeros(1, numel(expTime));
        for kk = 1:numel(expTime)
            thisData(kk) = meanLocalWindow{kk}(ii, jj);
        end
        p = polyfit(expTime, thisData, 1);
        
        offsetMap(ii, jj) = p(2);
        slopeMap(ii, jj) = p(1);
    end
    if mod(ii, 100) == 0
        fprintf('Processing row: %d\n', ii)
    end
end

end