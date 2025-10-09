function output_img = image_negative(img)
    % Image negative transformation: s = 255 - r
    % Input: img - input image (grayscale or color)
    % Output: output_img - negative image
    
    if ~isa(img, 'uint8')
        if isa(img, 'double') && max(img(:)) <= 1
            img = uint8(img * 255);
        else
            img = uint8(img);
        end
    end
    
    output_img = 255 - img;
    
    fprintf('Image Negative Applied:\n');
    fprintf('  Formula: s = 255 - r\n');
    fprintf('  Image type: %s\n', class(img));
    if size(img, 3) == 3
        fprintf('  Color channels: RGB\n');
    else
        fprintf('  Image type: Grayscale\n');
    end
end