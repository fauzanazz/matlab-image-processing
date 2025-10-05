function comparison = compare_with_builtin(img, show_plots)
    % Input: img - input image (grayscale or color)
    %        show_plots - boolean to display comparison plots (default: true)
    % Output: comparison - struct with comparison metrics
    
    addpath('../task1');
    
    if nargin < 2
        show_plots = true;
    end
    
    if size(img, 3) == 3
        img_test = rgb2gray(img);
        fprintf('Converting color image to grayscale for comparison...\n');
    else
        img_test = img;
    end
    
    tic;
    custom_result = histogram_equalization(img_test);
    custom_time = toc;
    
    tic;
    builtin_result = histeq(img_test);
    builtin_time = toc;
    
    comparison = calculate_comparison_metrics(img_test, custom_result, builtin_result);
    comparison.custom_time = custom_time;
    comparison.builtin_time = builtin_time;
    
    display_comparison_results(comparison);
    
    if show_plots
        create_comparison_plots(img_test, custom_result, builtin_result, comparison);
    end
end

function metrics = calculate_comparison_metrics(original, custom, builtin)
    metrics = struct();
    metrics.original_stats = get_image_stats(original);
    metrics.custom_stats = get_image_stats(custom);
    metrics.builtin_stats = get_image_stats(builtin);
    
    hist_orig = calculate_histogram(original);
    hist_custom = calculate_histogram(custom);
    hist_builtin = imhist(builtin)'; 
    
    metrics.original_entropy = calculate_entropy(hist_orig);
    metrics.custom_entropy = calculate_entropy(hist_custom);
    metrics.builtin_entropy = calculate_entropy(hist_builtin);
    
    metrics.mse = mean((double(custom(:)) - double(builtin(:))).^2);
    metrics.psnr = 10 * log10(255^2 / metrics.mse);
    metrics.ssim = calculate_ssim(custom, builtin);
    metrics.histogram_correlation = corr(hist_custom', hist_builtin');
    
    diff_image = abs(double(custom) - double(builtin));
    metrics.max_difference = max(diff_image(:));
    metrics.mean_difference = mean(diff_image(:));
    metrics.std_difference = std(diff_image(:));
    
    identical_pixels = sum(custom(:) == builtin(:));
    total_pixels = numel(custom);
    metrics.identical_pixel_percentage = (identical_pixels / total_pixels) * 100;
end

function stats = get_image_stats(img)
    stats.min = double(min(img(:)));
    stats.max = double(max(img(:)));
    stats.mean = mean(double(img(:)));
    stats.std = std(double(img(:)));
    stats.range = stats.max - stats.min;
end

function ssim_value = calculate_ssim(img1, img2)
    img1 = double(img1);
    img2 = double(img2);
    
    K1 = 0.01;
    K2 = 0.03;
    L = 255;
    
    C1 = (K1 * L)^2;
    C2 = (K2 * L)^2;
    
    mu1 = mean(img1(:));
    mu2 = mean(img2(:));
    
    sigma1_sq = var(img1(:));
    sigma2_sq = var(img2(:));
    sigma12 = cov(img1(:), img2(:));
    sigma12 = sigma12(1, 2);
    
    numerator = (2 * mu1 * mu2 + C1) * (2 * sigma12 + C2);
    denominator = (mu1^2 + mu2^2 + C1) * (sigma1_sq + sigma2_sq + C2);
    ssim_value = numerator / denominator;
end

function display_comparison_results(comparison)
    fprintf('\n=== CUSTOM vs BUILT-IN HISTOGRAM EQUALIZATION COMPARISON ===\n');
    fprintf('\nPERFORMANCE:\n');
    fprintf('  Custom Implementation: %.4f seconds\n', comparison.custom_time);
    fprintf('  Built-in histeq(): %.4f seconds\n', comparison.builtin_time);
    fprintf('  Speed Ratio: %.2fx %s\n', abs(comparison.custom_time / comparison.builtin_time), ...
        iff(comparison.custom_time > comparison.builtin_time, 'slower', 'faster'));
    
    fprintf('\nENTROPY COMPARISON:\n');
    fprintf('  Original: %.3f bits\n', comparison.original_entropy);
    fprintf('  Custom: %.3f bits\n', comparison.custom_entropy);
    fprintf('  Built-in: %.3f bits\n', comparison.builtin_entropy);
    fprintf('  Entropy Difference: %.6f bits\n', abs(comparison.custom_entropy - comparison.builtin_entropy));
    
    fprintf('\nSIMILARITY METRICS:\n');
    fprintf('  MSE: %.3f\n', comparison.mse);
    fprintf('  PSNR: %.2f dB\n', comparison.psnr);
    fprintf('  SSIM: %.6f\n', comparison.ssim);
    fprintf('  Histogram Correlation: %.6f\n', comparison.histogram_correlation);
    
    fprintf('\nPIXEL-WISE ANALYSIS:\n');
    fprintf('  Identical Pixels: %.2f%%\n', comparison.identical_pixel_percentage);
    fprintf('  Max Difference: %d intensity levels\n', comparison.max_difference);
    fprintf('  Mean Difference: %.3f intensity levels\n', comparison.mean_difference);
    fprintf('  Std Difference: %.3f intensity levels\n', comparison.std_difference);
    
    fprintf('\nOVERALL ASSESSMENT:\n');
    fprintf('  %s\n', get_comparison_assessment(comparison));
