function results = analyzeFrequency(image, displayPlots)
    if nargin < 2
        displayPlots = true;
    end
    
    if size(image, 3) == 3
        img = rgb2gray(image);
    else
        img = image;
    end
    
    img = double(img);
    [M, N] = size(img);
    
    F = fft2(img);
    F_shifted = fftshift(F);
    
    magnitude = abs(F_shifted);
    phase = angle(F_shifted);
    power = magnitude.^2;
    logMagnitude = log(1 + magnitude);
    
    results = struct();
    results.size = [M, N];
    results.magnitude = magnitude;
    results.phase = phase;
    results.power = power;
    results.logMagnitude = logMagnitude;
    
    results.DC = F_shifted(round(M/2), round(N/2));
    results.DCMagnitude = abs(results.DC);
    results.totalEnergy = sum(power(:));
    results.avgMagnitude = mean(magnitude(:));
    results.maxMagnitude = max(magnitude(:));
    
    center = [round(M/2), round(N/2)];
    radius = min(M, N) / 4;
    
    [X, Y] = meshgrid(1:N, 1:M);
    dist = sqrt((X - center(2)).^2 + (Y - center(1)).^2);
    
    lowFreqMask = dist <= radius;
    highFreqMask = ~lowFreqMask;
    
    results.lowFreqEnergy = sum(power(lowFreqMask));
    results.highFreqEnergy = sum(power(highFreqMask));
    results.energyRatio = results.lowFreqEnergy / results.highFreqEnergy;
    
    maxRadius = floor(min(M, N) / 2);
    radialProfile = zeros(1, maxRadius);
    
    for r = 1:maxRadius
        mask = (dist >= r-0.5) & (dist < r+0.5);
        radialProfile(r) = mean(magnitude(mask));
    end
    
    results.radialProfile = radialProfile;
    
    if displayPlots
        figure('Name', 'Frequency Domain Analysis', 'Position', [50 50 1400 900]);
        
        subplot(3, 4, 1);
        imshow(img, []); title('Original Image');
        
        subplot(3, 4, 2);
        imshow(logMagnitude, []); title('Log Magnitude Spectrum');
        colormap(gca, 'jet'); colorbar;
        
        subplot(3, 4, 3);
        imshow(phase, []); title('Phase Spectrum');
        colormap(gca, 'hsv'); colorbar;
        
        subplot(3, 4, 4);
        imshow(log(1 + power), []); title('Power Spectrum');
        colormap(gca, 'jet'); colorbar;
        
        subplot(3, 4, 5);
        [X, Y] = meshgrid(1:20:N, 1:20:M);
        Z = logMagnitude(1:20:M, 1:20:N);
        surf(X, Y, Z, 'EdgeColor', 'none');
        title('3D Magnitude'); view(45, 30);
        
        subplot(3, 4, 6);
        plot(radialProfile, 'LineWidth', 2);
        xlabel('Radius (pixels)');
        ylabel('Average Magnitude');
        title('Radial Profile');
        grid on;
        
        subplot(3, 4, 7);
        histogram(magnitude(:), 50);
        xlabel('Magnitude');
        ylabel('Frequency');
        title('Magnitude Histogram');
        
        subplot(3, 4, 8);
        bar([results.lowFreqEnergy, results.highFreqEnergy]);
        set(gca, 'XTickLabel', {'Low Freq', 'High Freq'});
        ylabel('Energy');
        title('Energy Distribution');
        grid on;
        
        subplot(3, 4, 9);
        H_lp = createLowPassFilter(M, N, 'GLPF', 50);
        G_lp = ifft2(ifftshift(F_shifted .* H_lp));
        imshow(real(G_lp), []); title('Low-Pass Filtered');
        
        subplot(3, 4, 10);
        H_hp = createHighPassFilter(M, N, 'GHPF', 30);
        G_hp = ifft2(ifftshift(F_shifted .* H_hp));
        imshow(real(G_hp), []); title('High-Pass Filtered');
        
        subplot(3, 4, 11);
        imshow([H_lp, H_hp], []); 
        title('LPF (left) vs HPF (right)');
        colorbar;
        
        subplot(3, 4, 12);
        axis off;
        text(0.1, 0.9, sprintf('DC Magnitude: %.2f', results.DCMagnitude), 'FontSize', 10);
        text(0.1, 0.8, sprintf('Total Energy: %.2e', results.totalEnergy), 'FontSize', 10);
        text(0.1, 0.7, sprintf('Avg Magnitude: %.2f', results.avgMagnitude), 'FontSize', 10);
        text(0.1, 0.6, sprintf('Max Magnitude: %.2f', results.maxMagnitude), 'FontSize', 10);
        text(0.1, 0.5, sprintf('Energy Ratio: %.2f', results.energyRatio), 'FontSize', 10);
        text(0.1, 0.4, 'Low/High Freq Energy', 'FontSize', 9);
        title('Statistics');
    end
end