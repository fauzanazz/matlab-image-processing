function output_img = histogram_equalization(img)
    % Histogram equalization without using built-in functions
    % Input: img - input image (grayscale or color)
    % Output: output_img - equalized image
    
    addpath('../task1');
    
    if isempty(img)
        error('Input image cannot be empty');
    end
    
    if size(img, 3) == 3
        output_img = zeros(size(img), 'uint8');
        
        fprintf('Histogram Equalization Applied (Color Image):\n');
        channel_names = {'Red', 'Green', 'Blue'};
        
        for ch = 1:3
            [output_img(:,:,ch), stats] = equalize_single_channel(img(:,:,ch));
            fprintf('  %s Channel: Entropy %.3f -> %.3f\n', ...
                channel_names{ch}, stats.input_entropy, stats.output_entropy);
        end
    else
        fprintf('Histogram Equalization Applied (Grayscale):\n');
        [output_img, stats] = equalize_single_channel(img);
        fprintf('  Entropy: %.3f -> %.3f\n', stats.input_entropy, stats.output_entropy);
        fprintf('  Dynamic Range: [%d,%d] -> [%d,%d]\n', ...
            stats.input_min, stats.input_max, stats.output_min, stats.output_max);
    end
    
    fprintf('  Algorithm: Custom histogram equalization (no built-in functions)\n');
end

function [output_channel, stats] = equalize_single_channel(img_channel)
    img_channel = uint8(img_channel);
    [rows, cols] = size(img_channel);
    total_pixels = double(rows*cols);

    hist_values = calculate_histogram(img_channel);
    pdf = hist_values / total_pixels;

    cdf = cumsum(pdf);

    nz = find(hist_values>0, 1, 'first');
    cdf_min = 0; 
    if ~isempty(nz)
        cdf_min = cdf(nz);
    end

    T = (cdf - cdf_min) ./ max(1e-12, (1 - cdf_min));
    T = uint8(round(255 * max(0, min(1, T))));

    output_channel = T(double(img_channel)+1);

    input_min  = double(min(img_channel(:)));
    input_max  = double(max(img_channel(:)));
    output_min = double(min(output_channel(:)));
    output_max = double(max(output_channel(:)));

    input_entropy  = calculate_entropy(hist_values);
    output_hist    = calculate_histogram(output_channel);
    output_entropy = calculate_entropy(output_hist);

    stats = struct('input_min',input_min,'input_max',input_max, ...
                   'output_min',output_min,'output_max',output_max, ...
                   'input_entropy',input_entropy,'output_entropy',output_entropy, ...
                   'cdf',cdf,'transform_func',T);
end

function entropy = calculate_entropy(hist_values)
    total_pixels = sum(hist_values);
    if total_pixels == 0
        entropy = 0;
        return;
    end
    
    probabilities = hist_values(hist_values > 0) / total_pixels;
    entropy = -sum(probabilities .* log2(probabilities));
end