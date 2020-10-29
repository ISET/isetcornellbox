%% init
ieInit;

%% specify file path
dirPath = fullfile(isetRootPath, 'local', 'dsnu_20201025', '3s', 'meas1', '*.dng');

files = dir(dirPath);

num = 30;
dsnuArrays = zeros(1, num);
for ii = 1:num
thisFiles = files(1:ii);
%%
[rawImg, expTimes, infoList1, infoList2, avgImg, avgRawImg, dsnu] = dsnuAnalysis(thisFiles);
dsnuArrays(ii) = dsnu;

end
%{
ieNewGraphWin;
plot(avgRawImg);
title(sprintf('%d images, Exptime: %.4f s, Std: %.4f',ii, expTimes(1), dsnu))
%}

%%
ieNewGraphWin;
plot(dsnuArrays, '-o');
%{
files(avgRawImg < 64) = [];

%%
[rawImg, expTimes, infoList1, infoList2, avgImg, avgRawImg, dsnu] = dsnuAnalysis(files);

ieNewGraphWin;
plot(avgRawImg);

title(sprintf('Exptime: %.4f s, Std: %.4f', expTimes(1), dsnu))
%}

