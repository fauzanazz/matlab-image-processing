function visualize_psf(len, theta, img_size)
    % VISUALIZE_PSF Visualize motion blur PSF in spatial and frequency domain
    %
    % Inputs:
    %   len      - Length of motion blur
    %   theta    - Angle of motion (degrees)
    %   img_size - [optional] Size for frequency domain visualization [M, N]
    
    if nargin < 3
        img_size = [256, 256];
    end
    
    % Create PSF
    psf = fspecial('motion', len, theta);
    
    % Pad PSF to image size
    psf_padded = zeros(img_size);
    [psf_m, psf_n] = size(psf);
    psf_padded(1:psf_m, 1:psf_n) = psf;
    psf_padded = circshift(psf_padded, [-floor(psf_m/2), -floor(psf_n/2)]);
    
    % Frequency domain
    H = fft2(psf_padded);
    H_magnitude = abs(fftshift(H));
    H_phase = angle(fftshift(H));
    
    % Wiener filter response for different NSR
    nsr_values = [0.001, 0.01, 0.1];
    
    figure('Name', sprintf('PSF Visualization (L=%d, θ=%d°)', len, theta), ...
           'Position', [100, 100, 1400, 800]);
    
    % Spatial domain PSF
    subplot(3, 4, 1);
    imshow(psf, []);
    title('PSF (Spatial)');
    colormap(gca, 'hot');
    colorbar;
    
    % Padded PSF
    subplot(3, 4, 2);
    imshow(psf_padded, []);
    title('PSF (Padded & Shifted)');
    
    % Frequency magnitude
    subplot(3, 4, 3);
    imshow(log(1 + H_magnitude), []);
    title('|H(u,v)| (Log scale)');
    colormap(gca, 'jet');
    colorbar;
    
    % Frequency phase
    subplot(3, 4, 4);
    imshow(H_phase, []);
    title('∠H(u,v)');
    colormap(gca, 'hsv');
    colorbar;
    
    % Cross-section of PSF
    subplot(3, 4, 5);
    [psf_m, psf_n] = size(psf);
    center_row = floor(psf_m/2) + 1;
    plot(psf(center_row, :), 'b-', 'LineWidth', 2);
    grid on;
    title('PSF Cross-section');
    xlabel('Pixel');
    ylabel('Value');
    
    % 3D PSF
    subplot(3, 4, 6);
    surf(psf);
    shading interp;
    view(45, 60);
    title('PSF (3D view)');
    xlabel('X');
    ylabel('Y');
    zlabel('Value');
    
    % Frequency magnitude (3D)
    subplot(3, 4, 7);
    [u, v] = meshgrid(1:img_size(2), 1:img_size(1));
    surf(u, v, log(1 + H_magnitude));
    shading interp;
    view(45, 60);
    title('|H(u,v)| (3D)');
    xlabel('u');
    ylabel('v');
    zlabel('Log Magnitude');
    
    % Frequency cross-section
    subplot(3, 4, 8);
    center = floor(img_size(1)/2) + 1;
    plot(H_magnitude(center, :), 'r-', 'LineWidth', 2);
    grid on;
    title('|H(u,v)| Cross-section');
    xlabel('Frequency (u)');
    ylabel('Magnitude');
    
    % Wiener filter responses for different NSR
    for i = 1:3
        H_abs_sq = abs(H).^2;
        H_conj = conj(H);
        W = H_conj ./ (H_abs_sq + nsr_values(i));
        W_magnitude = abs(fftshift(W));
        
        subplot(3, 4, 8 + i);
        imshow(log(1 + W_magnitude), []);
        title(sprintf('Wiener Filter (NSR=%.3f)', nsr_values(i)));
        colormap(gca, 'jet');
        colorbar;
    end
    
    % Comparison plot
    subplot(3, 4, 12);
    hold on;
    colors = {'b', 'r', 'g'};
    for i = 1:3
        H_abs_sq = abs(H).^2;
        H_conj = conj(H);
        W = H_conj ./ (H_abs_sq + nsr_values(i));
        W_magnitude = abs(fftshift(W));
        plot(W_magnitude(center, :), colors{i}, 'LineWidth', 1.5);
    end
    grid on;
    legend(arrayfun(@(x) sprintf('NSR=%.3f', x), nsr_values, 'UniformOutput', false));
    title('Wiener Filter Comparison');
    xlabel('Frequency (u)');
    ylabel('Magnitude');
    
    % Print information
    fprintf('PSF Information:\n');
    fprintf('  Size: %dx%d\n', psf_m, psf_n);
    fprintf('  Motion length: %d pixels\n', len);
    fprintf('  Motion angle: %d degrees\n', theta);
    fprintf('  Sum of PSF: %.6f\n', sum(psf(:)));
    fprintf('  Max value: %.6f\n', max(psf(:)));
    fprintf('  Energy: %.6f\n', sum(psf(:).^2));
end

