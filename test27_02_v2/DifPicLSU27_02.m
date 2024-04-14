close all; clear; clearvars all;
%PPDATA = load("preprocDATA.mat");
%% Data Calibration and Loading
hcube = hypercube('raw.hdr');

dark_ref = multibandread('darkReference', [342, 1, hcube.Metadata.Bands], 'uint16=>uint16', 0, 'bil', 'ieee-le');
white_ref = multibandread('whiteReference', [342, 1, hcube.Metadata.Bands], 'uint16=>uint16', 0, 'bil', 'ieee-le');

% Replicate the calibration images to match the hypercube's dimensions
dark_ref_replicated = repmat(reshape(dark_ref, [1, 342, hcube.Metadata.Bands]), [hcube.Metadata.Height, 1, 1]);
white_ref_replicated = repmat(reshape(white_ref, [1, 342, hcube.Metadata.Bands]), [hcube.Metadata.Height, 1, 1]);

calibratedData = (double(hcube.DataCube) - double(dark_ref_replicated)) ./ (double(white_ref_replicated) - double(dark_ref_replicated));
calibratedData(calibratedData < 0) = 0;
calibratedData = calibratedData(:,40:end-75, :);
calibratedHypercube = hypercube(calibratedData, hcube.Wavelength);
TestCC = calibratedData(1,1,:);
%% Preprocessing: Denoising and Band Reduction

% Integrate the preprocessing steps here
% Assuming the preprocessHSIData function includes noise estimation/filtering, band removal, averaging, and normalization
preprocessedData= preprocessHSIData(calibratedData); % Make sure this function is defined and available
bandIndices = round(linspace(1, size(calibratedData, 3)-127, 129 + 1));

newWavelengths = hcube.Wavelength(51:750);
dataWav = zeros(1,129);
for i = 1:129
    bandStart = bandIndices(i);
    bandEnd = bandIndices(i + 1) - 1;
    %Calculate the mean of the original wavelengths for the current band
    dataWav(i) = mean(newWavelengths(bandStart:bandEnd));
end


preprocessedHypercube = hypercube(preprocessedData, dataWav);

TestPP = preprocessedData(1,1,:);
%% Visualization of Preprocessed Data

figure();
subplot(1,2,1);
rgbImageBefore = colorize(calibratedHypercube, 'Method', 'rgb');
imshow(rgbImageBefore, "Interpolation", "bilinear")
title('Before Preprocessing');

subplot(1,2,2);
rgbImageAfter = colorize(preprocessedHypercube, 'Method', 'rgb');
imshow(rgbImageAfter, "Interpolation", "bilinear")
title('After Preprocessing');

%% Further Analysis on Preprocessed Data (e.g., Endmember Analysis)

% Update subsequent analyses to use preprocessedData instead of calibratedData
numEndmembers = countEndmembersHFC(preprocessedData, 'PFA', 10^-7);
[endmembers, endmemberIndices] = extractEndmembersVCA(preprocessedData, numEndmembers);

figure();
% Example: Plotting endmembers
for i = 1:numEndmembers
    subplot(numEndmembers, 1, i); 
    plot(dataWav, endmembers(:, i));
    title(sprintf('Endmember %d', i));
    xlabel('Band Number');
    ylabel('Reflectance');
end

%% Abundance Mapping on Preprocessed Data

figure();
abundanceMap = estimateAbundanceLS(preprocessedData, endmembers);
montage(abundanceMap, 'Size', [4 4], 'BorderSize', [10 10]);
colormap default
title('Abundance Maps for Endmembers');

%% Endmember Analysis using nfindr
figure();
endmembers2 = nfindr(preprocessedData, numEndmembers,'NumIterations',5000,'ReductionMethod','PCA');

for i = 1:numEndmembers
    subplot(numEndmembers, 1, i); 
    plot(dataWav, endmembers2(:, i));
    title(sprintf('nfindr Endmember %d', i));
    xlabel('Band Number');
    ylabel('Reflectance');
    
end

% Abundance Map
figure();
abundanceMap2 = estimateAbundanceLS(preprocessedData,endmembers2);
montage(abundanceMap2,'Size',[4 4],'BorderSize',[10 10]);
colormap default
title('Abundance Maps for Endmembers with nfindr');

%% Endmember Analysis using FIPPI
figure();
endmembers3 = fippi(preprocessedData, numEndmembers,'ReductionMethod','PCA');
fippiNum = size(endmembers3,2);

for i = 1:fippiNum
    subplot(fippiNum, 1, i); 
    plot(dataWav, endmembers3(:, i));
    title(sprintf('FIPPI Endmember %d', i));
    xlabel('Band Number');
    ylabel('Reflectance');
    
end

% Abundance Map
figure();
abundanceMap3 = estimateAbundanceLS(preprocessedData,endmembers3);
montage(abundanceMap3,'Size',[4 4],'BorderSize',[10 10]);
colormap default
title('Abundance Maps for Endmembers with FIPPI');

%% Endmember Analysis using AMEE
endmembers4 = hyperAmee(preprocessedData, numEndmembers, 1);
AmeeNum = size(endmembers4,2);

for i = 1:AmeeNum
    subplot(AmeeNum, 1, i); 
    plot(dataWav, endmembers4(:, i));
    title(sprintf('AMEE Endmember %d', i));
    xlabel('Band Number');
    ylabel('Reflectance');
    
end

% Abundance Map
figure();
abundanceMap4 = estimateAbundanceLS(preprocessedData,endmembers4);
montage(abundanceMap4,'Size',[4 4],'BorderSize',[10 10]);
colormap default
title('Abundance Maps for Endmembers with AMEE');