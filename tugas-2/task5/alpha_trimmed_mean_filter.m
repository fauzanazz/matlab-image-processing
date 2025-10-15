function filtered_img = alpha_trimmed_mean_filter(img, filter_size, d)
% ALPHA_TRIMMED_MEAN_FILTER Apply alpha-trimmed mean filter to an image
%   filtered_img = alpha_trimmed_mean_filter(img, filter_size, d)
%   
%   Inputs:
%       img         - Input image (grayscale or color)
%       filter_size - Size of filter window (default 3)
%       d           - Number of lowest and highest values to trim (default 2)
%   
%   Output:
%       filtered_img - Filtered image

    if nargin < 2
        filter_size = 3;
    end
    if nargin < 3
        d = 2;
    end
    
    [rows, cols, channels] = size(img);
    filtered_img = zeros(rows, cols, channels, 'uint8');
    pad_size = floor(filter_size / 2);
    
    for ch = 1:channels
        % Pad image with replicate border
        padded = padarray(img(:,:,ch), [pad_size pad_size], 'replicate');
        
        for i = 1:rows
            for j = 1:cols
                % Extract neighborhood
                neighborhood = padded(i:i+filter_size-1, j:j+filter_size-1);
                sorted_vals = sort(neighborhood(:));
                
                % Remove d lowest and d highest values
                n = length(sorted_vals);
                if d < n/2
                    trimmed_vals = sorted_vals(d+1:n-d);
                    filtered_img(i, j, ch) = mean(trimmed_vals);
                else
                    filtered_img(i, j, ch) = median(sorted_vals);
                end
            end
        end
    end
end

