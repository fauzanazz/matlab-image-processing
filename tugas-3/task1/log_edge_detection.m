function edge_img = log_edge_detection(img, sigma, threshold_factor)
% LOG_EDGE_DETECTION - Deteksi tepi menggunakan Laplacian of Gaussian (LoG)
%
% Syntax: edge_img = log_edge_detection(img, sigma, threshold_factor)
%
% Input:
%   img              - Citra input (grayscale, double)
%   sigma            - Standard deviasi Gaussian (default: 2.0)
%   threshold_factor - Faktor threshold (default: 0.08)
%
% Output:
%   edge_img - Citra biner hasil deteksi tepi
%
% Deskripsi:
%   LoG menggabungkan Gaussian smoothing dengan Laplacian untuk deteksi tepi
%   yang robust terhadap noise. Formula:
%   LoG(x,y) = -1/(π*σ^4) * [1 - (x^2+y^2)/(2σ^2)] * exp(-(x^2+y^2)/(2σ^2))

    if nargin < 2
        sigma = 2.0;
    end
    if nargin < 3
        threshold_factor = 0.08;
    end
    
    kernel_size = ceil(6 * sigma);
    if mod(kernel_size, 2) == 0
        kernel_size = kernel_size + 1;
    end
    
    half_size = floor(kernel_size / 2);
    [X, Y] = meshgrid(-half_size:half_size, -half_size:half_size);
    
    sigma2 = sigma^2;
    sigma4 = sigma2^2;
    
    r2 = X.^2 + Y.^2;
    log_kernel = -(1 / (pi * sigma4)) .* (1 - r2 / (2 * sigma2)) .* exp(-r2 / (2 * sigma2));
    log_kernel = log_kernel - mean(log_kernel(:));
    log_response = conv2(img, log_kernel, 'same');
    edge_img = zero_crossing_detection(log_response, threshold_factor);
    edge_img = bwareaopen(edge_img, 15);
    edge_img = imclose(edge_img, strel('disk', 1));
    
end

function zc = zero_crossing_detection(img, threshold)
    [rows, cols] = size(img);
    zc = false(rows, cols);
    thresh_val = threshold * max(abs(img(:)));
    
    for i = 2:rows-1
        for j = 2:cols-1
            neighborhood = img(i-1:i+1, j-1:j+1);
            center = img(i, j);
            
            % Horizontal
            if sign(img(i, j-1)) ~= sign(img(i, j+1)) && ...
               abs(img(i, j-1) - img(i, j+1)) > thresh_val
                zc(i, j) = true;
            end
            
            % Vertical
            if sign(img(i-1, j)) ~= sign(img(i+1, j)) && ...
               abs(img(i-1, j) - img(i+1, j)) > thresh_val
                zc(i, j) = true;
            end
            
            % Diagonal 1
            if sign(img(i-1, j-1)) ~= sign(img(i+1, j+1)) && ...
               abs(img(i-1, j-1) - img(i+1, j+1)) > thresh_val
                zc(i, j) = true;
            end
            
            % Diagonal 2
            if sign(img(i-1, j+1)) ~= sign(img(i+1, j-1)) && ...
               abs(img(i-1, j+1) - img(i+1, j-1)) > thresh_val
                zc(i, j) = true;
            end
        end
    end
end