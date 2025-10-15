%% Compare Custom Wiener Filter with MATLAB Built-in
% This script validates our custom implementation

clear; close all; clc;

fprintf('=== Comparing Custom vs Built-in Wiener Filter ===\n\n');

%% Load image
img = imread('test_images/gray1.jpg');
if size(img, 3) == 3
    img = rgb2gray(img);
end

%% Create motion blur
motion_length = 20;
motion_angle = 45;
psf = fspecial('motion', motion_length, motion_angle);

blurred = motion_blur(img, motion_length, motion_angle);

%% Restore with both methods
nsr = 0.01;

fprintf('Restoring with custom Wiener filter...\n');
restored_custom = wiener_filter(blurred, psf, nsr);

fprintf('Restoring with built-in deconvwnr...\n');
restored_builtin = deconvwnr(blurred, psf, nsr);

%% Calculate metrics
psnr_custom = psnr(restored_custom, img);
psnr_builtin = psnr(restored_builtin, img);

ssim_custom = ssim(restored_custom, img);
ssim_builtin = ssim(restored_builtin, img);

mse_custom = immse(restored_custom, img);
mse_builtin = immse(restored_builtin, img);

%% Display results
fprintf('\nPerformance Comparison:\n');
fprintf('%-20s %15s %15s\n', 'Metric', 'Custom', 'Built-in');
fprintf('%-20s %15.2f %15.2f\n', 'PSNR (dB)', psnr_custom, psnr_builtin);
fprintf('%-20s %15.4f %15.4f\n', 'SSIM', ssim_custom, ssim_builtin);
fprintf('%-20s %15.2f %15.2f\n', 'MSE', mse_custom, mse_builtin);

%% Visualize
figure('Name', 'Custom vs Built-in Wiener Filter Comparison', 'Position', [100, 100, 1400, 600]);

subplot(2, 3, 1);
imshow(img);
title('Original');

subplot(2, 3, 2);
imshow(blurred);
title('Motion Blurred');

subplot(2, 3, 3);
imshow(psf, []);
title('PSF');

subplot(2, 3, 4);
imshow(restored_custom);
title({'Custom Wiener Filter'; sprintf('PSNR: %.2f dB', psnr_custom)});

subplot(2, 3, 5);
imshow(restored_builtin);
title({'Built-in deconvwnr'; sprintf('PSNR: %.2f dB', psnr_builtin)});

subplot(2, 3, 6);
diff = abs(double(restored_custom) - double(restored_builtin));
imshow(diff, []);
title({'Difference Image'; sprintf('Max diff: %.2f', max(diff(:)))});
colormap(gca, 'hot');
colorbar;

fprintf('\nComparison completed!\n');

