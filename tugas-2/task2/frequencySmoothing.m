function [smoothed, filterUsed, spectrum] = frequencySmoothing(image, method, cutoffFreq, varargin)
    p = inputParser;
    addRequired(p, 'image');
    addRequired(p, 'method', @ischar);
    addRequired(p, 'cutoffFreq', @isnumeric);
    addOptional(p, 'order', 2, @isnumeric);
    parse(p, image, method, cutoffFreq, varargin{:});
    
    order = p.Results.order;
    
    [M, N, channels] = size(image);
    smoothed = zeros(size(image), class(image));
    
    spectrum = struct();
    
    for c = 1:channels
        img = double(image(:,:,c));
        
        F = fft2(img);
        F_shifted = fftshift(F); % Shift zero frequency ke center
        
        filterUsed = createLowPassFilter(M, N, method, cutoffFreq, order);
        
        G_shifted = F_shifted .* filterUsed;
        
        G = ifftshift(G_shifted);
        g = real(ifft2(G));
        
        g = max(0, min(255, g));
        smoothed(:,:,c) = g;
        
        if c == 1
            spectrum.original = log(1 + abs(F_shifted));
            spectrum.filtered = log(1 + abs(G_shifted));
            spectrum.filter = filterUsed;
        end
    end
    
    smoothed = cast(smoothed, class(image));
end