function [kf, Ek] = estimateAndFilterNoiseHySIME(y, n, Rn)
    % Hyperspectral signal subspace estimation based on HySIME principles for GPU
    % Parameters:
    %   y: Hyperspectral data set (each column is a pixel)
    %      with (p x (m*n)), where p is the number of bands
    %      and (m*n) the number of pixels. Assumes y is on the GPU.
    %   n: Matrix with the noise in each pixel. Assumes n is on the GPU.
    %   Rn: Noise correlation matrix (p x p). Assumes Rn is on the GPU.
    % Returns:
    %   kf: Signal subspace dimension
    %   Ek: Matrix whose columns are the eigenvectors that span
    %       the signal subspace.

    % Ensure inputs are GPU arrays
    y = gpuArray(y);
    n = gpuArray(n');
    Rn = gpuArray(Rn);

    [L, N] = size(y);
    [~, Nn] = size(n);
    [d1, d2] = size(Rn);

    x = y - n;

    Ry = (y * y') / N;
    Rx = (x * x') / N;
    [E, D, ~] = svd(Rx);  % E are the eigenvectors, D is the diagonal matrix of eigenvalues

    % Regularize Rn to ensure it is not singular
    Rn = Rn + (trace(Rx)/L/10^5) * eye(L, 'gpuArray');
    Py = diag(E' * (Ry * E));
    Pn = diag(E' * (Rn * E));
    cost_F = -Py + 2 * Pn;
    
    % Find the number of negative entries in cost_F
    kf = sum(cost_F < 0);
    
    % Get indices that would sort cost_F in ascending order
    [~, ind_asc] = sort(cost_F);
    
    % Extract eigenvectors corresponding to the kf smallest values
    Ek = E(:, ind_asc(1:kf));

    % Make sure to gather the results back to the CPU
    kf = gather(kf);
    Ek = gather(Ek);
end