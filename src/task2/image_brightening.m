function output_img = image_brightening(img, a, b)
    % Image brightening: s = a*r + b
    % Input: img - input image (grayscale or color)
    %        a - contrast multiplier (default: 1)
    %        b - brightness offset (default: 0)
    % Output: output_img - enhanced image
    
    if nargin < 2, a = 1; end
    if nargin < 3, b = 0; end
    
    if ~isnumeric(a) || ~isnumeric(b)
        error('Parameters a and b must be numeric');
    end
    
    img_double = double(img);
    output_img = a * img_double + b;
    output_img = max(0, min(255, output_img));
    output_img = uint8(output_img);
    
    fprintf('Image Brightening Applied:\n');
    fprintf('  Formula: s = %.2f*r + %.2f\n', a, b);
    fprintf('  Original range: [%d, %d]\n', min(img(:)), max(img(:)));
    fprintf('  Output range: [%d, %d]\n', min(output_img(:)), max(output_img(:)));
end