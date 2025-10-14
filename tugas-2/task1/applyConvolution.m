function output = applyConvolution(image, mask, paddingMethod)
    if nargin < 3
        paddingMethod = 'zero';
    end
    
    [~, ~, channels] = size(image);
    
    if channels == 1
        output = convolution2D(image, mask, paddingMethod);
        
    elseif channels == 3
        output = zeros(size(image));
        
        for c = 1:3
            output(:, :, c) = convolution2D(image(:, :, c), mask, paddingMethod);
        end
        
    else
        error('Format citra tidak didukung. Gunakan grayscale atau RGB.');
    end
    
    output = uint8(output);
    
end