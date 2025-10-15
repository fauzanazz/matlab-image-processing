%% Demo: Motion Blur and Wiener Filter Deconvolution
% Simple demonstration of motion blur and restoration

clear; close all; clc;

%% Load and prepare image
fprintf('=== Motion Blur and Wiener Deconvolution Demo ===\n\n');

% Test with grayscale image
img = imread('test_images/gray1.jpg');
if size(img, 3) == 3
    img = rgb2gray(img);
end

fprintf('Image loaded: %dx%d\n', size(img, 1), size(img, 2));

%% Apply Motion Blur
motion_length = 25;
motion_angle = 30;

fprintf('Applying motion blur (length=%d, angle=%d°)...\n', motion_length, motion_angle);

% Create PSF and apply blur
psf = fspecial('motion', motion_length, motion_angle);
blurred = motion_blur(img, motion_length, motion_angle);

%% Restore using Wiener Filter
fprintf('Restoring image using custom Wiener filter...\n');

% Try different NSR values
nsr = 0.01;  % Optimal NSR value
restored = wiener_filter(blurred, psf, nsr);

%% Calculate metrics
psnr_blurred = psnr(blurred, img);
psnr_restored = psnr(restored, img);
ssim_blurred = ssim(blurred, img);
ssim_restored = ssim(restored, img);

fprintf('\nResults:\n');
fprintf('  Blurred  - PSNR: %.2f dB, SSIM: %.4f\n', psnr_blurred, ssim_blurred);
fprintf('  Restored - PSNR: %.2f dB, SSIM: %.4f\n', psnr_restored, ssim_restored);
fprintf('  Improvement: %.2f dB\n', psnr_restored - psnr_blurred);

%% Display Results
figure('Name', 'Motion Blur and Wiener Deconvolution Demo', 'Position', [100, 100, 1400, 500]);

subplot(1, 4, 1);
imshow(img);
title('Original Image');

subplot(1, 4, 2);
imshow(blurred);
title({'Motion Blurred'; sprintf('PSNR: %.2f dB', psnr_blurred)});

subplot(1, 4, 3);
imshow(restored);
title({'Wiener Restored'; sprintf('PSNR: %.2f dB', psnr_restored)});

subplot(1, 4, 4);
imshow(psf, []);
title({'Point Spread Function'; sprintf('L=%d, θ=%d°', motion_length, motion_angle)});

%% Color Image Test
fprintf('\nTesting with color image...\n');
color_img = imread('test_images/color1.jpg');

blurred_color = motion_blur(color_img, motion_length, motion_angle);
restored_color = wiener_filter(blurred_color, psf, nsr);

psnr_val = psnr(restored_color, color_img);
ssim_val = ssim(restored_color, color_img);

fprintf('Color image - PSNR: %.2f dB, SSIM: %.4f\n', psnr_val, ssim_val);

figure('Name', 'Color Image Restoration', 'Position', [150, 150, 1200, 400]);

subplot(1, 3, 1);
imshow(color_img);
title('Original Color Image');

subplot(1, 3, 2);
imshow(blurred_color);
title('Motion Blurred');

subplot(1, 3, 3);
imshow(restored_color);
title({'Wiener Restored'; sprintf('PSNR: %.2f dB', psnr_val)});

fprintf('\nDemo completed!\n');

