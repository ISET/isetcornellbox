% s_cbFocusAnalysis

img1 = 'IMG_20210103_095707.dng'; % Focus: 0.1 m
img2 = 'IMG_20210103_095748.dng'; % Focus: inf
img3 = 'IMG_20210103_095759.dng'; % Focus: 2.0 m

%% 
[sensor1, info1] = sensorDNGRead(img1);
[sensor2, info2] = sensorDNGRead(img2);
[sensor3, info3] = sensorDNGRead(img3);

