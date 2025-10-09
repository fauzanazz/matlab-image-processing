function analysis = analyze_histogram_matching(input_img, reference_img, output_img)
    % Input: input_img - original input image
    %        reference_img - reference image with target histogram
    %        output_img - result of histogram matching
    % Output: analysis - struct with detailed analysis metrics
    
    addpath('../task1');
    
    analysis = struct();
    is_color = (size(input_img, 3) == 3);
    
    if is_color
        analysis = analyze_color_matching(input_img, reference_img, output_img);
    else
        analysis = analyze_grayscale_matching(input_img, reference_img, output_img);
    end
    
    analysis.image_type = is_color;
    analysis.matching_success = analysis.histogram_similarity > 0.6;
    analysis.overall_quality = assess_matching_quality(analysis);
    print_analysis_summary(analysis);
end

function analysis = analyze_grayscale_matching(input_img, reference_img, output_img)
    hist_input = calculate_histogram(input_img);
    hist_reference = calculate_histogram(reference_img);
    hist_output = calculate_histogram(output_img);
    
    analysis.hist_input = hist_input;
    analysis.hist_reference = hist_reference;
    analysis.hist_output = hist_output;

    analysis.histogram_similarity = calculate_correlation(hist_output, hist_reference);
    analysis.input_ref_similarity = calculate_correlation(hist_input, hist_reference);
    
    analysis.moments = calculate_statistical_moments(input_img, reference_img, output_img);
    
    analysis.input_entropy = calculate_entropy(hist_input);
    analysis.reference_entropy = calculate_entropy(hist_reference);
    analysis.output_entropy = calculate_entropy(hist_output);
    
    analysis.input_range = [double(min(input_img(:))), double(max(input_img(:)))];
    analysis.reference_range = [double(min(reference_img(:))), double(max(reference_img(:)))];
    analysis.output_range = [double(min(output_img(:))), double(max(output_img(:)))];
    
    analysis.kl_divergence = calculate_kl_divergence(hist_output, hist_reference);
    analysis.earth_movers_distance = calculate_emd_approximation(hist_output, hist_reference);
    
    analysis.improvement_factor = analysis.histogram_similarity / max(analysis.input_ref_similarity, 0.01);
    analysis.contrast_preservation = calculate_contrast_preservation(input_img, output_img);
end

function analysis = analyze_color_matching(input_img, reference_img, output_img)
    analysis.histogram_similarity = 0;
    analysis.input_entropy = 0;
    analysis.reference_entropy = 0;
    analysis.output_entropy = 0;
    
    channel_names = {'red', 'green', 'blue'};
    
    for ch = 1:3
        input_ch = input_img(:,:,ch);
        reference_ch = reference_img(:,:,ch);
        output_ch = output_img(:,:,ch);
        
        ch_analysis = analyze_grayscale_matching(input_ch, reference_ch, output_ch);
        analysis.channels.(channel_names{ch}) = ch_analysis;
        
        analysis.histogram_similarity = analysis.histogram_similarity + ch_analysis.histogram_similarity;
        analysis.input_entropy = analysis.input_entropy + ch_analysis.input_entropy;
        analysis.reference_entropy = analysis.reference_entropy + ch_analysis.reference_entropy;
        analysis.output_entropy = analysis.output_entropy + ch_analysis.output_entropy;
    end
    
    analysis.histogram_similarity = analysis.histogram_similarity / 3;
    analysis.input_entropy = analysis.input_entropy / 3;
    analysis.reference_entropy = analysis.reference_entropy / 3;
    analysis.output_entropy = analysis.output_entropy / 3;
    analysis.color_harmony = analyze_color_harmony(input_img, reference_img, output_img);
end

function moments = calculate_statistical_moments(input_img, reference_img, output_img)
    input_data = double(input_img(:));
    reference_data = double(reference_img(:));
    output_data = double(output_img(:));
    
    moments.input_mean = mean(input_data);
    moments.reference_mean = mean(reference_data);
    moments.output_mean = mean(output_data);
    moments.mean_improvement = abs(moments.output_mean - moments.reference_mean) < ...
                              abs(moments.input_mean - moments.reference_mean);
    
    moments.input_std = std(input_data);
    moments.reference_std = std(reference_data);
    moments.output_std = std(output_data);
    moments.std_improvement = abs(moments.output_std - moments.reference_std) < ...
                             abs(moments.input_std - moments.reference_std);
    
    moments.input_skewness = calculate_skewness(input_data);
    moments.reference_skewness = calculate_skewness(reference_data);
    moments.output_skewness = calculate_skewness(output_data);
    
    moments.input_kurtosis = calculate_kurtosis(input_data);
    moments.reference_kurtosis = calculate_kurtosis(reference_data);
    moments.output_kurtosis = calculate_kurtosis(output_data);
end

