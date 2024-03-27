clc,close,clear all
%%

load 'Indian_pines.mat'

%% Extract one spectrogram
spectrogram = indian_pines(30,:,:);
spectrogram = squeeze(spectrogram)
imshow(spectrogram)
fake_hcube = zeros(145,145,220);

%%
spectrogram = squeeze(spectrogram)

%% Visualize the data using imagesc
figure; % Create a new figure window
imagesc(spectrogram);
colorbar; % Add a colorbar to indicate the scale of values
xlabel('Dimension 2 (e.g., Wavelength or Time)');
ylabel('Dimension 1 (e.g., Spatial Locations)');
title('Visualization of the 145x220 Spectrum');
%%


% Pre-allocate the target 3D array for efficiency
fake_hcube = zeros(145, 145, 220);

% Loop through each feature (third dimension) and replicate the 145x1 vector across 145 columns
for i = 1:220
    % Each slice (:,:,i) of replicatedArray is a 145x145 matrix where each column is a copy of the originalArray(:,i)
    fake_hcube(:, :, i) = repmat(spectrogram(:, i), 1, 145);
end

%% displaying hyperspectral image through hypercube
wavelength = linspace(0.4, 2.5, 220);
hcube = hypercube(fake_hcube, wavelength);
img = colorize(hcube,'Method', 'rgb', 'ContrastStretching', true);
imshow(img)
