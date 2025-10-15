function noisy_img = add_gaussian_noise(img, mean_val, variance)
% ADD_GAUSSIAN_NOISE Add Gaussian noise to an image
%   noisy_img = add_gaussian_noise(img, mean_val, variance)
%   
%   Inputs:
%       img      - Input image (grayscale or color)
%       mean_val - Mean of Gaussian noise, default 0
%       variance - Variance of Gaussian noise, default 0.01
%   
%   Output:
%       noisy_img - Image with Gaussian noise

    if nargin < 2
        mean_val = 0;
    end
    if nargin < 3
        variance = 0.01;
    end
    
    % Convert to double for noise addition
    img_double = double(img);
    [rows, cols, channels] = size(img);
    
    % Generate Gaussian noise
    noise = mean_val + sqrt(variance) * randn(rows, cols, channels);
    
    % Add noise and clip to valid range
    noisy_img = img_double + noise;
    noisy_img = max(0, min(255, noisy_img));
    
    % Convert back to original type
    noisy_img = uint8(noisy_img);
end

