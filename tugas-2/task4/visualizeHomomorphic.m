function visualizeHomomorphic(original, enhanced, spectrum, params)
    figure('Name', 'Homomorphic Filtering Analysis', 'Position', [50 50 1400 900]);

    subplot(3, 4, 1);
    imshow(original);
    title('Original Image');

    subplot(3, 4, 2);
    imshow(enhanced);
    title(sprintf('Enhanced Image\n(γ_L=%.2f, γ_H=%.2f, c=%.2f, D_0=%d)', ...
        params.gammaL, params.gammaH, params.c, params.D0));

    subplot(3, 4, 3);
    if size(original, 3) == 1
        [countsOrig, bins] = imhist(original);
        [countsEnh, ~] = imhist(enhanced);
        plot(bins, countsOrig, 'b-', 'LineWidth', 1.5); hold on;
        plot(bins, countsEnh, 'r-', 'LineWidth', 1.5);
        legend('Original', 'Enhanced', 'Location', 'best');
    else
        hold on;
        for ch = 1:3
            [counts, bins] = imhist(original(:,:,ch));
            plot(bins, counts, '--', 'LineWidth', 1, 'Color', [ch==1, ch==2, ch==3]*0.7);
        end
        for ch = 1:3
            [counts, bins] = imhist(enhanced(:,:,ch));
            plot(bins, counts, '-', 'LineWidth', 1.5, 'Color', [ch==1, ch==2, ch==3]);
        end
        legend('R orig', 'G orig', 'B orig', 'R enh', 'G enh', 'B enh', 'Location', 'best');
    end
    xlabel('Intensity'); ylabel('Frequency');
    title('Histogram Comparison');
    grid on;

    subplot(3, 4, 4);
    meanOrig = mean(double(original(:)));
    meanEnh = mean(double(enhanced(:)));
    bar([meanOrig, meanEnh]);
    set(gca, 'XTickLabel', {'Original', 'Enhanced'});
    ylabel('Mean Brightness');
    title(sprintf('Brightness: %.1f → %.1f', meanOrig, meanEnh));
    grid on;

    subplot(3, 4, 5);
    imshow(spectrum.logImage, []);
    title('Log Transform');
    colormap(gca, 'gray');

    subplot(3, 4, 6);
    imshow(spectrum.original, []);
    title('Original Spectrum');
    colormap(gca, 'jet'); colorbar;

    subplot(3, 4, 7);
    imshow(spectrum.filter, []);
    title('Homomorphic Filter H(u,v)');
    colormap(gca, 'jet'); colorbar;

    subplot(3, 4, 8);
    imshow(spectrum.filtered, []);
    title('Filtered Spectrum');
    colormap(gca, 'jet'); colorbar;

    subplot(3, 4, 9);
    [M, N] = size(spectrum.filter);
    centerRow = round(M/2);
    plot(spectrum.filter(centerRow, :), 'b-', 'LineWidth', 2);
    hold on;
    yline(params.gammaL, 'r--', 'γ_L', 'LineWidth', 1.5);
    yline(params.gammaH, 'g--', 'γ_H', 'LineWidth', 1.5);
    xlabel('Frequency'); ylabel('H(u,v)');
    title('Filter Cross-Section');
    grid on;
    legend('H(u,v)', sprintf('γ_L = %.2f', params.gammaL), ...
        sprintf('γ_H = %.2f', params.gammaH), 'Location', 'best');

    subplot(3, 4, 10);
    [X, Y] = meshgrid(1:5:N, 1:5:M);
    Z = spectrum.filter(1:5:M, 1:5:N);
    surf(X, Y, Z, 'EdgeColor', 'none');
    title('3D Filter View');
    xlabel('u'); ylabel('v'); zlabel('H(u,v)');
    colormap(gca, 'jet'); colorbar;
    view(45, 30);

    subplot(3, 4, 11);
    contrastOrig = std(double(original(:)));
    contrastEnh = std(double(enhanced(:)));
    bar([contrastOrig, contrastEnh]);
    set(gca, 'XTickLabel', {'Original', 'Enhanced'});
    ylabel('Contrast (Std Dev)');
    title(sprintf('Contrast: %.1f → %.1f', contrastOrig, contrastEnh));
    grid on;

    subplot(3, 4, 12);
    [M, N, ~] = size(original);
    rowRange = round(M/3):round(2*M/3);
    colRange = round(N/3):round(2*N/3);

    roiOrig = original(rowRange, colRange, :);
    roiEnh = enhanced(rowRange, colRange, :);

    comparison = [roiOrig, uint8(255*ones(size(roiOrig,1), 5, size(roiOrig,3))), roiEnh];
    imshow(comparison);
    title('Zoomed Comparison (Orig | Enhanced)');

    sgtitle(sprintf('Homomorphic Filtering: γ_L=%.2f, γ_H=%.2f, c=%.2f, D_0=%d', ...
        params.gammaL, params.gammaH, params.c, params.D0), 'FontSize', 14, 'FontWeight', 'bold');
end
