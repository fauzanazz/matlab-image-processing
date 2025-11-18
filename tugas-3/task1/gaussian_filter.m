function filtered_img = gaussian_filter(img, sigma)
% GAUSSIAN_FILTER - Melakukan filtering Gaussian pada citra
%
% Syntax: filtered_img = gaussian_filter(img, sigma)
%
% Input:
%   img   - Citra input (grayscale, double)
%   sigma - Standard deviasi Gaussian kernel
%
% Output:
%   filtered_img - Citra hasil filtering
%
% Deskripsi:
%   Fungsi ini membuat Gaussian kernel dan mengaplikasikannya pada citra
%   untuk mengurangi noise sebelum deteksi tepi

    kernel_size = ceil(6 * sigma);
    if mod(kernel_size, 2) == 0
        kernel_size = kernel_size + 1; 
    end
    
    half_size = floor(kernel_size / 2);
    [X, Y] = meshgrid(-half_size:half_size, -half_size:half_size);
    
    gaussian_kernel = exp(-(X.^2 + Y.^2) / (2 * sigma^2));
    gaussian_kernel = gaussian_kernel / sum(gaussian_kernel(:)); 
    
    filtered_img = conv2(img, gaussian_kernel, 'same');
    
end