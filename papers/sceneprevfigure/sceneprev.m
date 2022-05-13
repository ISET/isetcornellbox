% Spectral reflectance
wave = 400:10:700;
refl = ieReadSpectra('cboxSurfaces', wave);
rRefl = refl(:, 1);
gRefl = refl(:, 2);
wRefl = refl(:, 3);

lightName = 'cbox-lights-1';
lgtSpd = ieReadSpectra(lightName, wave);

ieNewGraphWin;
hold all;
plot(wave, rRefl, 'r', 'LineWidth', 8);
plot(wave, gRefl, 'g', 'LineWidth', 8);
plot(wave, wRefl, 'k', 'LineWidth', 8);
legend('Red wall', 'Green wall', 'White wall');
xlabel('Wavelength (nm)');
ylabel('Reflectance');
xticks(400:100:700); xlim([400 700]);
ylim([0 1]); yticks(0:0.5:1);
box on; grid on; axis square;

ieNewGraphWin;
plot(wave, lgtSpd, 'k', 'LineWidth', 8);
xlabel('Wavelength (nm)');
ylabel('Radiance (Watts/m^2/nm)');
xticks(400:100:700); xlim([400 700]);
ylim([0 4e-3]); yticks(0:2e-3:4e-3);
box on; grid on; axis square;