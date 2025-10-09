function output_img = power_transformation(img, c, gamma)
    % Power-law (gamma) transformation: s = c * r^gamma
    % Input: img - input image (grayscale or color)
    %        c - scaling constant (default: 1)
    %        gamma - power parameter (default: 1)
    % Output: output_img - power transformed image
    
    if nargin < 2, c = 1; end
    if nargin < 3, gamma = 1; end
    
    if ~isnumeric(c) || c <= 0
        error('Parameter c must be a positive number');
    end
    
    if ~isnumeric(gamma) || gamma <= 0
        error('Parameter gamma must be a positive number');
    end
    
    img_double = double(img) / 255;
    powered_img = c * (img_double .^ gamma);
    output_img = powered_img * 255;
    output_img = max(0, min(255, output_img));
    output_img = uint8(output_img);
    
    fprintf('Power Transformation Applied:\n');
    fprintf('  Formula: s = %.2f * r^%.2f\n', c, gamma);
    fprintf('  Original range: [%d, %d]\n', min(img(:)), max(img(:)));
    fprintf('  Output range: [%d, %d]\n', min(output_img(:)), max(output_img(:)));
    if gamma < 1
        fprintf('  Effect: Brightens dark regions (gamma < 1)\n');
    elseif gamma > 1
        fprintf('  Effect: Darkens bright regions (gamma > 1)\n');
    else
        fprintf('  Effect: No change (gamma = 1)\n');
    end
end