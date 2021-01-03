function ip = ipRotate(ip)
    ip.data.input = rot90(ip.data.input);
    ip.data.sensorspace = rot90(ip.data.sensorspace);
    ip.data.result = rot90(ip.data.result);
end