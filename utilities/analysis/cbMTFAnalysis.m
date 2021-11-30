function mtfData = cbMTFAnalysis(ip, roiInt, sensorDx)
barImage = vcGetROIData(ip,roiInt,'sensor space');
c = roiInt(3)+1;
r = roiInt(4)+1;
barImage = reshape(barImage,r,c,3);

% ISO12233(barImage, deltaX, weight, plotOptions)
mtfData = ISO12233(barImage, sensorDx, [], 'all');
end