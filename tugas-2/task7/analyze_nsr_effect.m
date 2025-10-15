%% Analyze Effect of NSR Parameter on Wiener Filter Performance
% This script helps find optimal NSR value

clear; close all; clc;

fprintf('=== NSR Parameter Analysis for Wiener Filter ===\n\n');

%% Load and blur image
img = imread('test_images/gray1.jpg');
if size(img, 3) == 3
    img = rgb2gray(img);
end

% Apply motion blur
motion_length = 25;
motion_angle = 30;
psf = fspecial('motion', motion_length, motion_angle);
blurred = motion_blur(img, motion_length, motion_angle);

%% Test different NSR values
nsr_values = [0.0001, 0.0005, 0.001, 0.005, 0.01, 0.02, 0.05, 0.1, 0.2];
num_nsr = length(nsr_values);

psnr_values = zeros(1, num_nsr);
ssim_values = zeros(1, num_nsr);
mse_values = zeros(1, num_nsr);

fprintf('Testing %d different NSR values...\n', num_nsr);

for i = 1:num_nsr
    restored = wiener_filter(blurred, psf, nsr_values(i));
    psnr_values(i) = psnr(restored, img);
    ssim_values(i) = ssim(restored, img);
    mse_values(i) = immse(restored, img);
    
    fprintf('NSR=%.4f: PSNR=%.2f dB, SSIM=%.4f, MSE=%.2f\n', ...
            nsr_values(i), psnr_values(i), ssim_values(i), mse_values(i));
end

%% Find optimal NSR
[max_psnr, idx_psnr] = max(psnr_values);
[max_ssim, idx_ssim] = max(ssim_values);
[min_mse, idx_mse] = min(mse_values);

fprintf('\nOptimal NSR values:\n');
fprintf('  Best PSNR: NSR=%.4f (%.2f dB)\n', nsr_values(idx_psnr), max_psnr);
fprintf('  Best SSIM: NSR=%.4f (%.4f)\n', nsr_values(idx_ssim), max_ssim);
fprintf('  Best MSE:  NSR=%.4f (%.2f)\n', nsr_values(idx_mse), min_mse);

%% Plot performance curves
figure('Name', 'NSR Parameter Analysis', 'Position', [100, 100, 1400, 500]);

subplot(1, 3, 1);
semilogx(nsr_values, psnr_values, 'b-o', 'LineWidth', 2, 'MarkerSize', 8);
hold on;
semilogx(nsr_values(idx_psnr), psnr_values(idx_psnr), 'r*', 'MarkerSize', 15, 'LineWidth', 2);
grid on;
xlabel('NSR (Noise-to-Signal Ratio)');
ylabel('PSNR (dB)');
title('PSNR vs NSR');
legend('PSNR', sprintf('Optimal (NSR=%.4f)', nsr_values(idx_psnr)), 'Location', 'best');

subplot(1, 3, 2);
semilogx(nsr_values, ssim_values, 'b-o', 'LineWidth', 2, 'MarkerSize', 8);
hold on;
semilogx(nsr_values(idx_ssim), ssim_values(idx_ssim), 'r*', 'MarkerSize', 15, 'LineWidth', 2);
grid on;
xlabel('NSR (Noise-to-Signal Ratio)');
ylabel('SSIM');
title('SSIM vs NSR');
legend('SSIM', sprintf('Optimal (NSR=%.4f)', nsr_values(idx_ssim)), 'Location', 'best');

subplot(1, 3, 3);
loglog(nsr_values, mse_values, 'b-o', 'LineWidth', 2, 'MarkerSize', 8);
hold on;
loglog(nsr_values(idx_mse), mse_values(idx_mse), 'r*', 'MarkerSize', 15, 'LineWidth', 2);
grid on;
xlabel('NSR (Noise-to-Signal Ratio)');
ylabel('MSE');
title('MSE vs NSR');
legend('MSE', sprintf('Optimal (NSR=%.4f)', nsr_values(idx_mse)), 'Location', 'best');

%% Visual comparison of key NSR values
key_indices = [1, idx_psnr, num_nsr];  % Lowest, optimal, highest
key_nsr = nsr_values(key_indices);

figure('Name', 'Visual Comparison of NSR Values', 'Position', [150, 150, 1400, 500]);

subplot(1, 4, 1);
imshow(img);
title('Original');

subplot(1, 4, 2);
imshow(blurred);
title('Blurred');

for i = 1:3
    restored = wiener_filter(blurred, psf, key_nsr(i));
    subplot(1, 4, 2 + i);
    imshow(restored);
    psnr_val = psnr(restored, img);
    title({sprintf('NSR=%.4f', key_nsr(i)); sprintf('PSNR=%.2f dB', psnr_val)});
end

fprintf('\nAnalysis completed!\n');

