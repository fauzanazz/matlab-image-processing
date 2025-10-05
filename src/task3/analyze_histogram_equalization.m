function analysis = analyze_histogram_equalization(input_img, output_img)
    % Input: input_img - original image
    %        output_img - equalized image
    % Output: analysis - struct with detailed analysis
    
    addpath('../task1');
    
    analysis = struct();
    is_color = (size(input_img, 3) == 3);
    
    if is_color
        analysis = analyze_color_equalization(input_img, output_img);
    else
        analysis = analyze_grayscale_equalization(input_img, output_img);
    end
    
    analysis.image_type = is_color;
    analysis.improvement_achieved = analysis.output_entropy > analysis.input_entropy;
    analysis.entropy_improvement = analysis.output_entropy - analysis.input_entropy;
    analysis.contrast_improvement = (analysis.output_range / analysis.input_range) - 1;
    
    fprintf('\n=== HISTOGRAM EQUALIZATION ANALYSIS ===\n');
    fprintf('Image Type: %s\n', iff(is_color, 'Color (RGB)', 'Grayscale'));
    fprintf('Entropy Improvement: %.3f (%.1f%% increase)\n', ...
        analysis.entropy_improvement, (analysis.entropy_improvement/analysis.input_entropy)*100);
    fprintf('Contrast Improvement: %.1f%% increase in dynamic range\n', ...
        analysis.contrast_improvement * 100);
    fprintf('Overall Assessment: %s\n', get_quality_assessment(analysis));
end

function analysis = analyze_grayscale_equalization(input_img, output_img)
    hist_input = calculate_histogram(input_img);
    hist_output = calculate_histogram(output_img);
    
    analysis.input_min = double(min(input_img(:)));
    analysis.input_max = double(max(input_img(:)));
    analysis.output_min = double(min(output_img(:)));
    analysis.output_max = double(max(output_img(:)));
    analysis.input_range = analysis.input_max - analysis.input_min + 1;
    analysis.output_range = analysis.output_max - analysis.output_min + 1;
    analysis.input_entropy = calculate_entropy(hist_input);
    analysis.output_entropy = calculate_entropy(hist_output);
    analysis.histogram_uniformity = calculate_uniformity(hist_output);
    analysis.input_std = std(double(input_img(:)));
    analysis.output_std = std(double(output_img(:)));
    analysis.hist_input = hist_input;
    analysis.hist_output = hist_output;
end

function analysis = analyze_color_equalization(input_img, output_img)
    analysis.input_entropy = 0;
    analysis.output_entropy = 0;
    analysis.input_range = 0;
    analysis.output_range = 0;
    
    channel_names = {'red', 'green', 'blue'};
    
    for ch = 1:3
        input_ch = input_img(:,:,ch);
        output_ch = output_img(:,:,ch);
        
        ch_analysis = analyze_grayscale_equalization(input_ch, output_ch);
        
        analysis.channels.(channel_names{ch}) = ch_analysis;
        analysis.input_entropy = analysis.input_entropy + ch_analysis.input_entropy;
        analysis.output_entropy = analysis.output_entropy + ch_analysis.output_entropy;
        analysis.input_range = analysis.input_range + ch_analysis.input_range;
        analysis.output_range = analysis.output_range + ch_analysis.output_range;
    end
    
    analysis.input_entropy = analysis.input_entropy / 3;
    analysis.output_entropy = analysis.output_entropy / 3;
    analysis.input_range = analysis.input_range / 3;
    analysis.output_range = analysis.output_range / 3;
end

function uniformity = calculate_uniformity(histogram)
    mean_freq = mean(histogram);
    std_freq = std(histogram);
    
    if mean_freq == 0
        uniformity = 0;
    else
        cv = std_freq / mean_freq; 
        uniformity = 1 / (1 + cv); 
    end
end

function assessment = get_quality_assessment(analysis)
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

function result = iff(condition, true_value, false_value)
    if condition
        result = true_value;
    else
        result = false_value;
    end
end