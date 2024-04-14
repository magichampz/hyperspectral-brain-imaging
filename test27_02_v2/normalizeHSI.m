function normalizedHSI = normalizeHSI(hsiData)
    [rows, cols, bands] = size(hsiData);
    normalizedHSI = zeros(size(hsiData));
    
    % Flatten the data to find global min and max
    flatData = hsiData(:);
    minVal = min(flatData);
    maxVal = max(flatData);
    
    % Apply Max-Min normalization across the entire dataset
    for b = 1:bands
        band = hsiData(:, :, b);
        normalizedHSI(:, :, b) = (band - minVal) / (maxVal - minVal);
    end
end