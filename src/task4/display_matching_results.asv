function display_matching_results(input_img, reference_img, output_img, show_analysis)
    % Input: input_img - original input image
    %        reference_img - reference image with target histogram
    %        output_img - result of histogram matching
    %        show_analysis - boolean to show detailed analysis (default: true)
    
    addpath('../task1');
    
    if nargin < 4
        show_analysis = true;
    end
    
    is_color = (size(input_img, 3) == 3);
    fig_main = figure('Name', 'Histogram Matching Results', ...
                     'Position', [50 50 1600 1000]);
    
    if is_color
        display_color_matching_results(input_img, reference_img, output_img);
    else
        display_grayscale_matching_results(input_img, reference_img, output_img);
    end
    
    if show_analysis
        analysis = analyze_histogram_matching(input_img, reference_img, output_img);
        display_detailed_matching_analysis(analysis, is_color);
    end
end

function display_grayscale_matching_results(input_img, reference_img, output_img)
    hist_input = calculate_histogram(input_img);
    hist_reference = calculate_histogram(reference_img);
    hist_output = calculate_histogram(output_img);
    
    cdf_input = cumsum(hist_input) / sum(hist_input);
    cdf_reference = cumsum(hist_reference) / sum(hist_reference);
    cdf_output = cumsum(hist_output) / sum(hist_output);
    
    subplot(3,4,1);
    imshow(input_img);
    title('1. Input Image', 'FontSize', 12, 'FontWeight', 'bold');
    add_image_info(input_img, 'bottom-left');
    
    subplot(3,4,2);
    bar(0:255, hist_input, 'FaceColor', [0.2 0.4 0.8], 'EdgeColor', 'none');
    title('2. Input Histogram', 'FontSize', 11, 'FontWeight', 'bold');
    xlabel('Intensity Value');
    ylabel('Frequency');
    xlim([0 255]);
    grid on;
    
    subplot(3,4,5);
    imshow(reference_img);
    title('3. Reference Image', 'FontSize', 12, 'FontWeight', 'bold');
    add_image_info(reference_img, 'bottom-left');
    
    subplot(3,4,6);
    bar(0:255, hist_reference, 'FaceColor', [0.8 0.4 0.2], 'EdgeColor', 'none');
    title('4. Reference Histogram (Target)', 'FontSize', 11, 'FontWeight', 'bold');
    xlabel('Intensity Value');
    ylabel('Frequency');
    xlim([0 255]);
    grid on;
    
    subplot(3,4,9);
    imshow(output_img);
    title('5. Matched Result', 'FontSize', 12, 'FontWeight', 'bold');
    add_image_info(output_img, 'bottom-left');
    
    subplot(3,4,10);
    bar(0:255, hist_output, 'FaceColor', [0.2 0.8 0.4], 'EdgeColor', 'none');
    title('6. Output Histogram', 'FontSize', 11, 'FontWeight', 'bold');
    xlabel('Intensity Value');
    ylabel('Frequency');
    xlim([0 255]);
    grid on;
    
    subplot(3,4,[3,4,7,8]);
    plot(0:255, cdf_input, 'b-', 'LineWidth', 2.5, 'DisplayName', 'Input CDF');
    hold on;
    plot(0:255, cdf_reference, 'r-', 'LineWidth', 2.5, 'DisplayName', 'Reference CDF (Target)');
    plot(0:255, cdf_output, 'g--', 'LineWidth', 2.5, 'DisplayName', 'Output CDF (Result)');
    hold off;
    
    title('CDF Comparison - YANG HARUS MIRIP!', 'FontSize', 13, 'FontWeight', 'bold', 'Color', 'red');
    xlabel('Intensity Value', 'FontSize', 11);
    ylabel('Cumulative Probability', 'FontSize', 11);
    legend('Location', 'southeast', 'FontSize', 10);
    grid on;
    xlim([0 255]);
    ylim([0 1]);
    
    cdf_similarity = 1 - mean(abs(cdf_output - cdf_reference));
    
    annotation('textbox', [0.52 0.55 0.42 0.15], ...
        'String', {
            'PENTING: Histogram Matching bekerja dengan CDF, bukan histogram langsung!', ...
            '', ...
            sprintf('CDF Similarity: %.3f (>0.9 = excellent)', cdf_similarity), ...
            '', ...
            'Jika CDF Output (hijau) mendekati CDF Reference (merah),', ...
            'maka histogram matching BERHASIL, meskipun histogram', ...
            'terlihat berbeda. Ini NORMAL dan BENAR!'
        }, ...
        'FontSize', 9, 'FontWeight', 'bold', ...
        'BackgroundColor', 'yellow', 'EdgeColor', 'red', 'LineWidth', 2);
    
    subplot(3,4,[11,12]);
    
    hist_ref_norm = hist_reference / max(hist_reference);
    hist_out_norm = hist_output / max(hist_output);
    
    plot(0:255, hist_ref_norm, 'r-', 'LineWidth', 2.5, 'DisplayName', 'Reference (Normalized)');
    hold on;
    plot(0:255, hist_out_norm, 'g--', 'LineWidth', 2.5, 'DisplayName', 'Output (Normalized)');
    hold off;
    
    title('Histogram Comparison (Normalized)', 'FontSize', 11, 'FontWeight', 'bold');
    xlabel('Intensity Value');
    ylabel('Normalized Frequency');
    legend('Location', 'best');
    grid on;
    xlim([0 255]);
    
    hist_similarity = calculate_correlation(hist_output, hist_reference);
    text(0.02, 0.95, sprintf('Histogram Similarity: %.3f', hist_similarity), ...
         'Units', 'normalized', 'FontSize', 10, 'FontWeight', 'bold', ...
         'BackgroundColor', 'white', 'EdgeColor', 'black');
     
    text(0.02, 0.85, 'Histogram bisa berbeda, yang penting CDF mirip!', ...
         'Units', 'normalized', 'FontSize', 8, 'FontWeight', 'bold', ...
         'BackgroundColor', 'yellow', 'EdgeColor', 'red');
