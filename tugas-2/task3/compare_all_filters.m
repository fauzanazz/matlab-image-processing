function compare_all_filters(image, D0_values, usePadding)
% COMPARE_ALL_FILTERS - Membandingkan IHPF, GHPF, dan BHPF
%
% Syntax:
%   compare_all_filters(image, D0_values, usePadding)
%
% Input:
%   image      - Citra input (grayscale atau RGB)
%   D0_values  - Array nilai cutoff frequency untuk diuji (default: [20, 50, 80])
%   usePadding - true/false untuk padding (default: true)
%
% Output:
%   Menampilkan figure perbandingan
%
% Contoh:
%   img = imread('cameraman.tif');
%   compare_all_filters(img, [20, 40, 60], true);

    if nargin < 2
        D0_values = [20, 50, 80];
    end
    if nargin < 3
        usePadding = true;
    end

    if size(image, 3) == 3
        image = rgb2gray(image);
    end

    n_D0 = length(D0_values);
    butterworth_order = 2;

    figure('Name', 'Comprehensive Filter Comparison', 'Position', [50 50 1600 1000]);

    subplot(4, n_D0+1, 1);
    imshow(image);
    title('Original Image', 'FontWeight', 'bold');

    for i = 1:n_D0
        D0 = D0_values(i);

        % IHPF
        [ihpf_result, ihpf_H, ~] = ihpf(image, D0, usePadding);
        subplot(4, n_D0+1, i+1);
        imshow(ihpf_result);
        title(sprintf('IHPF D0=%d', D0));

        % GHPF
        [ghpf_result, ghpf_H, ~] = ghpf(image, D0, usePadding);
        subplot(4, n_D0+1, n_D0+1 + i+1);
        imshow(ghpf_result);
        title(sprintf('GHPF D0=%d', D0));

        % BHPF
        [bhpf_result, bhpf_H, ~] = bhpf(image, D0, butterworth_order, usePadding);
        subplot(4, n_D0+1, 2*(n_D0+1) + i+1);
        imshow(bhpf_result);
        title(sprintf('BHPF D0=%d n=%d', D0, butterworth_order));

        subplot(4, n_D0+1, 3*(n_D0+1) + i+1);
        centerRow = round(size(ihpf_H, 1) / 2);
        plot(ihpf_H(centerRow, :), 'b-', 'LineWidth', 1.5); hold on;
        plot(ghpf_H(centerRow, :), 'r-', 'LineWidth', 1.5);
        plot(bhpf_H(centerRow, :), 'g-', 'LineWidth', 1.5);
        legend('IHPF', 'GHPF', 'BHPF', 'Location', 'best', 'FontSize', 8);
        title(sprintf('Filter Profile D0=%d', D0), 'FontSize', 9);
        xlabel('Frequency', 'FontSize', 8);
        ylabel('H(u,v)', 'FontSize', 8);
        grid on;
        ylim([0 1.1]);
    end

    subplot(4, n_D0+1, 1);
    ylabel('Original', 'FontWeight', 'bold', 'FontSize', 12);

    subplot(4, n_D0+1, n_D0+1 + 1);
    text(0.5, 0.5, 'GHPF Results', 'HorizontalAlignment', 'center', ...
         'FontSize', 10, 'FontWeight', 'bold');
    axis off;

    subplot(4, n_D0+1, 2*(n_D0+1) + 1);
    text(0.5, 0.5, 'BHPF Results', 'HorizontalAlignment', 'center', ...
         'FontSize', 10, 'FontWeight', 'bold');
    axis off;

    subplot(4, n_D0+1, 3*(n_D0+1) + 1);
    text(0.5, 0.5, 'Filter Profiles', 'HorizontalAlignment', 'center', ...
         'FontSize', 10, 'FontWeight', 'bold');
    axis off;

    sgtitle('Comprehensive HPF Comparison: IHPF vs GHPF vs BHPF', ...
            'FontSize', 14, 'FontWeight', 'bold');
end
