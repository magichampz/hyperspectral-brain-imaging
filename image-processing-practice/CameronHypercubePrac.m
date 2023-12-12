clc; clear all; clearvars

hcube = hypercube("paviaU.dat");
hyperspectralViewer(hcube);
%rgbImg = colorize(hcube,Method="rgb",ContrastStretching=true);
%imshow(rgbImg)
%title("RGB Image")

%% Accessing spectrum for a specified pixel
cubeWaveLengths = hcube.Wavelength;
wavelength_values = zeros(1, length(cubeWaveLengths));
x = 1;
y = 1;

% Loop through each band and extract the value for the specified pixel
for b = 1:length(cubeWaveLengths)
    bandData = hcube.DataCube(x, y, b);
    wavelength_values(b) = bandData;
end
figure();
plot(cubeWaveLengths,wavelength_values,"r");