end

function display_color_matching_results(input_img, reference_img, output_img)
    subplot(3,6,[1,2]);
    imshow(input_img);
    title('1. Input Image', 'FontSize', 11, 'FontWeight', 'bold');
    
    subplot(3,6,[3,4]);
    imshow(reference_img);
    title('3. Reference Image', 'FontSize', 11, 'FontWeight', 'bold');
    
    subplot(3,6,[5,6]);
    imshow(output_img);
    title('5. Matched Result', 'FontSize', 11, 'FontWeight', 'bold');
    
    colors = {'r', 'g', 'b'};
    channel_names = {'Red', 'Green', 'Blue'};
    
    for ch = 1:3
        subplot(3,6,6+ch);
        hist_ch = calculate_histogram(input_img(:,:,ch));
        bar(0:255, hist_ch, colors{ch}, 'EdgeColor', 'none');
        title(['2. Input ' channel_names{ch}], 'FontSize', 9);
        xlim([0 255]);
        if ch == 1, ylabel('Frequency', 'FontSize', 8); end
        grid on;
        
        subplot(3,6,9+ch);
        hist_ref_ch = calculate_histogram(reference_img(:,:,ch));
        bar(0:255, hist_ref_ch, colors{ch}, 'EdgeColor', 'none', 'FaceAlpha', 0.7);
        title(['4. Reference ' channel_names{ch}], 'FontSize', 9);
        xlim([0 255]);
        if ch == 1, ylabel('Frequency', 'FontSize', 8); end
        grid on;
        
        subplot(3,6,12+ch);
        hist_out_ch = calculate_histogram(output_img(:,:,ch));
        bar(0:255, hist_out_ch, colors{ch}, 'EdgeColor', 'none');
        title(['6. Output ' channel_names{ch}], 'FontSize', 9);
        xlabel('Intensity', 'FontSize', 8);
        if ch == 1, ylabel('Frequency', 'FontSize', 8); end
        xlim([0 255]);
        grid on;
        
        cdf_ref = cumsum(hist_ref_ch) / sum(hist_ref_ch);
        cdf_out = cumsum(hist_out_ch) / sum(hist_out_ch);
        cdf_similarity = 1 - mean(abs(cdf_out - cdf_ref));
        
        text(0.05, 0.85, sprintf('CDF: %.2f', cdf_similarity), ...
             'Units', 'normalized', 'FontSize', 8, 'FontWeight', 'bold', ...
             'BackgroundColor', 'white');
    end
    
    hist_input_gray = calculate_histogram(rgb2gray(input_img));
    hist_reference_gray = calculate_histogram(rgb2gray(reference_img));
    hist_output_gray = calculate_histogram(rgb2gray(output_img));
    
    cdf_ref_gray = cumsum(hist_reference_gray) / sum(hist_reference_gray);
    cdf_out_gray = cumsum(hist_output_gray) / sum(hist_output_gray);
    overall_cdf_similarity = 1 - mean(abs(cdf_out_gray - cdf_ref_gray));
    
    annotation('textbox', [0.02 0.02 0.3 0.12], ...
        'String', {
            sprintf('Overall CDF Similarity: %.3f', overall_cdf_similarity), ...
            '', ...
            'Histogram matching bekerja di domain CDF.', ...
            'Jika CDF mirip, matching BERHASIL!'
        }, ...
        'FontSize', 10, 'FontWeight', 'bold', ...
        'BackgroundColor', 'yellow', 'EdgeColor', 'red', 'LineWidth', 2);
