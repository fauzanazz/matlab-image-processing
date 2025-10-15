%% Example Usage: Motion Blur and Wiener Deconvolution
% Simple examples showing how to use the functions

clear; close all; clc;

%% Example 1: Basic Usage - Grayscale Image
fprintf('Example 1: Basic Grayscale Image Processing\n');
fprintf('============================================\n\n');

% Load image
img_gray = imread('test_images/gray1.jpg');
if size(img_gray, 3) == 3
    img_gray = rgb2gray(img_gray);
end

% Apply motion blur
len = 20;
theta = 45;
blurred = motion_blur(img_gray, len, theta);

% Create PSF for deconvolution
psf = fspecial('motion', len, theta);

% Restore using Wiener filter
nsr = 0.01;  % Noise-to-Signal Ratio
restored = wiener_filter(blurred, psf, nsr);

% Display results
figure('Name', 'Example 1: Grayscale', 'Position', [100, 100, 1200, 400]);
subplot(1,3,1); imshow(img_gray); title('Original');
subplot(1,3,2); imshow(blurred); title('Blurred');
subplot(1,3,3); imshow(restored); title('Restored');

fprintf('PSNR: %.2f dB\n', psnr(restored, img_gray));
fprintf('SSIM: %.4f\n\n', ssim(restored, img_gray));

%% Example 2: Color Image
fprintf('Example 2: Color Image Processing\n');
fprintf('==================================\n\n');

% Load color image
img_color = imread('test_images/color1.jpg');

% Apply motion blur
blurred_color = motion_blur(img_color, len, theta);

% Restore
restored_color = wiener_filter(blurred_color, psf, nsr);

% Display
figure('Name', 'Example 2: Color', 'Position', [150, 150, 1200, 400]);
subplot(1,3,1); imshow(img_color); title('Original');
subplot(1,3,2); imshow(blurred_color); title('Blurred');
subplot(1,3,3); imshow(restored_color); title('Restored');

fprintf('PSNR: %.2f dB\n', psnr(restored_color, img_color));
fprintf('SSIM: %.4f\n\n', ssim(restored_color, img_color));

%% Example 3: Different Motion Parameters
fprintf('Example 3: Different Motion Directions\n');
fprintf('======================================\n\n');

angles = [0, 45, 90, 135];  % Different directions
figure('Name', 'Example 3: Motion Directions', 'Position', [200, 200, 1400, 800]);

for i = 1:length(angles)
    % Blur with different angle
    blurred_i = motion_blur(img_gray, len, angles(i));
    psf_i = fspecial('motion', len, angles(i));
    restored_i = wiener_filter(blurred_i, psf_i, nsr);
    
    % Display
    subplot(3, 4, i);
    imshow(blurred_i);
    title(sprintf('Blurred θ=%d°', angles(i)));
    
    subplot(3, 4, 4 + i);
    imshow(restored_i);
    title(sprintf('Restored θ=%d°', angles(i)));
    
    subplot(3, 4, 8 + i);
    imshow(psf_i, []);
    title(sprintf('PSF θ=%d°', angles(i)));
    
    fprintf('Angle %d°: PSNR = %.2f dB\n', angles(i), psnr(restored_i, img_gray));
end

%% Example 4: Visualize PSF
fprintf('\nExample 4: PSF Visualization\n');
fprintf('============================\n\n');

% Visualize PSF characteristics
visualize_psf(25, 30);
fprintf('PSF visualization displayed.\n\n');

%% Example 5: Finding Optimal NSR
fprintf('Example 5: Optimal NSR Value\n');
fprintf('============================\n\n');

nsr_test = [0.001, 0.005, 0.01, 0.05, 0.1];
psnr_values = zeros(size(nsr_test));

for i = 1:length(nsr_test)
    restored_test = wiener_filter(blurred, psf, nsr_test(i));
    psnr_values(i) = psnr(restored_test, img_gray);
    fprintf('NSR = %.3f → PSNR = %.2f dB\n', nsr_test(i), psnr_values(i));
end

[~, best_idx] = max(psnr_values);
fprintf('\nOptimal NSR: %.3f (PSNR: %.2f dB)\n', nsr_test(best_idx), psnr_values(best_idx));

% Plot
figure('Name', 'Example 5: NSR Optimization', 'Position', [250, 250, 600, 400]);
semilogx(nsr_test, psnr_values, 'bo-', 'LineWidth', 2, 'MarkerSize', 10);
hold on;
semilogx(nsr_test(best_idx), psnr_values(best_idx), 'r*', 'MarkerSize', 15, 'LineWidth', 2);
grid on;
xlabel('NSR (Noise-to-Signal Ratio)');
ylabel('PSNR (dB)');
title('PSNR vs NSR');
legend('PSNR', 'Optimal', 'Location', 'best');

fprintf('\n=== All examples completed! ===\n');

