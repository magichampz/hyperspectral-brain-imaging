function numSignals = estimateNumberOfSignals(eigenvalues)
    % Normalize eigenvalues to get the explained variance
    explainedVariance = eigenvalues / sum(eigenvalues);
    
    % Calculate cumulative explained variance
    cumulativeVariance = cumsum(explainedVariance);
    
    % Determine the number of components to explain a certain amount of variance
    varianceThreshold = 0.99; % for example, to keep 99% of the variance
    numSignals = find(cumulativeVariance >= varianceThreshold, 1, 'first');
    
    if isempty(numSignals)
        numSignals = length(eigenvalues); % Use all components if threshold not met
    end
end