end

function add_image_info(img, position)
    min_val = min(img(:));
    max_val = max(img(:));
    mean_val = mean(double(img(:)));
    std_val = std(double(img(:)));
    
    info_text = sprintf('Range: [%d,%d]\nMean: %.1f, Std: %.1f', ...
                       min_val, max_val, mean_val, std_val);
    
    switch lower(position)
        case 'bottom-left'
            text_pos = [0.02 0.02];
        case 'top-left'
            text_pos = [0.02 0.85];
        case 'bottom-right'
            text_pos = [0.65 0.02];
        otherwise
            text_pos = [0.02 0.02];
    end
    
    text(text_pos(1), text_pos(2), info_text, ...
         'Units', 'normalized', 'FontSize', 8, ...
         'BackgroundColor', 'white', 'EdgeColor', 'black');
end

function display_detailed_matching_analysis(analysis, is_color)
    fig_analysis = figure('Name', 'Histogram Matching Analysis', ...
                         'Position', [100 100 1000 700]);
    
    analysis_text = create_matching_analysis_text(analysis, is_color);
    subplot(2,2,[1,2]);
    text(0.05, 0.95, analysis_text, 'Units', 'normalized', ...
         'FontSize', 10, 'VerticalAlignment', 'top', 'FontName', 'FixedWidth');
    axis off;
    title('Detailed Histogram Matching Analysis', 'FontSize', 14, 'FontWeight', 'bold');
    
    subplot(2,2,3);
    create_quality_metrics_chart(analysis, is_color);
    
    subplot(2,2,4);
    create_improvement_comparison_chart(analysis, is_color);
end

function text_str = create_matching_analysis_text(analysis, is_color)
    text_str = sprintf('HISTOGRAM MATCHING ANALYSIS\n\n');
    text_str = [text_str sprintf('Image Type: %s\n\n', ...
        iff(is_color, 'Color (RGB)', 'Grayscale'))];
    
    text_str = [text_str sprintf('SIMILARITY METRICS:\n')];
    text_str = [text_str sprintf('  Histogram Similarity: %.3f\n', analysis.histogram_similarity)];
    text_str = [text_str sprintf('  Matching Success: %s\n\n', ...
        iff(analysis.matching_success, 'YES', 'NO'))];
    
    if ~is_color
        text_str = [text_str sprintf('STATISTICAL ANALYSIS:\n')];
        text_str = [text_str sprintf('  Mean Matching: %s\n', ...
            iff(analysis.moments.mean_improvement, 'Improved', 'Not Improved'))];
        text_str = [text_str sprintf('  Std Dev Matching: %s\n', ...
            iff(analysis.moments.std_improvement, 'Improved', 'Not Improved'))];
        text_str = [text_str sprintf('  KL Divergence: %.3f\n', analysis.kl_divergence)];
        text_str = [text_str sprintf('  Earth Mover Distance: %.3f\n', analysis.earth_movers_distance)];
        text_str = [text_str sprintf('  Contrast Preservation: %.3f\n\n', analysis.contrast_preservation)];
    else
        text_str = [text_str sprintf('COLOR HARMONY:\n')];
        text_str = [text_str sprintf('  Hue Similarity: %.3f\n', analysis.color_harmony.hue_similarity)];
        text_str = [text_str sprintf('  Saturation Similarity: %.3f\n', analysis.color_harmony.saturation_similarity)];
        text_str = [text_str sprintf('  Value Similarity: %.3f\n', analysis.color_harmony.value_similarity)];
        text_str = [text_str sprintf('  Overall Color Score: %.3f\n\n', analysis.color_harmony.overall_score)];
    end
    
    text_str = [text_str sprintf('OVERALL ASSESSMENT:\n')];
    text_str = [text_str sprintf('  %s\n', analysis.overall_quality)];
