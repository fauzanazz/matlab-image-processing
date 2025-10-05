function display_equalization_results(input_img, output_img, show_analysis)
    % Input: input_img - original image
    %        output_img - equalized image  
    %        show_analysis - boolean to show detailed analysis (default: true)
    
    addpath('../task1');
    
    if nargin < 3
        show_analysis = true;
    end
    
    is_color = (size(input_img, 3) == 3);
    fig_main = figure('Name', 'Histogram Equalization Results', ...
                     'Position', [50 50 1400 900]);
    
    if is_color
        display_color_equalization_results(input_img, output_img);
    else
        display_grayscale_equalization_results(input_img, output_img);
    end
    
    if show_analysis
        analysis = analyze_histogram_equalization(input_img, output_img);
        display_detailed_analysis(analysis, is_color);
    end
end

function display_grayscale_equalization_results(input_img, output_img)
    hist_input = calculate_histogram(input_img);
    hist_output = calculate_histogram(output_img);
    
    cdf_input = cumsum(hist_input) / sum(hist_input);
    cdf_output = cumsum(hist_output) / sum(hist_output);
    
    subplot(2,3,1);
    imshow(input_img);
    title('Original Image', 'FontSize', 12, 'FontWeight', 'bold');
    add_image_stats_text(input_img, 'bottom');
    
    subplot(2,3,4);
    imshow(output_img);
    title('Equalized Image', 'FontSize', 12, 'FontWeight', 'bold');
    add_image_stats_text(output_img, 'bottom');
    
    subplot(2,3,2);
    bar(0:255, hist_input, 'FaceColor', [0.2 0.4 0.8], 'EdgeColor', 'none');
    title('Original Histogram', 'FontSize', 11, 'FontWeight', 'bold');
    xlabel('Intensity Value');
    ylabel('Frequency');
    xlim([0 255]);
    grid on;
    
    subplot(2,3,5);
    bar(0:255, hist_output, 'FaceColor', [0.8 0.2 0.2], 'EdgeColor', 'none');
    title('Equalized Histogram', 'FontSize', 11, 'FontWeight', 'bold');
    xlabel('Intensity Value');
    ylabel('Frequency');
    xlim([0 255]);
    grid on;
    
    subplot(2,3,[3,6]);
    plot(0:255, cdf_input, 'b-', 'LineWidth', 2, 'DisplayName', 'Original CDF');
    hold on;
    plot(0:255, cdf_output, 'r-', 'LineWidth', 2, 'DisplayName', 'Equalized CDF');
    plot([0 255], [0 1], 'k--', 'LineWidth', 1, 'DisplayName', 'Ideal Linear CDF');
    hold off;
    
    title('Cumulative Distribution Functions', 'FontSize', 11, 'FontWeight', 'bold');
    xlabel('Intensity Value');
    ylabel('Cumulative Probability');
    legend('Location', 'southeast');
    grid on;
    xlim([0 255]);
    ylim([0 1]);
end

function display_color_equalization_results(input_img, output_img)
    subplot(2,5,1);
    imshow(input_img);
    title('Original Image', 'FontSize', 10, 'FontWeight', 'bold');
    
    subplot(2,5,6);
    imshow(output_img);
    title('Equalized Image', 'FontSize', 10, 'FontWeight', 'bold');
    
    colors = {'r', 'g', 'b'};
    channel_names = {'Red', 'Green', 'Blue'};
    
    for ch = 1:3
        subplot(2,5,ch+1);
        hist_ch = calculate_histogram(input_img(:,:,ch));
        bar(0:255, hist_ch, colors{ch}, 'EdgeColor', 'none');
        title(['Original ' channel_names{ch}], 'FontSize', 9);
        xlim([0 255]);
        if ch == 1, ylabel('Frequency'); end
        grid on;
        
        subplot(2,5,ch+6);
        hist_eq_ch = calculate_histogram(output_img(:,:,ch));
        bar(0:255, hist_eq_ch, colors{ch}, 'EdgeColor', 'none');
        title(['Equalized ' channel_names{ch}], 'FontSize', 9);
        xlim([0 255]);
        if ch == 1, ylabel('Frequency'); end
        xlabel('Intensity');
        grid on;
    end
    
    subplot(2,5,5);
    hist_orig_gray = calculate_histogram(rgb2gray(input_img));
    bar(0:255, hist_orig_gray, 'FaceColor', [0.5 0.5 0.5], 'EdgeColor', 'none');
    title('Original (Grayscale)', 'FontSize', 9);
    xlim([0 255]);
    grid on;
    
    subplot(2,5,10);
    hist_eq_gray = calculate_histogram(rgb2gray(output_img));
    bar(0:255, hist_eq_gray, 'FaceColor', [0.3 0.3 0.3], 'EdgeColor', 'none');
    title('Equalized (Grayscale)', 'FontSize', 9);
    xlabel('Intensity');
    xlim([0 255]);
    grid on;
end

