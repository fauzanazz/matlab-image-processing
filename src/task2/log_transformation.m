function output_img = log_transformation(img, c)
    % Log transformation: s = c * log(1 + r)
    % Input: img - input image (grayscale or color)
    %        c - scaling constant (default: 1)
    % Output: output_img - log transformed image
    
    if nargin < 2, c = 1; end
    
    if ~isnumeric(c) || c <= 0
        error('Parameter c must be a positive number');
    end
    
    img_double = double(img);
    log_img = c * log(1 + img_double);
    min_val = min(log_img(:));
    max_val = max(log_img(:));
    
    if max_val > min_val
        output_img = ((log_img - min_val) / (max_val - min_val)) * 255;
    else
        output_img = log_img;
    end
    
    output_img = uint8(output_img);
    
    fprintf('Log Transformation Applied:\n');
    fprintf('  Formula: s = %.2f * log(1 + r)\n', c);
    fprintf('  Original range: [%d, %d]\n', min(img(:)), max(img(:)));
    fprintf('  Before normalization: [%.2f, %.2f]\n', min_val, max_val);
    fprintf('  Final range: [%d, %d]\n', min(output_img(:)), max(output_img(:)));
end