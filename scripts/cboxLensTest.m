%% Initialize ISET and Docker
%
% We start up ISET and check that the user is configured for docker
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read the file
thisR = piRecipeDefault('scene name','slantedBarC4D');

%%

idx = piMaterialFind(thisR, 'name', 'BlackMat');

piMaterialCreate(thisR);

piMaterialList(thisR);

piMaterialSet(thisR, 3, 'name', 'GrayMat');
piMaterialSet(thisR, 3, 'rgbkd', [0.5 0.5 0.5]);

%% Assign gray material to 
% The desired style should be 
% thisR.set('asset object', 'name', 'material', 'value')
% thisR.set('asset light', 'name', 'field')
% thisR.set('asset branch', 'name', 'position', 'value')
% Leaves can be objects or lights, branches are place holder for
% transforms.
disp(thisR.assets.tostring)

blkID = piAssetFind(thisR, 'name', 'WhiteSurface');

objID = piAssetGet(thisR, blkID, 'children');

thisNode = piAssetGet(thisR, objID);

newMaterial = thisNode.material;
newMaterial.namedmaterial = 'GrayMat';

thisR = piAssetSet(thisR, objID, 'material', newMaterial);

% Double check we changed 
newNode = piAssetGet(thisR, objID);

%% Build a lens
% lensfile = 'reversed.telephoto.77deg.3.5201mm.json';
lensfile  = 'dgauss.77deg.3.5201mm.json';  
fprintf('Using lens: %s\n',lensfile);
thisR.camera = piCameraCreate('omni','lensFile',lensfile);
thisR.set('film diagonal',0.5);

%%
dst = thisR.get('depth range')

%% Add a point light
thisR = piLightAdd(thisR, 'type', 'distant', 'camera coordinate', true,...
                          'lightspectrum', 'D65');

% You can also try this light if you like, which is more blue and distant
% 
% Just comment the line above and uncomment this one
% thisR = piLightAdd(thisR, 'type', 'distant', 'light spectrum', [9000 0.001],...
%                         'camera coordinate', true);

%% Set up the render quality
%
% There are many different parameters that can be set.  This is the just an
% introductory script, so we do a minimal number of parameters.  Much of
% what is described in other scripts expands on this section.
thisR.set('film resolution',[768 768]);
thisR.set('rays per pixel',384);
thisR.set('n bounces',1); % Number of bounces

%% Save the recipe information
piWrite(thisR);

%% Render 
%
% There is no lens, just a pinhole.  In that case, we are rendering a
% scene. If we had a lens, we would be rendering an optical image.
[oi, result] = piRender(thisR, 'render type', 'radiance');
oiWindow(oi);

%%
FOV = 5.5;
oi = oiSet(oi, 'fov', FOV);

%% Sensor
sensorFOV = 5.5;
sensor = sensorCreate('IMX363');
sensor = sensorSet(sensor, 'noise flag', 2);
sensor = sensorSetSizeToFOV(sensor, sensorFOV, oi);
sensor = sensorCompute(sensor, oi);
sensorWindow(sensor);

%% ip
ip = ipCreate;
ip = ipCompute(ip, sensor);
ipWindow(ip);

%% Compute MTF
% Get slanted bar region
%{
    mtfData = ieISO12233(ip, sensor);
    mrect = ISOFindSlantedBar(ip);
%}

% Manually select slanted bar region
[roiLocs,roi] = ieROISelect(ip);
mrect = round(roi.Position);
% Get bar image
barImage = vcGetROIData(ip, mrect, 'sensor space');
c = mrect(3)+1; r = mrect(4)+1;
barImage = reshape(barImage,r,c,3);
% ieNewGraphWin; imagesc(barImage(:,:,1)); axis image; colormap(gray);

% Get pixel size
dx = sensorGet(sensor, 'pixel width', 'mm');

weight = [];
mtfData = ISO12233(barImage, dx, weight, 'none');

%% Plot mtfData
ieNewGraphWin;
c = {'r','g','b','k'};
for ii = 1:4
h = plot(mtfData.freq,mtfData.mtf(:, ii),['-',c{ii}]);
hold on
end
nfreq = mtfData.nyquistf;
l = line([nfreq ,nfreq],[0.1,0],'color',c{ii});


xlabel('lines/mm');
ylabel('Relative amplitude');
title('MTF for different pixel sizes');
hold off; grid on

set(gca, 'xlim', [0 400], 'ylim', [0 1.5])

