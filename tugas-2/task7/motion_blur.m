function blurred = motion_blur(img, len, theta)
    % MOTION_BLUR Apply motion blur to an image
    %
    % Inputs:
    %   img   - Input image (grayscale or color)
    %   len   - Length of motion blur in pixels
    %   theta - Angle of motion in degrees
    %
    % Output:
    %   blurred - Motion blurred image
    
    % Create motion blur PSF (Point Spread Function)
    psf = fspecial('motion', len, theta);
    
    % Check if image is color or grayscale
    if size(img, 3) == 3
        % Color image: apply to each channel
        blurred = zeros(size(img), class(img));
        for ch = 1:3
            blurred(:,:,ch) = imfilter(img(:,:,ch), psf, 'conv', 'same', 'replicate');
        end
    else
        % Grayscale image
        blurred = imfilter(img, psf, 'conv', 'same', 'replicate');
    end
end

