dngpath = '/mnt/disks/sdb/dataset/cornellbox/integratingsphere/20211116_dc_p55_pos1';

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