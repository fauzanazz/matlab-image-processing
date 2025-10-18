function [output, H, spectrum] = ilpf(f, D0, usePadding)
% ILPF - Ideal Low-Pass Filter dalam ranah frekuensi
%
% Syntax:
%   [output, H, spectrum] = ilpf(f, D0, usePadding)
%
% Input:
%   f          - Citra input (grayscale atau RGB)
%   D0         - Frekuensi cutoff
%   usePadding - true untuk padding 2x, false untuk tanpa padding (default: true)
%
% Output:
%   output     - Citra hasil filtering (smoothed/blurred)
%   H          - Filter yang digunakan
%   spectrum   - Struct berisi informasi spektrum
%
% Formula ILPF (Slide 12):
%   H(u,v) = 1 jika D(u,v) <= D0
%   H(u,v) = 0 jika D(u,v) > D0
%   dimana D(u,v) = sqrt((u - M/2)^2 + (v - N/2)^2)
%
% Catatan Slide 24-25: ILPF menimbulkan ringing effect karena diskontinuitas

    if nargin < 3
        usePadding = true;
    end

    f = im2double(f);
    [M, N, channels] = size(f);

    if usePadding
        P = 2*M;
        Q = 2*N;
    else
        P = M;
        Q = N;
    end

    output = zeros(M, N, channels);

    for ch = 1:channels
        fc = f(:,:,ch);

        if usePadding
            fp = zeros(P, Q);
            fp(1:M, 1:N) = fc;
        else
            fp = fc;
        end

        F = fft2(fp);
        F_shifted = fftshift(F); 
        u = 0:(P-1);
        v = 0:(Q-1);

        idx = find(u > P/2);
        u(idx) = u(idx) - P;
        idy = find(v > Q/2);
        v(idy) = v(idy) - Q;

        [V, U] = meshgrid(v, u);
        D = sqrt(U.^2 + V.^2);

        % ILPF: H(u,v) = 1 jika D <= D0, 0 otherwise 
        H = double(D <= D0);
        H = fftshift(H);
        G = H .* F_shifted;
        G_unshifted = ifftshift(G);
        g = real(ifft2(G_unshifted));

        if usePadding
            g = g(1:M, 1:N);
        end

        output(:,:,ch) = g;

        if ch == 1
            spectrum.original = log(1 + abs(F_shifted));
            spectrum.filtered = log(1 + abs(G));
            spectrum.filter = H;
            spectrum.magnitude_original = abs(F_shifted);
            spectrum.magnitude_filtered = abs(G);
        end
    end

    output = mat2gray(output);
end
