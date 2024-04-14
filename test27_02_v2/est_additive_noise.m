function [w, Rw] = est_additive_noise(r)
    % Ensure input is a GPU array
    r = gpuArray(r);

    [L, N] = size(r);
    small = 1e-6;

    % Initialize w as a GPU array
    w = gpuArray.zeros(L, N);

    % Efficient covariance matrix calculation and regularization
    RR = r * r';
    RRi = pinv(RR + small * gpuArray.eye(L));

    for i = 1:L
        XX = RRi - (RRi(:, i) * RRi(i, :)) / RRi(i, i);
        RRa = RR(:, i);
        RRa(i) = 0;  % Remove self-relation (diagonal influence)
        beta = XX * RRa;
        beta(i) = 0;  % Ensuring self-influence is negated
        w(i, :) = r(i, :) - (beta' * r);
    end

    % Compute the noise covariance matrix only for the diagonal elements
    Rw = diag(diag((w * w') / N));

    % Convert w and Rw back to CPU arrays if needed elsewhere as non-GPU arrays
    w = gather(w);
    Rw = gather(Rw);
end