function roiInt = cbIpROISelect(ip)
ipWindow(ip);
[roiLocs,roi] = ieROISelect(ip);
roiInt = round(roi.Position);
end