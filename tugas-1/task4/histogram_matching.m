function output_img = histogram_matching(input_img, reference_img)
    % Input: input_img - image to be enhanced
    %        reference_img - reference image with desired histogram
    % Output: output_img - matched image with histogram similar to reference
    
    addpath('../task1');
    
    if isempty(input_img) || isempty(reference_img)
        error('Input images cannot be empty');
    end
    
    if ~isequal(size(input_img), size(reference_img))
        error('Input and reference images must have the same dimensions');
    end
    
    if size(input_img, 3) == 3 && size(reference_img, 3) == 3
        output_img = zeros(size(input_img), 'uint8');
        fprintf('Histogram Matching Applied (Color Image):\n');
        channel_names = {'Red', 'Green', 'Blue'};
        
        for ch = 1:3
            [output_img(:,:,ch), stats] = match_single_channel(...
                input_img(:,:,ch), reference_img(:,:,ch));
            fprintf('  %s Channel: Similarity %.3f\n', ...
                channel_names{ch}, stats.similarity);
        end
    elseif size(input_img, 3) == 1 && size(reference_img, 3) == 1
        fprintf('Histogram Matching Applied (Grayscale):\n');
        [output_img, stats] = match_single_channel(input_img, reference_img);
        fprintf('  Histogram Similarity: %.3f\n', stats.similarity);
        fprintf('  Mapping Quality: %.3f\n', stats.mapping_quality);
    else
        if size(input_img, 3) == 3
            input_img = rgb2gray(input_img);
        end
        if size(reference_img, 3) == 3
            reference_img = rgb2gray(reference_img);
        end
        
        fprintf('Histogram Matching Applied (Converted to Grayscale):\n');
        [output_img, stats] = match_single_channel(input_img, reference_img);
        fprintf('  Histogram Similarity: %.3f\n', stats.similarity);
    end
    
    fprintf('  Algorithm: Custom histogram matching (no built-in functions)\n');
end

function [output_channel, stats] = match_single_channel(input_channel, reference_channel)
    [rows, cols] = size(input_channel);

    hist_input = calculate_histogram(input_channel);
    hist_reference = calculate_histogram(reference_channel);
    cdf_input = calculate_cdf(hist_input);
    cdf_reference = calculate_cdf(hist_reference);
    mapping_func = create_mapping_function(cdf_input, cdf_reference);
    output_channel = apply_mapping(input_channel, mapping_func);
    stats = calculate_matching_stats(input_channel, reference_channel, ...
                                   output_channel, mapping_func);
end

function cdf = calculate_cdf(histogram)
    total_pixels = sum(histogram);
    if total_pixels == 0
        cdf = zeros(1, 256);
        return;
    end
    
    cdf = zeros(1, 256);
    cdf(1) = histogram(1);
    for i = 2:256
        cdf(i) = cdf(i-1) + histogram(i);
    end
    
    cdf = cdf / total_pixels;
end

function mapping_func = create_mapping_function(cdf_input, cdf_reference)
    mapping_func = zeros(1, 256);
    
    for input_intensity = 1:256
        input_cdf_value = cdf_input(input_intensity);
        [~, closest_idx] = min(abs(cdf_reference - input_cdf_value));
        mapping_func(input_intensity) = closest_idx - 1;
    end
    
    mapping_func = max(0, min(255, mapping_func));
end

function output_img = apply_mapping(input_img, mapping_func)
    [rows, cols] = size(input_img);
    output_img = zeros(rows, cols, 'uint8');
    
    for i = 1:rows
        for j = 1:cols
            old_intensity = double(input_img(i, j)) + 1;
            new_intensity = mapping_func(old_intensity);
            output_img(i, j) = uint8(new_intensity);
        end
    end
end

function stats = calculate_matching_stats(input_img, reference_img, output_img, mapping_func)
    hist_input = calculate_histogram(input_img);
    hist_reference = calculate_histogram(reference_img);
    hist_output = calculate_histogram(output_img);
    stats.similarity = calculate_correlation(hist_output, hist_reference);
    
    unique_mappings = length(unique(mapping_func));
    stats.mapping_quality = unique_mappings / 256;
    
    stats.input_mean = mean(double(input_img(:)));
    stats.reference_mean = mean(double(reference_img(:)));
    stats.output_mean = mean(double(output_img(:)));
    
    stats.input_std = std(double(input_img(:)));
    stats.reference_std = std(double(reference_img(:)));
    stats.output_std = std(double(output_img(:)));
    
    stats.input_range = [double(min(input_img(:))), double(max(input_img(:)))];
    stats.reference_range = [double(min(reference_img(:))), double(max(reference_img(:)))];
    stats.output_range = [double(min(output_img(:))), double(max(output_img(:)))];
    stats.input_entropy = calculate_entropy(hist_input);
    stats.reference_entropy = calculate_entropy(hist_reference);
    stats.output_entropy = calculate_entropy(hist_output);
    mean_diff = abs(stats.output_mean - stats.reference_mean);
    std_diff = abs(stats.output_std - stats.reference_std);
    
    if stats.similarity > 0.8 && mean_diff < 20 && std_diff < 20
        stats.quality = 'Excellent';
    elseif stats.similarity > 0.6 && mean_diff < 40 && std_diff < 40
        stats.quality = 'Good';
    elseif stats.similarity > 0.4
        stats.quality = 'Moderate';
    else
        stats.quality = 'Poor';
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