end

function create_quality_metrics_chart(analysis, is_color)
    if is_color
        metrics_names = {'Histogram', 'Hue', 'Saturation', 'Value'};
        metrics_values = [analysis.histogram_similarity, ...
                         analysis.color_harmony.hue_similarity, ...
                         analysis.color_harmony.saturation_similarity, ...
                         analysis.color_harmony.value_similarity];
        colors_map = [0.3 0.6 0.9; 0.9 0.3 0.3; 0.3 0.9 0.3; 0.9 0.9 0.3];
    else
        metrics_names = {'Similarity', 'Contrast', 'Mean Match', 'Std Match'};
        metrics_values = [analysis.histogram_similarity, ...
                         analysis.contrast_preservation, ...
                         double(analysis.moments.mean_improvement), ...
                         double(analysis.moments.std_improvement)];
        colors_map = [0.3 0.6 0.9; 0.6 0.3 0.9; 0.9 0.6 0.3; 0.3 0.9 0.6];
    end
    
    bar_handle = bar(metrics_values, 'FaceColor', 'flat');
    bar_handle.CData = colors_map;
    
    set(gca, 'XTickLabel', metrics_names);
    title('Quality Metrics');
    ylabel('Score');
    ylim([0 1]);
    grid on;
    
    hold on;
    plot([0.5 length(metrics_names)+0.5], [0.7 0.7], 'r--', 'LineWidth', 2);
    text(length(metrics_names)/2, 0.75, 'Good Threshold', 'HorizontalAlignment', 'center');
    hold off;
end

function create_improvement_comparison_chart(analysis, is_color)
    if is_color
        categories = {'Input', 'Reference', 'Output'};
        entropy_values = [analysis.input_entropy, analysis.reference_entropy, analysis.output_entropy];
        
        bar(entropy_values, 'FaceColor', [0.4 0.7 0.5]);
        set(gca, 'XTickLabel', categories);
        title('Entropy Comparison');
        ylabel('Entropy (bits)');
        grid on;
        
    else
        categories = {'Mean', 'Std Dev'};
        input_vals = [analysis.moments.input_mean/255, analysis.moments.input_std/255];
        reference_vals = [analysis.moments.reference_mean/255, analysis.moments.reference_std/255];
        output_vals = [analysis.moments.output_mean/255, analysis.moments.output_std/255];
        
        x = 1:length(categories);
        width = 0.25;
        
        bar(x - width, input_vals, width, 'FaceColor', [0.2 0.4 0.8], 'DisplayName', 'Input');
        hold on;
        bar(x, reference_vals, width, 'FaceColor', [0.8 0.4 0.2], 'DisplayName', 'Reference');
        bar(x + width, output_vals, width, 'FaceColor', [0.2 0.8 0.4], 'DisplayName', 'Output');
        hold off;
        
        set(gca, 'XTickLabel', categories);
        title('Statistical Moments Comparison');
        ylabel('Normalized Value');
        legend();
        grid on;
    end
end

function correlation = calculate_correlation(x, y)
    x = x(:);
    y = y(:);
    
    mean_x = mean(x);
    mean_y = mean(y);
    
    numerator = sum((x - mean_x) .* (y - mean_y));
    denominator = sqrt(sum((x - mean_x).^2) * sum((y - mean_y).^2));
    
    if denominator == 0
        correlation = 0;
    else
        correlation = numerator / denominator;
    end
end

function result = iff(condition, true_value, false_value)
    if condition
        result = true_value;
    else
        result = false_value;
    end
end


