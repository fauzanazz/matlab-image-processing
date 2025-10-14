function [enhanced, spectrum] = homomorphicFilter(image, gammaL, gammaH, c, D0)
    isColor = (size(image, 3) == 3);

    if isColor
        hsv = rgb2hsv(image);
        [v_enhanced, spectrum] = processChannel(uint8(hsv(:,:,3) * 255), gammaL, gammaH, c, D0);
        hsv(:,:,3) = double(v_enhanced) / 255.0;
        hsv(:,:,2) = hsv(:,:,2) .^ 0.7;  % Power < 1 boosts saturation
        hsv(:,:,2) = min(hsv(:,:,2) * 1.5, 1.0);  % Then scale up
        enhanced = im2uint8(hsv2rgb(hsv));
    else
        [enhanced, spectrum] = processChannel(image, gammaL, gammaH, c, D0);
    end
end

function [enhanced, spectrum] = processChannel(img, gammaL, gammaH, c, D0)
    img_orig = double(img);
    img_normalized = img_orig / 255.0;
    epsilon = 1e-6;
    img_normalized = img_normalized + epsilon;
    logImg = log(img_normalized);
    F = fft2(logImg);
    F_shifted = fftshift(F);
    [M, N] = size(img);
    H = createHomomorphicFilter(M, N, gammaL, gammaH, c, D0);
    G_shifted = F_shifted .* H;
    G = ifftshift(G_shifted);
    g = real(ifft2(G));
    enhanced = exp(g);
    enhanced = enhanced - epsilon;
    enhanced(enhanced < 0) = 0;
    minVal = min(enhanced(:));
    maxVal = max(enhanced(:));

    if maxVal > minVal
        enhanced = (enhanced - minVal) / (maxVal - minVal);
    end

    gamma = 0.3;  
    enhanced = enhanced .^ gamma;
    enhanced = uint8(enhanced * 255);
    spectrum.original = log(1 + abs(fftshift(fft2(img_normalized))));
    spectrum.filtered = log(1 + abs(G_shifted));
    spectrum.filter = H;
    spectrum.logImage = logImg;
end

function H = createHomomorphicFilter(M, N, gammaL, gammaH, c, D0)
    u = 0:(M-1);
    v = 0:(N-1);
    idx = find(u > M/2);
    u(idx) = u(idx) - M;
    idx = find(v > N/2);
    v(idx) = v(idx) - N;
    [V, U] = meshgrid(v, u);
    D = sqrt(U.^2 + V.^2);
    H = (gammaH - gammaL) * (1 - exp(-c * (D.^2 / D0^2))) + gammaL;
end
