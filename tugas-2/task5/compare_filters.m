% Compare filter performance on different noise types
% Calculates MSE and PSNR for each filter

function compare_filters()
    clear; clc; close all;
    
    % Load original image
    img = imread('test_images/color1.jpg');
    
    % Configuration
    filter_size = 3;
    sp_density = 0.05;
    gauss_var = 0.01;
    
    %% Test 1: Salt & Pepper Noise
    fprintf('=== Salt & Pepper Noise (density=%.2f) ===\n', sp_density);
    noisy_sp = add_salt_pepper_noise(img, sp_density);
    
    % Apply all filters
    filters_sp = struct();
    filters_sp.min = min_filter(noisy_sp, filter_size);
    filters_sp.max = max_filter(noisy_sp, filter_size);
    filters_sp.median = median_filter(noisy_sp, filter_size);
    filters_sp.arithmetic = arithmetic_mean_filter(noisy_sp, filter_size);
    filters_sp.geometric = geometric_mean_filter(noisy_sp, filter_size);
    filters_sp.harmonic = harmonic_mean_filter(noisy_sp, filter_size);
    filters_sp.contraharmonic_pos = contraharmonic_mean_filter(noisy_sp, filter_size, 1.5);
    filters_sp.contraharmonic_neg = contraharmonic_mean_filter(noisy_sp, filter_size, -1.5);
    filters_sp.midpoint = midpoint_filter(noisy_sp, filter_size);
    filters_sp.alpha_trimmed = alpha_trimmed_mean_filter(noisy_sp, filter_size, 2);
    
    % Calculate metrics
    fprintf('\nFilter Performance (MSE / PSNR):\n');
    fprintf('%-25s %10s %10s\n', 'Filter', 'MSE', 'PSNR (dB)');
    fprintf('%s\n', repmat('-', 1, 50));
    
    fields = fieldnames(filters_sp);
    for i = 1:length(fields)
        [mse_val, psnr_val] = calculate_metrics(img, filters_sp.(fields{i}));
        fprintf('%-25s %10.2f %10.2f\n', fields{i}, mse_val, psnr_val);
    end
    
    %% Test 2: Gaussian Noise
    fprintf('\n\n=== Gaussian Noise (variance=%.3f) ===\n', gauss_var);
    noisy_gauss = add_gaussian_noise(img, 0, gauss_var);
    
    % Apply all filters
    filters_gauss = struct();
    filters_gauss.min = min_filter(noisy_gauss, filter_size);
    filters_gauss.max = max_filter(noisy_gauss, filter_size);
    filters_gauss.median = median_filter(noisy_gauss, filter_size);
    filters_gauss.arithmetic = arithmetic_mean_filter(noisy_gauss, filter_size);
    filters_gauss.geometric = geometric_mean_filter(noisy_gauss, filter_size);
    filters_gauss.harmonic = harmonic_mean_filter(noisy_gauss, filter_size);
    filters_gauss.contraharmonic = contraharmonic_mean_filter(noisy_gauss, filter_size, 1.5);
    filters_gauss.midpoint = midpoint_filter(noisy_gauss, filter_size);
    filters_gauss.alpha_trimmed = alpha_trimmed_mean_filter(noisy_gauss, filter_size, 2);
    
    % Calculate metrics
    fprintf('\nFilter Performance (MSE / PSNR):\n');
    fprintf('%-25s %10s %10s\n', 'Filter', 'MSE', 'PSNR (dB)');
    fprintf('%s\n', repmat('-', 1, 50));
    
    fields = fieldnames(filters_gauss);
    for i = 1:length(fields)
        [mse_val, psnr_val] = calculate_metrics(img, filters_gauss.(fields{i}));
        fprintf('%-25s %10.2f %10.2f\n', fields{i}, mse_val, psnr_val);
    end
    
    %% Visualization
    visualize_results(img, noisy_sp, filters_sp, 'Salt & Pepper Noise');
    visualize_results(img, noisy_gauss, filters_gauss, 'Gaussian Noise');
    
    fprintf('\n\nConclusions:\n');
    fprintf('- Higher PSNR = Better quality (less error)\n');
    fprintf('- Lower MSE = Better match to original\n');
    fprintf('- For S&P noise: Median and Alpha-trimmed perform best\n');
    fprintf('- For Gaussian: Arithmetic and Geometric mean perform best\n');
end

function [mse, psnr] = calculate_metrics(original, filtered)
    % Calculate Mean Squared Error and Peak Signal-to-Noise Ratio
    original = double(original);
    filtered = double(filtered);
    
    mse = mean((original(:) - filtered(:)).^2);
    
    if mse == 0
        psnr = Inf;
    else
        max_pixel = 255;
        psnr = 10 * log10(max_pixel^2 / mse);
    end
end

function visualize_results(original, noisy, filters, noise_type)
    % Create visualization of top 5 performing filters
    fields = fieldnames(filters);
    
    % Calculate PSNR for all filters
    psnr_vals = zeros(length(fields), 1);
    for i = 1:length(fields)
        [~, psnr_vals(i)] = calculate_metrics(original, filters.(fields{i}));
    end
    
    % Sort by PSNR (descending)
    [~, sorted_idx] = sort(psnr_vals, 'descend');
    
    % Display top 5 filters
    figure('Name', ['Top Filters - ' noise_type], 'Position', [50 50 1400 500]);
    
    subplot(2,4,1);
    imshow(original);
    title('Original');
    
    subplot(2,4,2);
    imshow(noisy);
    title(['Noisy (' noise_type ')']);
    
    for i = 1:min(6, length(fields))
        idx = sorted_idx(i);
        subplot(2,4,i+2);
        imshow(filters.(fields{idx}));
        title(sprintf('%s\nPSNR: %.2f dB', strrep(fields{idx}, '_', ' '), psnr_vals(idx)));
    end
end

