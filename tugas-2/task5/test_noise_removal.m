% Test script for noise addition and removal filters
% Tests both salt & pepper and Gaussian noise on grayscale and color images

clear; clc; close all;

%% Configuration
filter_size = 3;
sp_noise_density = 0.05;  % Salt & pepper noise density
gaussian_variance = 0.01;  % Gaussian noise variance

%% Test 1: Grayscale Image with Salt & Pepper Noise
fprintf('=== Test 1: Grayscale Image with Salt & Pepper Noise ===\n');

% Load grayscale image
gray_img = imread('test_images/gray1.jpg');
if size(gray_img, 3) == 3
    gray_img = rgb2gray(gray_img);
end

% Add salt & pepper noise
gray_noisy_sp = add_salt_pepper_noise(gray_img, sp_noise_density);

% Apply all filters
gray_min = min_filter(gray_noisy_sp, filter_size);
gray_max = max_filter(gray_noisy_sp, filter_size);
gray_median = median_filter(gray_noisy_sp, filter_size);
gray_arith = arithmetic_mean_filter(gray_noisy_sp, filter_size);
gray_geo = geometric_mean_filter(gray_noisy_sp, filter_size);
gray_harm = harmonic_mean_filter(gray_noisy_sp, filter_size);
gray_contra_pos = contraharmonic_mean_filter(gray_noisy_sp, filter_size, 1.5);
gray_contra_neg = contraharmonic_mean_filter(gray_noisy_sp, filter_size, -1.5);
gray_midpoint = midpoint_filter(gray_noisy_sp, filter_size);
gray_alpha = alpha_trimmed_mean_filter(gray_noisy_sp, filter_size, 2);

% Display results
figure('Name', 'Grayscale - Salt & Pepper Noise', 'Position', [50 50 1400 800]);
subplot(3,4,1); imshow(gray_img); title('Original');
subplot(3,4,2); imshow(gray_noisy_sp); title('Noisy (S&P)');
subplot(3,4,3); imshow(gray_min); title('Min Filter');
subplot(3,4,4); imshow(gray_max); title('Max Filter');
subplot(3,4,5); imshow(gray_median); title('Median Filter');
subplot(3,4,6); imshow(gray_arith); title('Arithmetic Mean');
subplot(3,4,7); imshow(gray_geo); title('Geometric Mean');
subplot(3,4,8); imshow(gray_harm); title('Harmonic Mean');
subplot(3,4,9); imshow(gray_contra_pos); title('Contraharmonic (Q=1.5)');
subplot(3,4,10); imshow(gray_contra_neg); title('Contraharmonic (Q=-1.5)');
subplot(3,4,11); imshow(gray_midpoint); title('Midpoint Filter');
subplot(3,4,12); imshow(gray_alpha); title('Alpha-Trimmed Mean');

%% Test 2: Grayscale Image with Gaussian Noise
fprintf('=== Test 2: Grayscale Image with Gaussian Noise ===\n');

% Add Gaussian noise
gray_noisy_gauss = add_gaussian_noise(gray_img, 0, gaussian_variance);

% Apply all filters
gray_gauss_min = min_filter(gray_noisy_gauss, filter_size);
gray_gauss_max = max_filter(gray_noisy_gauss, filter_size);
gray_gauss_median = median_filter(gray_noisy_gauss, filter_size);
gray_gauss_arith = arithmetic_mean_filter(gray_noisy_gauss, filter_size);
gray_gauss_geo = geometric_mean_filter(gray_noisy_gauss, filter_size);
gray_gauss_harm = harmonic_mean_filter(gray_noisy_gauss, filter_size);
gray_gauss_contra = contraharmonic_mean_filter(gray_noisy_gauss, filter_size, 1.5);
gray_gauss_midpoint = midpoint_filter(gray_noisy_gauss, filter_size);
gray_gauss_alpha = alpha_trimmed_mean_filter(gray_noisy_gauss, filter_size, 2);

% Display results
figure('Name', 'Grayscale - Gaussian Noise', 'Position', [100 100 1400 800]);
subplot(3,4,1); imshow(gray_img); title('Original');
subplot(3,4,2); imshow(gray_noisy_gauss); title('Noisy (Gaussian)');
subplot(3,4,3); imshow(gray_gauss_min); title('Min Filter');
subplot(3,4,4); imshow(gray_gauss_max); title('Max Filter');
subplot(3,4,5); imshow(gray_gauss_median); title('Median Filter');
subplot(3,4,6); imshow(gray_gauss_arith); title('Arithmetic Mean');
subplot(3,4,7); imshow(gray_gauss_geo); title('Geometric Mean');
subplot(3,4,8); imshow(gray_gauss_harm); title('Harmonic Mean');
subplot(3,4,9); imshow(gray_gauss_contra); title('Contraharmonic (Q=1.5)');
subplot(3,4,10); imshow(gray_gauss_midpoint); title('Midpoint Filter');
subplot(3,4,11); imshow(gray_gauss_alpha); title('Alpha-Trimmed Mean');

