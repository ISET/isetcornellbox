function [pM, estYM] = cbPlotSensorData(sData, rData, t, pattern1, pattern2)
% colors = {'g', 'r', 'b'};
colors1 = {'r', 'g', 'b'};
lStyleS = '-';
colors2 = {[0.8500, 0.3250, 0.0980], [0.4660, 0.6740, 0.1880], [0, 0.4470, 0.7410]};
lStyleR = 'o';
ieNewGraphWin;
hold all
for ii = 1:4
D1.x = sData.pixPos{ii};
D1.y = sData.pixData{ii};
D2.x = rData.pixPos{ii};
D2.y = rData.pixData{ii};

[pM, estYM] = ieLineAlign(D1, D2);
plot(D1.x,D1.y, 'Color', colors1{pattern1(ii)}, 'LineStyle', lStyleS);
plot(pM(1)*(D2.x - pM(2)), D2.y, 'Color', colors2{pattern2(ii)}, 'Marker', lStyleR, 'LineStyle', 'None');
ylabel('Digital value');
end
grid on; box on;
title(t)
end