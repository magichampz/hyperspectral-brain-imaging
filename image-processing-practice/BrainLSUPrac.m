
hcube = hypercube('raw.hdr');

dark_ref = multibandread('darkReference', [285, 1, hcube.Metadata.Bands], 'uint16=>uint16', 0, 'bil', 'ieee-le');
white_ref = multibandread('whiteReference', [285, 1, hcube.Metadata.Bands], 'uint16=>uint16', 0, 'bil', 'ieee-le');

% Replicate the calibration images to match the hypercube's dimensions
% We replicate each band's single row to match the height of the hypercube
dark_ref_replicated = repmat(reshape(dark_ref, [1, 285, hcube.Metadata.Bands]), [hcube.Metadata.Height, 1, 1]);
white_ref_replicated = repmat(reshape(white_ref, [1, 285, hcube.Metadata.Bands]), [hcube.Metadata.Height, 1, 1]);

calibratedData = (double(hcube.DataCube) - double(dark_ref_replicated)) ./ (double(white_ref_replicated) - double(dark_ref_replicated));
calibratedData(calibratedData < 0) = 0;

numCorruptedRows = 100; 
calibratedData = calibratedData(1:end-numCorruptedRows, :, :);

calibratedHypercube = hypercube(calibratedData, hcube.Wavelength);

figure(1);

subplot(1,2,1);
rgbImage = colorize(calibratedHypercube, 'Method', 'rgb');
imshow(rgbImage);

% Perform linear stretching on the calibrated data
minVal = min(calibratedHypercube.DataCube(:));
maxVal = max(calibratedHypercube.DataCube(:));
stretchedData = (calibratedHypercube.DataCube - minVal) / (maxVal - minVal);

% Initialize an array for the gamma-corrected data
gammaCorrectedData = zeros(size(stretchedData));

% Apply a gamma correction to each band
for b = 1:size(stretchedData, 3)
    gammaCorrectedData(:, :, b) = imadjust(stretchedData(:, :, b), [], [], 0.5);
end

% Create a new hypercube object with the stretched and gamma-corrected data
gammaCorrectedHypercube = hypercube(gammaCorrectedData, calibratedHypercube.Wavelength);

% Colorize the gamma-corrected hypercube data
rgbImage = colorize(gammaCorrectedHypercube, 'Method', 'rgb');

% Display the result
subplot(1,2,2);
imshow(rgbImage);


figure(2);

numEndmembers = countEndmembersHFC(calibratedData,'PFA',10^-7);
endmembers = nfindr(calibratedData, numEndmembers,'NumIterations',1000,'ReductionMethod','PCA');

numBands = hcube.Metadata.Bands;

for i = 1:numEndmembers
    subplot(numEndmembers, 1, i); 
    plot(hcube.Wavelength, endmembers(:, i));
    title(sprintf('Endmember %d', i));
    xlabel('Band Number');
    ylabel('Reflectance');
end

figure(3);
abundanceMap = estimateAbundanceLS(calibratedData,endmembers);
montage(abundanceMap,'Size',[4 4],'BorderSize',[10 10]);
colormap default
title('Abundance Maps for Endmembers');
