clc; clear all; clearvars
hcube = hypercube("paviaU.dat");
hyperspectralViewer(hcube);
%rgbImg = colorize(hcube,Method="rgb",ContrastStretching=true);
%imshow(rgbImg)
%title("RGB Image")

reducedCube = hyperpca(hcube, 10);
%figure, montage(hcube, 'DisplayRange', []);
figure, montage(reducedCube, 'DisplayRange',[]);
title('First 10 bands from original data');

%% Accessing spectrum for a specified pixel
cubeWaveLengths = hcube.Wavelength;
wavelength_values = zeros(1, length(cubeWaveLengths));
x = 100;
y = 5;

% Loop through each band and extract the value for the specified pixel
for b = 1:length(cubeWaveLengths)
    bandData = hcube.DataCube(x, y, b);
    wavelength_values(b) = bandData;
end
figure();
plot(cubeWaveLengths,wavelength_values,"r");
title("RGB Image")