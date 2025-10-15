% Demonstration script for individual filters
% Shows the effect of each filter on salt & pepper and Gaussian noise

clear; clc; close all;

%% Load test image
img = imread('test_images/color1.jpg');

% Display options
figure_width = 1200;
figure_height = 400;

%% Demo 1: Salt & Pepper Noise - Best Filters
fprintf('Demo 1: Salt & Pepper Noise Removal\n');

% Add noise
noisy_sp = add_salt_pepper_noise(img, 0.05);

% Apply filters
median_result = median_filter(noisy_sp, 3);
alpha_result = alpha_trimmed_mean_filter(noisy_sp, 3, 2);
contra_pos = contraharmonic_mean_filter(noisy_sp, 3, 1.5);

figure('Name', 'Salt & Pepper Noise - Best Filters', 'Position', [50 50 figure_width figure_height]);
subplot(1,4,1); imshow(img); title('Original');
subplot(1,4,2); imshow(noisy_sp); title('Noisy (S&P 5%)');
subplot(1,4,3); imshow(median_result); title('Median Filter');
subplot(1,4,4); imshow(alpha_result); title('Alpha-Trimmed Mean');

%% Demo 2: Gaussian Noise - Best Filters
fprintf('Demo 2: Gaussian Noise Removal\n');

% Add Gaussian noise
noisy_gauss = add_gaussian_noise(img, 0, 0.01);

% Apply filters
arith_result = arithmetic_mean_filter(noisy_gauss, 3);
geo_result = geometric_mean_filter(noisy_gauss, 3);
median_gauss = median_filter(noisy_gauss, 3);

figure('Name', 'Gaussian Noise - Best Filters', 'Position', [100 100 figure_width figure_height]);
subplot(1,4,1); imshow(img); title('Original');
subplot(1,4,2); imshow(noisy_gauss); title('Noisy (Gaussian)');
subplot(1,4,3); imshow(arith_result); title('Arithmetic Mean');
subplot(1,4,4); imshow(geo_result); title('Geometric Mean');

%% Demo 3: Min/Max Filters on Salt & Pepper
fprintf('Demo 3: Min/Max Filters on Salt & Pepper Noise\n');

min_result = min_filter(noisy_sp, 3);
max_result = max_filter(noisy_sp, 3);

figure('Name', 'Min/Max Filters', 'Position', [150 150 figure_width figure_height]);
subplot(1,4,1); imshow(img); title('Original');
subplot(1,4,2); imshow(noisy_sp); title('Noisy (S&P)');
subplot(1,4,3); imshow(min_result); title('Min Filter (removes salt)');
subplot(1,4,4); imshow(max_result); title('Max Filter (removes pepper)');

%% Demo 4: Contraharmonic Filter with Different Q Values
fprintf('Demo 4: Contraharmonic Filter with Different Q Values\n');

contra_neg = contraharmonic_mean_filter(noisy_sp, 3, -1.5);
contra_zero = contraharmonic_mean_filter(noisy_sp, 3, 0);
contra_pos2 = contraharmonic_mean_filter(noisy_sp, 3, 1.5);

figure('Name', 'Contraharmonic Filter - Different Q', 'Position', [200 200 figure_width figure_height]);
subplot(1,4,1); imshow(noisy_sp); title('Noisy (S&P)');
subplot(1,4,2); imshow(contra_neg); title('Q = -1.5 (removes salt)');
subplot(1,4,3); imshow(contra_zero); title('Q = 0 (arithmetic mean)');
subplot(1,4,4); imshow(contra_pos2); title('Q = 1.5 (removes pepper)');

%% Demo 5: Grayscale Image Test
fprintf('Demo 5: Grayscale Image Test\n');

gray_img = imread('test_images/gray1.jpg');
if size(gray_img, 3) == 3
    gray_img = rgb2gray(gray_img);
end

gray_noisy = add_salt_pepper_noise(gray_img, 0.1);
gray_median = median_filter(gray_noisy, 5);
gray_alpha = alpha_trimmed_mean_filter(gray_noisy, 5, 3);

figure('Name', 'Grayscale Image - Heavy Noise', 'Position', [250 250 figure_width figure_height]);
subplot(1,4,1); imshow(gray_img); title('Original Grayscale');
subplot(1,4,2); imshow(gray_noisy); title('Noisy (S&P 10%)');
subplot(1,4,3); imshow(gray_median); title('Median Filter (5x5)');
subplot(1,4,4); imshow(gray_alpha); title('Alpha-Trimmed (5x5, d=3)');

fprintf('\nAll demonstrations completed!\n');
fprintf('\nKey Observations:\n');
fprintf('- Median filter: Best for salt & pepper noise\n');
fprintf('- Arithmetic mean: Good for Gaussian noise but blurs image\n');
fprintf('- Geometric mean: Similar to arithmetic but preserves details better\n');
fprintf('- Contraharmonic: Q>0 removes pepper, Q<0 removes salt\n');
fprintf('- Alpha-trimmed: Robust for mixed noise types\n');
fprintf('- Min filter: Removes salt (white) noise\n');
fprintf('- Max filter: Removes pepper (black) noise\n');

