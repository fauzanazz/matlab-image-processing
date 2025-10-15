function filtered_img = geometric_mean_filter(img, filter_size)
% GEOMETRIC_MEAN_FILTER Apply geometric mean filter to an image
%   filtered_img = geometric_mean_filter(img, filter_size)
%   
%   Inputs:
%       img         - Input image (grayscale or color)
%       filter_size - Size of filter window (default 3)
%   
%   Output:
%       filtered_img - Filtered image

    if nargin < 2
        filter_size = 3;
    end
    
    [rows, cols, channels] = size(img);
    filtered_img = zeros(rows, cols, channels, 'uint8');
    pad_size = floor(filter_size / 2);
    
    for ch = 1:channels
        % Pad image with replicate border
        padded = double(padarray(img(:,:,ch), [pad_size pad_size], 'replicate'));
        
        for i = 1:rows
            for j = 1:cols
                % Extract neighborhood
                neighborhood = padded(i:i+filter_size-1, j:j+filter_size-1);
                % Apply geometric mean: (product of all values)^(1/n)
                neighborhood(neighborhood == 0) = 1; % Avoid log(0)
                filtered_img(i, j, ch) = prod(neighborhood(:))^(1/numel(neighborhood));
            end
        end
    end
end

