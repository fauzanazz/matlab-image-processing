function noisy_img = add_salt_pepper_noise(img, density)
% ADD_SALT_PEPPER_NOISE Add salt and pepper noise to an image
%   noisy_img = add_salt_pepper_noise(img, density)
%   
%   Inputs:
%       img     - Input image (grayscale or color)
%       density - Noise density (0 to 1), default 0.05
%   
%   Output:
%       noisy_img - Image with salt and pepper noise

    if nargin < 2
        density = 0.05;
    end
    
    noisy_img = img;
    [rows, cols, channels] = size(img);
    
    % Calculate number of pixels to corrupt
    num_pixels = rows * cols;
    num_salt = round(density * num_pixels / 2);
    num_pepper = round(density * num_pixels / 2);
    
    % Add salt (white pixels - 255)
    salt_coords = randperm(num_pixels, num_salt);
    for i = 1:num_salt
        row = mod(salt_coords(i)-1, rows) + 1;
        col = floor((salt_coords(i)-1) / rows) + 1;
        noisy_img(row, col, :) = 255;
    end
    
    % Add pepper (black pixels - 0)
    pepper_coords = randperm(num_pixels, num_pepper);
    for i = 1:num_pepper
        row = mod(pepper_coords(i)-1, rows) + 1;
        col = floor((pepper_coords(i)-1) / rows) + 1;
        noisy_img(row, col, :) = 0;
    end
end

