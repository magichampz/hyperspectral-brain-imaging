function [endmembers, indices] = extractEndmembersVCA(hsiData, numEndmembers)
    % Flatten the HSI cube for VCA
    [rows, cols, bands] = size(hsiData);
    hsi2D = reshape(hsiData, rows*cols, bands)';
    
    % Normalize the data between 0 and 1 for each band
    hsi2D = hsi2D - min(hsi2D, [], 2);
    hsi2D = hsi2D ./ max(hsi2D, [], 2);
    
    % VCA algorithm
    [endmembers, indices] = hyperVca(hsi2D, numEndmembers);
    
    % Reshape indices to 2D spatial coordinates
    [indRow, indCol] = ind2sub([rows, cols], indices);
    indices = [indRow, indCol];
end