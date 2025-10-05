function output_img = contrast_stretching(img)
    % Automatic contrast stretching using histogram analysis
    % Formula: s = ((r - r_min) / (r_max - r_min)) * 255
    % r_min and r_max are automatically determined from histogram
    % Input: img - input image (grayscale or color)
    % Output: output_img - contrast stretched image
    
    addpath('../task1');
    
    if size(img, 3) == 3
        output_img = zeros(size(img), 'uint8');
        fprintf('Contrast Stretching Applied (Color Image):\n');
        
        channel_names = {'Red', 'Green', 'Blue'};
        for ch = 1:3
            [output_img(:,:,ch), r_min, r_max] = stretch_single_channel(img(:,:,ch));
            fprintf('  %s Channel: [%d, %d] -> [0, 255]\n', channel_names{ch}, r_min, r_max);
        end
    else
        fprintf('Contrast Stretching Applied (Grayscale):\n');
        [output_img, r_min, r_max] = stretch_single_channel(img);
        fprintf('  Range: [%d, %d] -> [0, 255]\n', r_min, r_max);
    end
end

function [output_channel, r_min, r_max] = stretch_single_channel(img_channel)
    hist_values = calculate_histogram(img_channel);
    nonzero_indices = find(hist_values > 0);
    
    if isempty(nonzero_indices)
        output_channel = img_channel;
        r_min = double(img_channel(1,1));
        r_max = r_min;
        return;
    end
    
    r_min = nonzero_indices(1) - 1;
    r_max = nonzero_indices(end) - 1;
    
    if r_min == r_max
        output_channel = img_channel;
        return;
    end
    
    img_double = double(img_channel);
    stretched = ((img_double - r_min) / (r_max - r_min)) * 255;
    stretched = max(0, min(255, stretched));
    output_channel = uint8(stretched);
end