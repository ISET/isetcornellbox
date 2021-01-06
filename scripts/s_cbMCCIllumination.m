% s_cbMCCIllumination
%
% We took images of the MCC in the CB with the MCC at different locations
% and in different orientations.  Here we examine how much the RGB values
% change as a function of position/orientation.
%
% JEF/BW
%

%%
ieInit

%%
dataDir = '/Users/wandell/Google Drive File Stream/My Drive/Data/Cornell box/Camera A/20210103/MCC lighting';
chdir(dataDir)
dataFiles = dir('*.dng');
exist(dataFiles(1).name,'file')
sensor = sensorDNGRead(dataFiles(1).name);

%% Pick the ROIs.
for ii=1:numel(dataFiles)
    sensor = sensorDNGRead(dataFiles(ii).name);
    if ii > 1
        ieReplaceObject(sensor);
        sensorWindow;
    else
        % sensor = sensorSet(sensor,'name',dataFiles(ii).name);
        sensorWindow(sensor);
    end
    drawnow;
    [~,rect] = ieROISelect(sensor);
    ROI(ii).position = round(rect.Position); %#ok<SAGROW>
end

%%  Read in the cropped sensor data and leave them in the window

for ii=1:numel(dataFiles)
    [~,name] = fileparts(dataFiles(ii).name);
    sensor = sensorDNGRead(dataFiles(ii).name,'crop',ROI(ii).position);
    sensorWindow(sensor);
end

%%