%% Test 3: Color Image with Salt & Pepper Noise
fprintf('=== Test 3: Color Image with Salt & Pepper Noise ===\n');

% Load color image
color_img = imread('test_images/color1.jpg');

% Add salt & pepper noise
color_noisy_sp = add_salt_pepper_noise(color_img, sp_noise_density);

% Apply all filters
color_min = min_filter(color_noisy_sp, filter_size);
color_max = max_filter(color_noisy_sp, filter_size);
color_median = median_filter(color_noisy_sp, filter_size);
color_arith = arithmetic_mean_filter(color_noisy_sp, filter_size);
color_geo = geometric_mean_filter(color_noisy_sp, filter_size);
color_harm = harmonic_mean_filter(color_noisy_sp, filter_size);
color_contra_pos = contraharmonic_mean_filter(color_noisy_sp, filter_size, 1.5);
color_contra_neg = contraharmonic_mean_filter(color_noisy_sp, filter_size, -1.5);
color_midpoint = midpoint_filter(color_noisy_sp, filter_size);
color_alpha = alpha_trimmed_mean_filter(color_noisy_sp, filter_size, 2);

% Display results
figure('Name', 'Color - Salt & Pepper Noise', 'Position', [150 150 1400 800]);
subplot(3,4,1); imshow(color_img); title('Original');
subplot(3,4,2); imshow(color_noisy_sp); title('Noisy (S&P)');
subplot(3,4,3); imshow(color_min); title('Min Filter');
subplot(3,4,4); imshow(color_max); title('Max Filter');
subplot(3,4,5); imshow(color_median); title('Median Filter');
subplot(3,4,6); imshow(color_arith); title('Arithmetic Mean');
subplot(3,4,7); imshow(color_geo); title('Geometric Mean');
subplot(3,4,8); imshow(color_harm); title('Harmonic Mean');
subplot(3,4,9); imshow(color_contra_pos); title('Contraharmonic (Q=1.5)');
subplot(3,4,10); imshow(color_contra_neg); title('Contraharmonic (Q=-1.5)');
subplot(3,4,11); imshow(color_midpoint); title('Midpoint Filter');
subplot(3,4,12); imshow(color_alpha); title('Alpha-Trimmed Mean');

%% Test 4: Color Image with Gaussian Noise
fprintf('=== Test 4: Color Image with Gaussian Noise ===\n');

% Add Gaussian noise
color_noisy_gauss = add_gaussian_noise(color_img, 0, gaussian_variance);

% Apply all filters
color_gauss_min = min_filter(color_noisy_gauss, filter_size);
color_gauss_max = max_filter(color_noisy_gauss, filter_size);
color_gauss_median = median_filter(color_noisy_gauss, filter_size);
color_gauss_arith = arithmetic_mean_filter(color_noisy_gauss, filter_size);
color_gauss_geo = geometric_mean_filter(color_noisy_gauss, filter_size);
color_gauss_harm = harmonic_mean_filter(color_noisy_gauss, filter_size);
color_gauss_contra = contraharmonic_mean_filter(color_noisy_gauss, filter_size, 1.5);
color_gauss_midpoint = midpoint_filter(color_noisy_gauss, filter_size);
color_gauss_alpha = alpha_trimmed_mean_filter(color_noisy_gauss, filter_size, 2);

% Display results
figure('Name', 'Color - Gaussian Noise', 'Position', [200 200 1400 800]);
subplot(3,4,1); imshow(color_img); title('Original');
subplot(3,4,2); imshow(color_noisy_gauss); title('Noisy (Gaussian)');
subplot(3,4,3); imshow(color_gauss_min); title('Min Filter');
subplot(3,4,4); imshow(color_gauss_max); title('Max Filter');
subplot(3,4,5); imshow(color_gauss_median); title('Median Filter');
subplot(3,4,6); imshow(color_gauss_arith); title('Arithmetic Mean');
subplot(3,4,7); imshow(color_gauss_geo); title('Geometric Mean');
subplot(3,4,8); imshow(color_gauss_harm); title('Harmonic Mean');
subplot(3,4,9); imshow(color_gauss_contra); title('Contraharmonic (Q=1.5)');
subplot(3,4,10); imshow(color_gauss_midpoint); title('Midpoint Filter');
subplot(3,4,11); imshow(color_gauss_alpha); title('Alpha-Trimmed Mean');

fprintf('\nAll tests completed!\n');

