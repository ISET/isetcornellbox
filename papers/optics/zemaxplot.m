% LSF, MTF, lens vignetting
%% 
ieInit;

%%
zemaxPath = fullfile(cboxRootPath, 'local', 'measurement',...
                        'zemax');
                    
%% Read LSF
lsfName = 'GeometricLSP.txt';
% A n x 5 matrix, which are: position, LSFX, erfX (?), LSFY, erfY
lsfRaw = readmatrix(fullfile(zemaxPath, lsfName));
lsfPos = lsfRaw(:, 1);
lsfX = lsfRaw(:, 2); lsfY = lsfRaw(:,4); % Same

ieNewGraphWin; hold all;
plot(lsfPos, lsfX, 'LineWidth', 8);
grid on; box on; 
xlabel('Position (um)'); ylabel('Relative Intensity (a.u.)');

%% Read MTF
mtfName = 'GeometricMTF.txt';
mtfRaw = readmatrix(fullfile(zemaxPath, mtfName));
%{
1:81, 84:164, 167:247, 250:330, 333:413, 416:496
%}
validRows = {[1:81], [84:164], [167:247], [250:330], [330:413], [416:496]};

ieNewGraphWin;hold all;
for ii=1:numel(validRows)
    plot(mtfRaw(validRows{ii}, 1), mtfRaw(validRows{ii}, 3), 'LineWidth', 8);
end
grid on; box on;
xlabel('Spatial frequency (cy/mm)'); ylabel('Contrast reduction (MTF)');
legend('On-axis', 'Film height@1.5mm', 'Film height@2.1mm',...
        'Film height@2.6mm', 'Film height@2.8mm',...
        'Film height@3.5mm');
    
%% Relative illumination
riName = 'RI.txt';
riRaw = readmatrix(fullfile(zemaxPath, riName));
pixPos = riRaw(:,1);
lensVignet = riRaw(:,2);
ieNewGraphWin; hold all;
plot(pixPos, lensVignet, 'LineWidth', 8);
grid on; box on;
xlabel('Position (mm)'); ylabel('Relative Illumination');
xlim([0 3.5])