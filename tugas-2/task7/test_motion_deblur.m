%% Test Motion Blur and Wiener Filter Deconvolution
% This script demonstrates motion blurring and restoration using custom Wiener filter

clear; close all; clc;

%% Parameters
motion_length = 21;     % Length of motion blur (pixels)
motion_angle = 45;      % Angle of motion (degrees)
nsr_values = [0.001, 0.01, 0.1];  % Noise-to-Signal Ratios to test

%% Test on Grayscale Image
fprintf('Testing on Grayscale Image...\n');
gray_img = imread('test_images/gray1.jpg');

% Ensure grayscale
if size(gray_img, 3) == 3
    gray_img = rgb2gray(gray_img);
end

% Apply motion blur
psf = fspecial('motion', motion_length, motion_angle);
blurred_gray = motion_blur(gray_img, motion_length, motion_angle);

% Test different NSR values
figure('Name', 'Grayscale Image - Motion Blur and Wiener Restoration', 'Position', [100, 100, 1400, 800]);

subplot(2, 4, 1);
imshow(gray_img);
title('Original');

subplot(2, 4, 2);
imshow(blurred_gray);
title(sprintf('Motion Blurred\nLen=%d, θ=%d°', motion_length, motion_angle));

for i = 1:length(nsr_values)
    restored = wiener_filter(blurred_gray, psf, nsr_values(i));
    
    subplot(2, 4, 2 + i);
    imshow(restored);
    title(sprintf('Restored (NSR=%.3f)', nsr_values(i)));
    
    % Calculate PSNR
    psnr_val = psnr(restored, gray_img);
    xlabel(sprintf('PSNR: %.2f dB', psnr_val));
end

% Show PSF
subplot(2, 4, 6);
imshow(psf, []);
title('PSF (Point Spread Function)');

% Show frequency response
subplot(2, 4, 7);
H = fft2(psf, size(gray_img, 1), size(gray_img, 2));
imshow(log(1 + abs(fftshift(H))), []);
title('PSF Frequency Response');
colormap(gca, 'jet');
colorbar;

% Show difference image
best_nsr = nsr_values(2);
restored_best = wiener_filter(blurred_gray, psf, best_nsr);
subplot(2, 4, 8);
diff_img = abs(double(gray_img) - double(restored_best));
imshow(diff_img, []);
title(sprintf('Difference Image\n(Original - Restored)'));
colormap(gca, 'hot');
colorbar;

%% Test on Color Image
fprintf('Testing on Color Image...\n');
color_img = imread('test_images/color1.jpg');

% Apply motion blur
blurred_color = motion_blur(color_img, motion_length, motion_angle);

% Test different NSR values
figure('Name', 'Color Image - Motion Blur and Wiener Restoration', 'Position', [150, 50, 1400, 800]);

subplot(2, 4, 1);
imshow(color_img);
title('Original');

subplot(2, 4, 2);
imshow(blurred_color);
title(sprintf('Motion Blurred\nLen=%d, θ=%d°', motion_length, motion_angle));

for i = 1:length(nsr_values)
    restored = wiener_filter(blurred_color, psf, nsr_values(i));
    
    subplot(2, 4, 2 + i);
    imshow(restored);
    title(sprintf('Restored (NSR=%.3f)', nsr_values(i)));
    
    % Calculate PSNR
    psnr_val = psnr(restored, color_img);
    xlabel(sprintf('PSNR: %.2f dB', psnr_val));
end

% Show PSF
subplot(2, 4, 6);
imshow(psf, []);
title('PSF (Point Spread Function)');

% Show each channel separately
best_nsr = nsr_values(2);
restored_best = wiener_filter(blurred_color, psf, best_nsr);

subplot(2, 4, 7);
imshow(cat(3, restored_best(:,:,1), restored_best(:,:,1)*0, restored_best(:,:,1)*0));
title('Restored - Red Channel');

subplot(2, 4, 8);
imshow(cat(3, restored_best(:,:,2)*0, restored_best(:,:,2), restored_best(:,:,2)*0));
title('Restored - Green Channel');

%% Comparison with Different Motion Parameters
fprintf('Testing different motion parameters...\n');
motion_configs = [
    15, 0;    % Horizontal
    15, 90;   % Vertical
    25, 45;   % Diagonal
    30, 30    % Custom angle
];

figure('Name', 'Different Motion Blur Configurations', 'Position', [200, 100, 1400, 900]);

for i = 1:size(motion_configs, 1)
    len = motion_configs(i, 1);
    angle = motion_configs(i, 2);
    
    % Create PSF
    psf_curr = fspecial('motion', len, angle);
    
    % Apply blur
    blurred = motion_blur(gray_img, len, angle);
    
    % Restore with optimal NSR
    restored = wiener_filter(blurred, psf_curr, 0.01);
    
    % Display
    subplot(4, 4, (i-1)*4 + 1);
    imshow(gray_img);
    if i == 1
        title('Original');
    end
    
    subplot(4, 4, (i-1)*4 + 2);
    imshow(blurred);
    title(sprintf('Blurred (L=%d, θ=%d°)', len, angle));
    
    subplot(4, 4, (i-1)*4 + 3);
    imshow(restored);
    psnr_val = psnr(restored, gray_img);
    title(sprintf('Restored (PSNR=%.2f)', psnr_val));
    
    subplot(4, 4, (i-1)*4 + 4);
    imshow(psf_curr, []);
    title('PSF');
end

%% Performance Analysis
fprintf('\n=== Performance Analysis ===\n');
fprintf('Motion Parameters: Length=%d, Angle=%d°\n', motion_length, motion_angle);
fprintf('\nGrayscale Image Results:\n');

for i = 1:length(nsr_values)
    restored = wiener_filter(blurred_gray, psf, nsr_values(i));
    psnr_val = psnr(restored, gray_img);
    ssim_val = ssim(restored, gray_img);
    mse_val = immse(restored, gray_img);
    
    fprintf('  NSR=%.3f: PSNR=%.2f dB, SSIM=%.4f, MSE=%.2f\n', ...
            nsr_values(i), psnr_val, ssim_val, mse_val);
end

fprintf('\nColor Image Results:\n');
for i = 1:length(nsr_values)
    restored = wiener_filter(blurred_color, psf, nsr_values(i));
    psnr_val = psnr(restored, color_img);
    ssim_val = ssim(restored, color_img);
    mse_val = immse(restored, color_img);
    
    fprintf('  NSR=%.3f: PSNR=%.2f dB, SSIM=%.4f, MSE=%.2f\n', ...
            nsr_values(i), psnr_val, ssim_val, mse_val);
end

fprintf('\nTest completed successfully!\n');

