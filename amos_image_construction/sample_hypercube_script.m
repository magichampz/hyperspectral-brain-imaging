clear all; clc; clf;
%%

load 'Indian_pines.mat'

%% displaying hyperspectral image through hypercube
wavelength = linspace(0.4, 2.5, 220);
hcube = hypercube(indian_pines, wavelength);
img = colorize(hcube,'Method', 'rgb', 'ContrastStretching', true);
imshow(img)

%% visualise one spectrogram of a 'slit'
% Load the dataset
load 'Indian_pines.mat'

% Choose a row to visualize
rowIndex = 100;

% Extract the spectral data for the entire row
spectralDataRow = indian_pines(rowIndex, :, :);

% Reshape the spectral data for visualization
% The resulting matrix will have dimensions [number of wavelengths] x [number of pixels in the row]
spectralDataMatrix = squeeze(spectralDataRow);

% Display the spectral data as an image
figure;
imagesc(spectralDataMatrix');
xlabel('Wavelength Index');
ylabel('Pixel Index in Row');
title(sprintf('Spectral Data Across Row %d', rowIndex));
colorbar;

%% pixel spectra of one pixel
stest1 = indian_pines(1,1,:);
stest2 = squeeze(stest1);
figure(2)
plot(wavelength, stest2)
title('First Pixel Spectra')
xlabel('Wavelength')
ylabel('Data')

%%
head = indian_pines(:,:,1:3)