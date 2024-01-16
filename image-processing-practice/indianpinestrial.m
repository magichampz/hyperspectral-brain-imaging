clear all; clc; clf;
load 'Indian_pines.mat'

%% displaying hyperspectral image through hypercube
wavelength = linspace(0.4, 2.5, 220);
hcube = hypercube(indian_pines, wavelength);
img = colorize(hcube,'Method', 'rgb', 'ContrastStretching', true);
imshow(img)

%% pixel spectra of one pixel
stest1 = indian_pines(1,1,:);
stest2 = squeeze(stest1);
figure(2)
plot(wavelength, stest2)
title('First Pixel Spectra')
xlabel('Wavelength')
ylabel('Data')

%% new section
disp(5);