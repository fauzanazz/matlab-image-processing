function [filtered, filterUsed, spectrum] = frequencyHighPass(image, method, cutoffFreq, varargin)
    p = inputParser;
    addRequired(p, 'image');
    addRequired(p, 'method', @ischar);
    addRequired(p, 'cutoffFreq', @isnumeric);
    addOptional(p, 'order', 2, @isnumeric);
    addOptional(p, 'boostFactor', 1.0, @isnumeric);
    parse(p, image, method, cutoffFreq, varargin{:});
    
    order = p.Results.order;
    boostFactor = p.Results.boostFactor;
    
    [M, N, channels] = size(image);
    filtered = zeros(size(image));
    spectrum = struct();
    
    for c = 1:channels
        img = double(image(:,:,c));
        F = fft2(img);
        F_shifted = fftshift(F); 
        
        filterUsed = createHighPassFilter(M, N, method, cutoffFreq, order);
        G_shifted = F_shifted .* filterUsed;
        
        if boostFactor ~= 1.0
            G_shifted = G_shifted * boostFactor;
        end
        
        G = ifftshift(G_shifted);
        g = real(ifft2(G));
        
        g = g - min(g(:));
        g = g / max(g(:)) * 255;
        
        filtered(:,:,c) = g;
        
        if c == 1
            spectrum.original = log(1 + abs(F_shifted));
            spectrum.filtered = log(1 + abs(G_shifted));
            spectrum.filter = filterUsed;
            spectrum.magnitude = abs(F_shifted);
            spectrum.phase = angle(F_shifted);
        end
    end
    
    filtered = uint8(filtered);
end