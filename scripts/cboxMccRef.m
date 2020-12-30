%% Load light spd
lightName = '';
lgt = ieReadSpectra(lightName);

%%

mccPath = fullfile(cboxRootPath, 'local', 'mcc-Day', '*.mat');
f = dir(mccPath);

refList = zeros(numel(lgt), numel(f));
for ii=1:numel(f)
    curName = f(ii).name;
    row = str2double(curName(1));
    col = str2double(curName(2));
    index = (col - 1) * 4 + row;
    thisRad = ieReadSpectra(curName);
    
    refList(:, ii) = thisRad ./ lgt;
end

%%