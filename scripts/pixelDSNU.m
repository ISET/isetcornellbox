%% init
ieInit;

%% specify file path
dirPath = fullfile(isetRootPath, 'local', 'dsnu_20201024', '*.dng');

files = dir(dirPath);

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

%% Extract blacklevel
blackLvl = mean(infoList2{1}.BlackLevel);

%% For each image, calculate the average digital value and std
% A very helpful description that helps me understand why dsnu is not
% purely time dependent is:
%{
https://harvestimaging.com/blog/?p=814
It should be noted that the dark-signal itself can be composed out of :
    - a thermal component, which will depend on the temperature and on the 
      exposure time.  The thermal component will be present on pixel level,

    – an electrical component, which is independent on the exposure time 
      and almost independent on the temperatue.  This electrical component 
      is due to threshold variations, gain variations and other 
      imperfections in the electronic circuits.  
      It can be present on pixel, column and row level.
%}

% Mean of signal = offset + D_t * expTime + D_nt;
% Assuming Signal follows: x = offset + randn * dsnu = offset + randn * (dsnu_t * t + dsnu_nt);
% x = mean of signal - D_t * expTime - D_nt + randn * (dsnu_t * t + dsnu_nt);
% So x ~ norm(mean of signal - D_t * expTime - D_nt, (dsnu_t * t + dsnu_nt)^2)
% The std of x is dsnu_t * t + dsnu_nt.


avgRawImg = zeros(1, numel(files));
dsnu = zeros(1, numel(files));
for ii = 1:numel(rawImg)
    avgRawImg(ii) = mean(rawImg{ii}(:));
    dsnu(ii) = std(double(rawImg{ii}(:)));
end

% Check the dark current rate
P = polyfit(expTimes, avgRawImg, 1);
avgRawImgEst = expTimes * P(1) + P(2);

ieNewGraphWin;
hold all;
plot(expTimes, avgRawImg,'-ro');
plot(expTimes, avgRawImgEst, '-bo');
legend('Captured', 'Est')

% Check the dsnu component:
ieNewGraphWin;
hold all;
plot(expTimes, dsnu, 'o');

%%
tmp = ((double(rawImg{ii}(:)) - avgRawImg(ii))) / expTimes(ii);

histogram(tmp, 'BinLimits', [-0.5 0.5])
%% Another way of examine