end

function assessment = get_comparison_assessment(comparison)
    ssim_threshold = 0.95;
    correlation_threshold = 0.95;
    identical_threshold = 95.0;
    
    if comparison.ssim > ssim_threshold && ...
       comparison.histogram_correlation > correlation_threshold && ...
       comparison.identical_pixel_percentage > identical_threshold
        assessment = 'EXCELLENT - Custom implementation matches built-in very closely';
    elseif comparison.ssim > 0.90 && comparison.histogram_correlation > 0.90
        assessment = 'GOOD - Custom implementation is highly similar to built-in';
    elseif comparison.ssim > 0.80 && comparison.histogram_correlation > 0.80
        assessment = 'ACCEPTABLE - Custom implementation shows good similarity';
    else
        assessment = 'NEEDS REVIEW - Significant differences detected';
    end
end

function create_comparison_plots(original, custom, builtin, comparison)
    figure('Name', 'Custom vs Built-in Comparison', 'Position', [50 50 1500 1000]);
    
    subplot(3,4,1);
    imshow(original);
    title('Original Image', 'FontWeight', 'bold');
    
    subplot(3,4,2);
    imshow(custom);
    title('Custom Equalization', 'FontWeight', 'bold');
    
    subplot(3,4,3);
    imshow(builtin);
    title('Built-in histeq()', 'FontWeight', 'bold');
    
    subplot(3,4,4);
    diff_img = abs(double(custom) - double(builtin));
    imshow(diff_img, []);
    colorbar;
    title(sprintf('Absolute Difference\nMax: %d', comparison.max_difference), 'FontWeight', 'bold');
    
    hist_orig = calculate_histogram(original);
    hist_custom = calculate_histogram(custom);
    hist_builtin = imhist(builtin)';
    
    subplot(3,4,5);
    bar(0:255, hist_orig, 'FaceColor', [0.5 0.5 0.5], 'EdgeColor', 'none');
    title('Original Histogram');
    xlim([0 255]);
    ylabel('Frequency');
    
    subplot(3,4,6);
    bar(0:255, hist_custom, 'FaceColor', [0.2 0.6 0.2], 'EdgeColor', 'none');
    title('Custom Histogram');
    xlim([0 255]);
    
    subplot(3,4,7);
    bar(0:255, hist_builtin, 'FaceColor', [0.6 0.2 0.2], 'EdgeColor', 'none');
    title('Built-in Histogram');
    xlim([0 255]);
    
    subplot(3,4,8);
    plot(0:255, hist_custom, 'g-', 'LineWidth', 1.5, 'DisplayName', 'Custom');
    hold on;
    plot(0:255, hist_builtin, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Built-in');
    hold off;
    title('Histogram Overlay');
    legend();
    xlim([0 255]);
    
    cdf_custom = cumsum(hist_custom) / sum(hist_custom);
    cdf_builtin = cumsum(hist_builtin) / sum(hist_builtin);
    
    subplot(3,4,9);
    plot(0:255, cdf_custom, 'g-', 'LineWidth', 2, 'DisplayName', 'Custom CDF');
    hold on;
    plot(0:255, cdf_builtin, 'r--', 'LineWidth', 2, 'DisplayName', 'Built-in CDF');
    plot([0 255], [0 1], 'k:', 'DisplayName', 'Ideal');
    hold off;
    title('CDF Comparison');
    xlabel('Intensity');
    ylabel('Cumulative Probability');
    legend();
    xlim([0 255]);
    ylim([0 1]);
    
    subplot(3,4,10);
    metrics_names = {'SSIM', 'Correlation', 'Identical%'};
    metrics_values = [comparison.ssim, comparison.histogram_correlation, comparison.identical_pixel_percentage/100];
    bar(metrics_values, 'FaceColor', [0.3 0.6 0.9]);
    set(gca, 'XTickLabel', metrics_names);
    title('Similarity Metrics');
    ylabel('Score');
    ylim([0 1.1]);
    
    hold on;
    plot([0.5 3.5], [0.95 0.95], 'r--', 'LineWidth', 1);
    text(2, 0.97, 'Excellent Threshold', 'HorizontalAlignment', 'center');
    hold off;
    
    subplot(3,4,11);
    diff_values = abs(double(custom(:)) - double(builtin(:)));
    histogram(diff_values, 'FaceColor', [0.8 0.4 0.8], 'EdgeColor', 'none');
    title('Pixel Difference Distribution');
    xlabel('Absolute Difference');
    ylabel('Frequency');
    
    subplot(3,4,12);
    axis off;
    summary_text = sprintf(['COMPARISON SUMMARY:\n\n' ...
        'SSIM: %.4f\n' ...
        'Correlation: %.4f\n' ...
        'Identical Pixels: %.1f%%\n' ...
        'Max Difference: %d\n' ...
        'Mean Difference: %.3f\n\n' ...
        'Assessment:\n%s'], ...
        comparison.ssim, comparison.histogram_correlation, ...
        comparison.identical_pixel_percentage, comparison.max_difference, ...
        comparison.mean_difference, get_comparison_assessment(comparison));
    
    text(0.05, 0.95, summary_text, 'Units', 'normalized', ...
         'FontSize', 10, 'VerticalAlignment', 'top', ...
         'FontFamily', 'FixedWidth');
end

function result = iff(condition, true_value, false_value)
    if condition
        result = true_value;
    else
        result = false_value;
    end
end