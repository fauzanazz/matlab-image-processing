function [sharpened, enhancementMask] = sharpenImage(image, method, cutoffFreq, varargin)
    p = inputParser;
    addRequired(p, 'image');
    addRequired(p, 'method');
    addRequired(p, 'cutoffFreq');
    addOptional(p, 'k1', 1.0, @isnumeric);
    addOptional(p, 'k2', 0.5, @isnumeric);
    parse(p, image, method, cutoffFreq, varargin{:});
    
    k1 = p.Results.k1;
    k2 = p.Results.k2;
    
    [~, ~, channels] = size(image);
    sharpened = zeros(size(image));
    
    for c = 1:channels
        img = double(image(:,:,c));
        
        if strcmpi(method, 'unsharp')
            F = fft2(img);
            F_shifted = fftshift(F);
            
            [M, N] = size(img);
            H_lp = 1 - createHighPassFilter(M, N, 'GHPF', cutoffFreq);
            
            G_shifted = F_shifted .* H_lp;
            G = ifftshift(G_shifted);
            g_lp = real(ifft2(G));
            g_hp = img - g_lp;
            sharpened(:,:,c) = k1 * img + k2 * g_hp;
            
            enhancementMask = g_hp;
        else
            filtered = frequencyHighPass(image(:,:,c), method, cutoffFreq);
            g_hp = double(filtered);
            g_hp = g_hp - mean(g_hp(:));
            sharpened(:,:,c) = img + k2 * g_hp;
            
            enhancementMask = g_hp;
        end
    end
    
    sharpened = max(0, min(255, sharpened));
    sharpened = uint8(sharpened);
end