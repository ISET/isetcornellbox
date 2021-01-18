function [corrMapNorm, corrMap, error] = cbVignettingFitting(data, samplerate)
%{
dngName = 'IMG_20201102_103619_4.dng';
[sensor1, info] = sensorDNGRead(dngName);
pSz = sensorGet(sensor1, 'pixel size'); % pixel size
pSz = pSz(1);
sSz = sensorGet(sensor1, 'size'); % Sensor resolution

sensorData = sensorGet(sensor1, 'dv');
pattern = sensorGet(sensor1, 'pattern');

sensorB = sensorData(1:2:end, 1:2:end);
cbCos4thFitting(sensorB, pSz(1), 1);
%}
%%
data = double(data)/2^10;
x = double((1:size(data,2))-size(data,2)/2)/(size(data,2)/2);
y = double((1:size(data,1))-size(data,1)/2)/(size(data,1)/2)*size(data,1)/size(data,2);

[X, Y] = meshgrid(x,y);
XY(:,:,1) = X;
XY(:,:,2) = Y;

fitX = X(1:samplerate:end,1:samplerate:end);
fitY = Y(1:samplerate:end,1:samplerate:end);
fitZ = data(1:samplerate:end,1:samplerate:end);
fitXY(:,:,1) = fitX;
fitXY(:,:,2) = fitY;

%     fun = @(A,fitXY)(A(1)+A(2)*cos(sqrt((fitXY(:,:,1).^2+fitXY(:,:,2).^2)/A(3))));
fun = @(A,fitXY)(A(1)+A(2)*(A(3)./(fitXY(:,:,1).^2+fitXY(:,:,2).^2+A(3))).^2);
[A, resnorm, residual] = lsqcurvefit(fun, [max(fitZ(:)) 0.1 5], fitXY, fitZ);

corrMap = fun(A, XY);
corrMap = corrMap * 2^10;
data = data * 2^10;
error = sqrt(immse(data, corrMap));
corrMapNorm = corrMap / max(corrMap(:));
end