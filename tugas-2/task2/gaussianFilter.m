function [output, kernel] = gaussianFilter(f, n, sigma)
% GAUSSIANFILTER - Gaussian filter dalam ranah spasial menggunakan konvolusi
%
% Syntax:
%   [output, kernel] = gaussianFilter(f, n, sigma)
%
% Input:
%   f      - Citra input (grayscale atau RGB)
%   n      - Ukuran kernel (n x n), harus ganjil
%   sigma  - Standard deviation (default: n/5)
%
% Output:
%   output - Citra hasil filtering (smoothed)
%   kernel - Gaussian kernel yang digunakan
%
% Menggunakan fungsi konvolusi dari Task 1
% Gaussian formula: G(x,y) = (1/(2*pi*sigma^2)) * exp(-(x^2+y^2)/(2*sigma^2))

    if nargin < 3
        sigma = n / 5;
    end

    if mod(n, 2) == 0
        error('Ukuran kernel harus ganjil (3, 5, 7, ...)');
    end

    kernel = createGaussianKernel(n, sigma);
    f = im2double(f);
    [M, N, channels] = size(f);
    output = zeros(M, N, channels);

    for ch = 1:channels
        fc = f(:,:,ch);
        output(:,:,ch) = convolution2D_task1(fc, kernel, 'replicate');
    end

    output = max(0, min(1, output));
end

function kernel = createGaussianKernel(n, sigma)
    center = ceil(n / 2);
    [X, Y] = meshgrid(1:n, 1:n);
    X = X - center;
    Y = Y - center;
    kernel = exp(-(X.^2 + Y.^2) / (2 * sigma^2));
    kernel = kernel / sum(kernel(:));
end

function output = convolution2D_task1(image, mask, paddingMethod)
    if nargin < 3
        paddingMethod = 'zero';
    end

    [maskRows, maskCols] = size(mask);

    image = double(image);
    mask = double(mask);

    [M, N] = size(image);
    n = maskRows;

    padSize = floor(n / 2);
    paddedImage = padImage(image, padSize, paddingMethod);

    output = zeros(M, N);
    mask = rot90(mask, 2);

    for i = 1:M
        for j = 1:N
            roi = paddedImage(i:i+n-1, j:j+n-1);
            output(i, j) = sum(sum(roi .* mask));
        end
    end
end

function paddedImage = padImage(image, padSize, method)
    [M, N] = size(image);

    switch lower(method)
        case 'zero'
            paddedImage = zeros(M + 2*padSize, N + 2*padSize);
            paddedImage(padSize+1:padSize+M, padSize+1:padSize+N) = image;

        case 'replicate'
            paddedImage = zeros(M + 2*padSize, N + 2*padSize);
            paddedImage(padSize+1:padSize+M, padSize+1:padSize+N) = image;

            for k = 1:padSize
                paddedImage(k, padSize+1:padSize+N) = image(1, :);
                paddedImage(M+padSize+k, padSize+1:padSize+N) = image(M, :);
            end

            for k = 1:padSize
                paddedImage(:, k) = paddedImage(:, padSize+1);
                paddedImage(:, N+padSize+k) = paddedImage(:, padSize+N);
            end

        case 'symmetric'
            paddedImage = zeros(M + 2*padSize, N + 2*padSize);
            paddedImage(padSize+1:padSize+M, padSize+1:padSize+N) = image;

            for k = 1:padSize
                paddedImage(padSize+1-k, padSize+1:padSize+N) = image(k, :);
                paddedImage(M+padSize+k, padSize+1:padSize+N) = image(M-k+1, :);
            end

            for k = 1:padSize
                paddedImage(:, padSize+1-k) = paddedImage(:, padSize+1+k);
                paddedImage(:, N+padSize+k) = paddedImage(:, N+padSize-k);
            end

        otherwise
            error('Metode padding tidak valid: zero, replicate, atau symmetric');
    end
end