function add_image_stats_text(img, position)
    min_val = min(img(:));
    max_val = max(img(:));
    mean_val = mean(double(img(:)));
    std_val = std(double(img(:)));
    
    stats_text = sprintf('Min: %d, Max: %d\nMean: %.1f, Std: %.1f', ...
                        min_val, max_val, mean_val, std_val);
    
    if strcmp(position, 'bottom')
        text_pos = [0.02 0.02];
    else
        text_pos = [0.02 0.85];
    end
    
    text(text_pos(1), text_pos(2), stats_text, ...
         'Units', 'normalized', 'FontSize', 8, ...
         'BackgroundColor', 'white', 'EdgeColor', 'black');
end

function display_detailed_analysis(analysis, is_color)
    fig_analysis = figure('Name', 'Equalization Analysis', ...
                         'Position', [100 100 800 600]);
    
    analysis_text = create_analysis_text(analysis, is_color);
    
    subplot(2,1,1);
    text(0.05, 0.95, analysis_text, 'Units', 'normalized', ...
     'FontSize', 10, 'VerticalAlignment', 'top');
    axis off;
    title('Histogram Equalization Analysis', 'FontSize', 14, 'FontWeight', 'bold');
    
    subplot(2,1,2);
    create_improvement_chart(analysis, is_color);
end

function text_str = create_analysis_text(analysis, is_color)
    text_str = sprintf('IMAGE TYPE: %s\n\n', ...
        iff(is_color, 'Color (RGB)', 'Grayscale'));
    
    text_str = [text_str sprintf('ENTROPY ANALYSIS:\n')];
    text_str = [text_str sprintf('  Original Entropy: %.3f bits\n', analysis.input_entropy)];
    text_str = [text_str sprintf('  Equalized Entropy: %.3f bits\n', analysis.output_entropy)];
    text_str = [text_str sprintf('  Improvement: %.3f bits (%.1f%% increase)\n\n', ...
        analysis.entropy_improvement, (analysis.entropy_improvement/analysis.input_entropy)*100)];
    
    text_str = [text_str sprintf('DYNAMIC RANGE:\n')];
    text_str = [text_str sprintf('  Original Range: %.1f levels\n', analysis.input_range)];
    text_str = [text_str sprintf('  Equalized Range: %.1f levels\n', analysis.output_range)];
    text_str = [text_str sprintf('  Improvement: %.1f%% increase\n\n', ...
        analysis.contrast_improvement * 100)];
    
    text_str = [text_str sprintf('QUALITY ASSESSMENT:\n')];
    text_str = [text_str sprintf('  %s\n\n', get_quality_assessment_local(analysis))];
    
    if is_color
        text_str = [text_str sprintf('CHANNEL-SPECIFIC RESULTS:\n')];
        channels = {'red', 'green', 'blue'};
        for i = 1:3
            ch_data = analysis.channels.(channels{i});
            text_str = [text_str sprintf('  %s: Entropy %.3f -> %.3f\n', ...
                upper(channels{i}), ch_data.input_entropy, ch_data.output_entropy)];
        end
    end
end

function assessment = get_quality_assessment_local(analysis)
    entropy_gain = analysis.entropy_improvement;
    contrast_gain = analysis.contrast_improvement;
    
    if entropy_gain > 1.0 && contrast_gain > 0.5
        assessment = 'Excellent - Significant improvement in both entropy and contrast';
    elseif entropy_gain > 0.5 && contrast_gain > 0.2
        assessment = 'Good - Noticeable improvement achieved';
    elseif entropy_gain > 0.1 || contrast_gain > 0.1
        assessment = 'Moderate - Some improvement achieved';
    elseif entropy_gain > -0.1 && contrast_gain > -0.1
        assessment = 'Minimal - Little change (image may already be well-balanced)';
    else
        assessment = 'Poor - Limited or negative improvement (not suitable for this image)';
    end
end

function create_improvement_chart(analysis, is_color)
    if is_color
        channels = {'Red', 'Green', 'Blue'};
        entropy_gains = zeros(1, 3);
        
        channel_fields = {'red', 'green', 'blue'};
        for i = 1:3
            ch_data = analysis.channels.(channel_fields{i});
            entropy_gains(i) = ch_data.output_entropy - ch_data.input_entropy;
        end
        
        bar(entropy_gains, 'FaceColor', [0.3 0.6 0.9]);
        set(gca, 'XTickLabel', channels);
        title('Entropy Improvement by Channel');
        ylabel('Entropy Gain (bits)');
    else
        metrics = {'Entropy', 'Contrast'};
        improvements = [analysis.entropy_improvement, analysis.contrast_improvement * 10];
        
        bar(improvements, 'FaceColor', [0.6 0.3 0.9]);
        set(gca, 'XTickLabel', metrics);
        title('Overall Improvements');
        ylabel('Improvement Value');
        
        text(0.5, max(improvements)*0.8, 'Note: Contrast scaled by 10x for visibility', ...
             'HorizontalAlignment', 'center', 'FontSize', 8);
    end
    
    grid on;
end

function result = iff(condition, true_value, false_value)
    if condition
        result = true_value;
    else
        result = false_value;
    end
end