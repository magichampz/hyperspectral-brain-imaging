%% Data Calibration and Loading
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

calibratedData = calibratedData(:,40:end-numCorruptedRows, :);

calibratedHypercube = hypercube(calibratedData, hcube.Wavelength);


%% Show calibrated data with corrections to make more visible

figure(1);

subplot(1,2,1);
rgbImage = colorize(calibratedHypercube, 'Method', 'rgb');
imshow(rgbImage)

subplot (1,2,2);

% Find the band indices closest to the selected wavelengths
[~, redBandIndex] = min(abs(hcube.Wavelength - 628));
[~, greenBandIndex] = min(abs(hcube.Wavelength - 517));
[~, blueBandIndex] = min(abs(hcube.Wavelength - 565));

% Extract the bands for false color image
redBand = calibratedData(:,:,redBandIndex);
greenBand = calibratedData(:,:,greenBandIndex);
blueBand = calibratedData(:,:,blueBandIndex);

% Normalize and stack the bands to create an RGB image
redNormalized = (redBand - min(redBand(:))) / (max(redBand(:)) - min(redBand(:)));
greenNormalized = (greenBand - min(greenBand(:))) / (max(greenBand(:)) - min(greenBand(:)));
blueNormalized = (blueBand - min(blueBand(:))) / (max(blueBand(:)) - min(blueBand(:)));

falseColorImage = cat(3, redNormalized, greenNormalized, blueNormalized);

% Display the false color image
imshow(falseColorImage);
title('False Color Image based on PCA');
figure(2);

%% Endmember Analysis
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

%% Abundance Map
figure(3);
abundanceMap = estimateAbundanceLS(calibratedData,endmembers);
montage(abundanceMap,'Size',[4 4],'BorderSize',[10 10]);
colormap default
title('Abundance Maps for Endmembers');
