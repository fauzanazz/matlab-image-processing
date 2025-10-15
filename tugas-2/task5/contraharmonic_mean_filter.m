function filtered_img = contraharmonic_mean_filter(img, filter_size, Q)
% CONTRAHARMONIC_MEAN_FILTER Apply contraharmonic mean filter to an image
%   filtered_img = contraharmonic_mean_filter(img, filter_size, Q)
%   
%   Inputs:
%       img         - Input image (grayscale or color)
%       filter_size - Size of filter window (default 3)
%       Q           - Filter order (default 1.5)
%                     Q > 0: eliminates pepper noise
%                     Q < 0: eliminates salt noise
%   
%   Output:
%       filtered_img - Filtered image

    if nargin < 2
        filter_size = 3;
    end
    if nargin < 3
        Q = 1.5;
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
                % Apply contraharmonic mean: sum(f^(Q+1)) / sum(f^Q)
                numerator = sum(neighborhood(:).^(Q+1));
                denominator = sum(neighborhood(:).^Q);
                
                if denominator ~= 0
                    filtered_img(i, j, ch) = numerator / denominator;
                else
                    filtered_img(i, j, ch) = 0;
                end
            end
        end
    end
end

