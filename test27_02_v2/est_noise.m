function [w, Rw] = est_noise(y)

    % Ensure input is a GPU array
    y = gpuArray(y);

    [L, N] = size(y);
    small = 1e-6;
    w = gpuArray.zeros(L, N);
    RR = gpuArray.zeros(L);

    % Compute covariance matrix efficiently
    for i = 1:L
        for j = i:L
            RR(i, j) = y(i, :) * y(j, :)' / N;
            if i ~= j
                RR(j, i) = RR(i, j);
            end
        end
    end

    % Regularize the covariance matrix to ensure it is positive definite
    RR = RR + small * gpuArray.eye(L);
    RRi = pinv(RR + small * gpuArray.eye(L));

    for i = 1:L
        XX = RRi - (RRi(:, i) * RRi(i, :)) / RRi(i, i);
        RRa = RR(:, i);
        RRa(i) = 0;
        beta = XX * RRa;
        beta(i) = 0;
        w(i, :) = y(i, :) - (beta' * y);
    end

    % Diagonal matrix with variances
    Rw = diag(diag((w * w') / N));

    % Convert w and Rw back to CPU arrays if needed
    w = gather(w)';
    Rw = gather(Rw)';
end