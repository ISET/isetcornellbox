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

%% Let's make some images of the MCC in different positions

% cp = sensorGet(sensor,'chart corner points');
sensor = ieGetObject('sensor');

cp = sensorGet(sensor,'corner points')
if isempty(cp)
    cp = chartCornerpoints(sensor,false);  % Get the corner points
    sensor = sensorSet(sensor,'corner points',cp);
    ieReplaceObject(sensor);
end
[rects,mLocs,pSize] = chartRectangles(cp,4,6,0.5);  % MCC parameters
chartRectsDraw(sensor,rects);

fullData = false;
dataType = 'dv';
delta = round(pSize(1)*0.5);

% rgb are the 24x3 values (average) from the sensor at the macbeth positions.
rgb = chartRectsData(sensor,mLocs,delta,fullData,dataType);

%%
sensorRed = ieGetObject('sensor');
if isempty(cp)
    cp = chartCornerpoints(sensorRed,false);  % Get the corner points
    sensor = sensorSet(sensorRed,'corner points',cp);
    ieReplaceObject(sensorRed);
end
[rects,mLocs,pSize] = chartRectangles(cp,4,6,0.5);  % MCC parameters
chartRectsDraw(sensorRed,rects);

fullData = false;
dataType = 'dv';
delta = round(pSize(1)*0.5);

% rgb are the 24x3 values (average) from the sensor at the macbeth positions.
rgb2 = chartRectsData(sensorRed,mLocs,delta,fullData,dataType);
sensorRed = sensorSet(sensorRed,'corner points',cp);

%%
ieNewGraphWin; plot(rgb,rgb2,'o'); identityLine
xlabel('Center'); ylabel('Red wall');

%%
sensorGreen = ieGetObject('sensor');
if isempty(cp)
    cp = chartCornerpoints(sensorGreen,false);  % Get the corner points
    sensor = sensorSet(sensorGreen,'corner points',cp);
    ieReplaceObject(sensorGreen);
end
[rects,mLocs,pSize] = chartRectangles(cp,4,6,0.5);  % MCC parameters
chartRectsDraw(sensorGreen,rects);

fullData = false;
dataType = 'dv';
delta = round(pSize(1)*0.5);

% rgb are the 24x3 values (average) from the sensor at the macbeth positions.
rgb3 = chartRectsData(sensorGreen,mLocs,delta,fullData,dataType);
sensorGreen = sensorSet(sensorGreen,'corner points',cp);

%%
ieNewGraphWin; plot(rgb,rgb3,'o'); identityLine
xlabel('Center'); ylabel('Green wall');

ieNewGraphWin; plot(rgb2,rgb3,'o'); identityLine
xlabel('Red Wall'); ylabel('Green wall');
