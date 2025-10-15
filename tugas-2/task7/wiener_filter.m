function restored = wiener_filter(blurred, psf, nsr)
    % WIENER_FILTER Custom Wiener filter implementation for image restoration
    %
    % Inputs:
    %   blurred - Blurred/degraded image (grayscale or color)
    %   psf     - Point Spread Function (degradation kernel)
    %   nsr     - Noise-to-Signal Ratio (K parameter)
    %
    % Output:
    %   restored - Restored image using Wiener filtering
    %
    % Wiener Filter Formula in frequency domain:
    %   F_restored = [H*(s) / (|H|^2 + K)] * G
    %   where H = PSF in freq domain, G = degraded image in freq domain
    %         K = noise-to-signal ratio, H* = complex conjugate of H
    
    % Get image dimensions
    [M, N, channels] = size(blurred);
    
    % Convert PSF to same size as image (zero-padded)
    psf_padded = zeros(M, N);
    [psf_m, psf_n] = size(psf);
    psf_padded(1:psf_m, 1:psf_n) = psf;
    
    % Circular shift PSF to center it
    psf_padded = circshift(psf_padded, [-floor(psf_m/2), -floor(psf_n/2)]);
    
    % Transform PSF to frequency domain
    H = fft2(psf_padded);
    
    % Calculate Wiener filter
    % W(u,v) = H*(u,v) / (|H(u,v)|^2 + K)
    H_conj = conj(H);
    H_abs_sq = abs(H).^2;
    wiener_filter_freq = H_conj ./ (H_abs_sq + nsr);
    
    % Apply to each channel
    if channels == 3
        % Color image
        restored = zeros(M, N, 3, class(blurred));
        for ch = 1:3
            % Transform blurred image to frequency domain
            G = fft2(double(blurred(:,:,ch)));
            
            % Apply Wiener filter
            F = wiener_filter_freq .* G;
            
            % Transform back to spatial domain
            restored(:,:,ch) = real(ifft2(F));
        end
    else
        % Grayscale image
        % Transform blurred image to frequency domain
        G = fft2(double(blurred));
        
        % Apply Wiener filter
        F = wiener_filter_freq .* G;
        
        % Transform back to spatial domain
        restored = real(ifft2(F));
    end
    
    % Convert back to original class
    restored = cast(restored, class(blurred));
end

