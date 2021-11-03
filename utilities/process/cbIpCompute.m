function ip = cbIpCompute(sensor)
% Cornell box version of ip compute
% Demosaic only
%% 
ip = ipCreate;
ip = ipSet(ip, 'render demosaic only', true);
ip = ipSet(ip, 'scale display output', false);
ip = ipCompute(ip, sensor);
end