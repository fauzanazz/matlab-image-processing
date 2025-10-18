function test_ringing_effect(image, D0, usePadding)
% TEST_RINGING_EFFECT - Demonstrasi ringing effect
%
% Program ini menunjukkan bahwa IHPF menghasilkan ringing artifact
% karena diskontinuitas fungsi filter, sedangkan GHPF tidak.
%
% Syntax:
%   test_ringing_effect(image, D0, usePadding)
%
% Input:
%   image      - Citra input (akan dikonversi ke grayscale)
%   D0         - Cutoff frequency (default: 30, gunakan nilai kecil untuk ringing jelas)
%   usePadding - true/false (default: true)

    if nargin < 2
        D0 = 30; 
    end
    if nargin < 3
        usePadding = true;
    end

    if size(image, 3) == 3
        image = rgb2gray(image);
    end

    fprintf('========================================\n');
    fprintf('RINGING EFFECT DEMONSTRATION\n');
    fprintf('========================================\n');
    fprintf('Cutoff frequency D0 = %d\n', D0);
    fprintf('Slide Reference: 24-25\n\n');

    fprintf('Applying IHPF (akan ada ringing)...\n');
    [ihpf_result, ihpf_H, ihpf_spectrum] = ihpf(image, D0, usePadding);

    fprintf('Applying GHPF (tidak ada ringing)...\n');
    [ghpf_result, ghpf_H, ghpf_spectrum] = ghpf(image, D0, usePadding);

    difference = abs(double(ihpf_result) - double(ghpf_result));

    figure('Name', 'Ringing Effect Analysis (Slide 24-25)', 'Position', [50 50 1600 900]);

    subplot(3, 4, 1);
    imshow(image);
    title('Original Image', 'FontWeight', 'bold');

    subplot(3, 4, 2);
    imshow(ihpf_result);
    title(sprintf('IHPF (D0=%d)\nADA RINGING', D0), 'Color', 'red', 'FontWeight', 'bold');

    subplot(3, 4, 3);
    imshow(ghpf_result);
    title(sprintf('GHPF (D0=%d)\nTIDAK ADA RINGING', D0), 'Color', 'green', 'FontWeight', 'bold');

    subplot(3, 4, 4);
    imshow(difference, []);
    title('Difference (Ringing Artifact)');
    colorbar;
    colormap(gca, 'hot');

    subplot(3, 4, 5);
    text(0.5, 0.5, 'Filter Visualization', 'HorizontalAlignment', 'center', ...
         'FontSize', 10, 'FontWeight', 'bold');
    axis off;

    subplot(3, 4, 6);
    imshow(ihpf_H);
    title('IHPF Filter (Diskontinuitas Tajam)');
    colorbar;

    subplot(3, 4, 7);
    imshow(ghpf_H);
    title('GHPF Filter (Transisi Smooth)');
    colorbar;

    subplot(3, 4, 8);
    centerRow = round(size(ihpf_H, 1) / 2);
    plot(ihpf_H(centerRow, :), 'b-', 'LineWidth', 2); hold on;
    plot(ghpf_H(centerRow, :), 'r-', 'LineWidth', 2);
    legend('IHPF (Tajam)', 'GHPF (Smooth)', 'Location', 'best');
    title('Filter Cross-Section');
    xlabel('Frequency'); ylabel('H(u,v)');
    grid on;
    ylim([0 1.1]);

    subplot(3, 4, 9);
    imshow(log(1 + abs(fftshift(fft2(double(image))))), []);
    title('Original Spectrum');
    colormap(gca, 'jet');

    subplot(3, 4, 10);
    imshow(ihpf_spectrum.filtered, []);
    title('IHPF Filtered Spectrum');
    colormap(gca, 'jet');

    subplot(3, 4, 11);
    imshow(ghpf_spectrum.filtered, []);
    title('GHPF Filtered Spectrum');
    colormap(gca, 'jet');

    subplot(3, 4, 12);
    profile_row = round(size(image, 1) / 2);
    plot(double(image(profile_row, :)), 'k-', 'LineWidth', 1.5); hold on;
    plot(double(ihpf_result(profile_row, :))*255, 'b-', 'LineWidth', 1.5);
    plot(double(ghpf_result(profile_row, :))*255, 'r-', 'LineWidth', 1.5);
    legend('Original', 'IHPF (dengan ringing)', 'GHPF (smooth)', ...
           'Location', 'best', 'FontSize', 8);
    title('Cross-Section Profile (Tengah)');
    xlabel('Column'); ylabel('Intensity');
    grid on;

    sgtitle(['Ringing Effect Demonstration (Slide 24-25) | D0 = ' num2str(D0)], ...
            'FontSize', 14, 'FontWeight', 'bold');

    fprintf('\n========================================\n');
    fprintf('ANALISIS RINGING EFFECT\n');
    fprintf('========================================\n');
    fprintf('IHPF (Ideal High-Pass Filter):\n');
    fprintf('  - Memiliki transisi TAJAM (diskontinuitas)\n');
    fprintf('  - Menimbulkan RINGING ARTIFACT\n');
    fprintf('  - Terlihat sebagai "ringing" pada tepi\n\n');
    fprintf('GHPF (Gaussian High-Pass Filter):\n');
    fprintf('  - Memiliki transisi SMOOTH (continuous)\n');
    fprintf('  - TIDAK menimbulkan ringing\n');
    fprintf('  - Hasil lebih natural\n\n');
    fprintf('Difference Image:\n');
    fprintf('  - Intensitas rata-rata: %.4f\n', mean(difference(:)));
    fprintf('  - Max difference: %.4f\n', max(difference(:)));
    fprintf('  - Area dengan perbedaan tinggi = ringing\n');
    fprintf('========================================\n\n');
end
