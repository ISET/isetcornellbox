dngpath = '/home/zhenglyu/Desktop/git/isetcornellbox/local/measurement/noise/darkcurrent/ISO_55';

fileList = dir(fullfile(dngpath,'*.dng'));

exposures = [];
for ii=1:numel(fileList)
    [~, info] = sensorDNGRead(fullfile(dngpath, fileList(ii).name));
    if ~any(exposures == info.ExposureTime)
        exposures = [exposures, info.ExposureTime];
        mkdir(fullfile(dngpath, num2str(floor(1/info.ExposureTime))))
    end
    movefile(fullfile(dngpath, fileList(ii).name),... 
             fullfile(dngpath, num2str(floor(1/info.ExposureTime))));
end