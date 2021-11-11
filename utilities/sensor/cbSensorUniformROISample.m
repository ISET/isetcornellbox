function roiSelects = cbSensorUniformROISample(sensor, varargin)

%%
p = inputParser;
p.addRequired('sensor', @isstruct);
p.addParameter('nsamples', 10, @isnumeric);
p.addParameter('sz', [15, 15], @isnumeric);
p.parse(sensor, varargin{:});

nsamples = p.Results.nsamples;
sz = p.Results.sz;
%%
hw = sensorGet(sensor, 'size');
height = hw(1); width = hw(2);
%%
roiSelects = cell(1, nsamples);

cnt = 1;
visited = [0,0];
fprintf('====Start searching for uniform patches...====\n')
while cnt <= nsamples
    thisX = randi([1, width], 1); thisY = randi([1, height], 1);
    while ismember([thisX, thisY], visited, 'rows')
        thisX = randi([1, width], 1); thisY = randi([1, height], 1);
    end
    visited = [visited; [thisX, thisY]];
    
    curROI = [thisX, thisY, sz(1), sz(2)];
    if cbSensorROIIsUniform(sensor, curROI)
        roiSelects{cnt} = curROI;
        cnt = cnt + 1;
    end
    if mod(cnt, 10)==0
        fprintf('Found %d samples...\n', cnt);
    end
end
fprintf('Done.\n')
end