function grayscale_histogram(hist_values, title_text)
    figure;
    bar(0:255, hist_values, 'BarWidth', 1);
    xlabel('Intensity Value');
    ylabel('Frequency');
    title(title_text);
    xlim([0 255]);
end