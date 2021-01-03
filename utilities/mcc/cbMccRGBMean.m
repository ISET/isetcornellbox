function [rgbMean, rois] = cbMccRGBMean(sensor, cornerPoint, blackBorder)
    [rois, mLocs, pSize] = chartRectangles(cornerPoint,4,6,0.5,blackBorder);
    nPixel = round(pSize(1)/4);
    rgbMean = chartRectsData(sensor,mLocs,nPixel,false,'dv'); %returns digital values
    rgbMean = rgbMean - sensorGet(sensor,'black level');
end