function skewness = calculate_skewness(data)
    mean_val = mean(data);
    std_val = std(data);
    
    if std_val == 0
        skewness = 0;
    else
        skewness = mean(((data - mean_val) / std_val).^3);
    end
end

function kurtosis = calculate_kurtosis(data)
    mean_val = mean(data);
    std_val = std(data);
    
    if std_val == 0
        kurtosis = 0;
    else
        kurtosis = mean(((data - mean_val) / std_val).^4) - 3; 
    end
end

function kl_div = calculate_kl_divergence(hist_p, hist_q)
    p = hist_p / sum(hist_p);
    q = hist_q / sum(hist_q);
    
    epsilon = 1e-10;
    p = p + epsilon;
    q = q + epsilon;
    
    p = p / sum(p);
    q = q / sum(q);
    
    kl_div = sum(p .* log(p ./ q));
end

function emd = calculate_emd_approximation(hist1, hist2)
    hist1 = hist1 / sum(hist1);
    hist2 = hist2 / sum(hist2);
    
    cdf1 = cumsum(hist1);
    cdf2 = cumsum(hist2);
    
    emd = sum(abs(cdf1 - cdf2));
end

function contrast_preservation = calculate_contrast_preservation(input_img, output_img)
    input_std = std(double(input_img(:)));
    output_std = std(double(output_img(:)));
    
    if input_std == 0
        contrast_preservation = 1;
    else
        contrast_preservation = min(output_std / input_std, input_std / output_std);
    end
end

function harmony = analyze_color_harmony(input_img, reference_img, output_img)
    input_hsv = rgb2hsv(double(input_img)/255);
    reference_hsv = rgb2hsv(double(reference_img)/255);
    output_hsv = rgb2hsv(double(output_img)/255);
    
    harmony.hue_similarity = calculate_correlation(output_hsv(:,:,1), reference_hsv(:,:,1));
    harmony.saturation_similarity = calculate_correlation(output_hsv(:,:,2), reference_hsv(:,:,2));
    harmony.value_similarity = calculate_correlation(output_hsv(:,:,3), reference_hsv(:,:,3));
    
    harmony.overall_score = mean([harmony.hue_similarity, ...
                                 harmony.saturation_similarity, ...
                                 harmony.value_similarity]);
end

function quality = assess_matching_quality(analysis)
    similarity = analysis.histogram_similarity;
    
    if similarity > 0.85
        quality = 'Excellent - Very high histogram similarity achieved';
    elseif similarity > 0.70
        quality = 'Good - High histogram similarity with minor differences';
    elseif similarity > 0.50
        quality = 'Moderate - Noticeable improvement but some differences remain';
    elseif similarity > 0.30
        quality = 'Poor - Limited similarity to reference histogram';
    else
        quality = 'Very Poor - Minimal improvement achieved';
    end
end

function print_analysis_summary(analysis)
    fprintf('\n=== HISTOGRAM MATCHING ANALYSIS ===\n');
    fprintf('Image Type: %s\n', iff(analysis.image_type, 'Color (RGB)', 'Grayscale'));
    fprintf('Histogram Similarity: %.3f\n', analysis.histogram_similarity);
    
    if ~analysis.image_type 
        fprintf('Statistical Moments:\n');
        fprintf('  Mean Match: %s (%.1f vs %.1f target)\n', ...
            iff(analysis.moments.mean_improvement, 'Improved', 'Not Improved'), ...
            analysis.moments.output_mean, analysis.moments.reference_mean);
        fprintf('  Std Match: %s (%.1f vs %.1f target)\n', ...
            iff(analysis.moments.std_improvement, 'Improved', 'Not Improved'), ...
            analysis.moments.output_std, analysis.moments.reference_std);
        
        fprintf('Distribution Metrics:\n');
        fprintf('  KL Divergence: %.3f (lower is better)\n', analysis.kl_divergence);
        fprintf('  Earth Mover Distance: %.3f (lower is better)\n', analysis.earth_movers_distance);
        fprintf('  Contrast Preservation: %.3f (closer to 1 is better)\n', analysis.contrast_preservation);
    else
        fprintf('Color Harmony Analysis:\n');
        fprintf('  Hue Similarity: %.3f\n', analysis.color_harmony.hue_similarity);
        fprintf('  Saturation Similarity: %.3f\n', analysis.color_harmony.saturation_similarity);
        fprintf('  Value Similarity: %.3f\n', analysis.color_harmony.value_similarity);
        fprintf('  Overall Color Score: %.3f\n', analysis.color_harmony.overall_score);
    end
    
    fprintf('\nOverall Assessment: %s\n', analysis.overall_quality);
    fprintf('Matching Success: %s\n', iff(analysis.matching_success, 'YES', 'NO'));
end

function result = iff(condition, true_value, false_value)
    if condition
        result = true_value;
    else
        result = false_value;
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