function cameraPosInfo = cbCameraPosCreate(varargin)

% Examples
%{
cameraHeight = 107.5;
boxHeight = 90;
boxSize = 30;
boxWindowSize = 5;
leftDist = 41;
rightDist = 41;
rotationDeg = 40;
cameraPosInfo = cbCameraPosCreate('camera height', cameraHeight,...
                                  'box height', boxHeight,...
                                  'box size', boxSize,...
                                  'box window size', boxWindowSize,...
                                  'left distance', leftDist,...
                                  'right distance', rightDist,...
                                  'rotation deg', rotationDeg);
%}
%% Parse
varargin = ieParamFormat(varargin);
p = inputParser;
p.addParameter('cameraheight', 0, @isnumeric);
p.addParameter('boxheight', 0, @isnumeric);
p.addParameter('boxsize', 0, @isnumeric);
p.addParameter('boxwindowsize', 0, @isnumeric);
p.addParameter('leftdistance', 0, @isnumeric);
p.addParameter('rightdistance', 0, @isnumeric);
p.addParameter('rotationdeg', 40, @isnumeric);
p.addParameter('calideg', 40, @isnumeric);
p.parse(varargin{:});

cameraHeight = p.Results.cameraheight;
boxHeight = p.Results.boxheight;
boxSize = p.Results.boxsize;
boxWindowSize = p.Results.boxsize;
leftDist = p.Results.leftdistance;
rightDist = p.Results.rightdistance;
rotationDeg = p.Results.rotationdeg;
caliDeg = p.Results.calideg;

%% Create struct for origin info
oriInfo.cameraHeight = cameraHeight;
oriInfo.boxHeight = boxHeight;
oriInfo.boxSize = boxSize;
oriInfo.boxWindowSize = boxWindowSize;
oriInfo.leftDist = leftDist;
oriInfo.rightDist = rightDist;
oriInfo.rotationDeg = rotationDeg;
oriInfo.caliDeg = caliDeg;

%% Create struct for PBRT info
pbrtInfo.cameraHeight = cameraHeight - boxHeight;
pbrtInfo.boxSize = boxSize;
pbrtInfo.boxWindowSize = boxWindowSize;
pbrtInfo.rotationDeg = rotationDeg - caliDeg;

%% Calculate camera distance to the box and horizontal position from center
% Use heron's formula calculate the triangle area. The distance can be
% calculated as the height of the triangle with box size as base side. Then
% the horizontal position can be calculated with Pythagorean theorem.

tmpArea = triangleArea(boxSize, leftDist, rightDist);
pbrtInfo.cameraDist = tmpArea * 2 / boxSize;

distToRight = sqrt(rightDist^2 - pbrtInfo.cameraDist^2);
pbrtInfo.cameraHorDist = distToRight - boxSize / 2;

%% Wrap oriInfo and pbrtInfo
cameraPosInfo.oriInfo = oriInfo;
cameraPosInfo.pbrtInfo = pbrtInfo;
end

function area = triangleArea(a, b, c)
rho = (a + b + c) / 2; % Half perimeter
area = sqrt(rho * (rho-a) * (rho-b) * (rho-c));
end