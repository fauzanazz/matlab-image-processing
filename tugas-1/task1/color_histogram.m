function color_histogram(img)
    figure;
    
    subplot(3,1,1);
    hist_r = calculate_histogram(img(:,:,1));
    bar(0:255, hist_r, 'r', 'BarWidth', 1);
    title('Red Channel Histogram');
    xlim([0 255]);
    
    subplot(3,1,2);
    hist_g = calculate_histogram(img(:,:,2));
    bar(0:255, hist_g, 'g', 'BarWidth', 1);
    title('Green Channel Histogram');
    xlim([0 255]);
    
    subplot(3,1,3);
    hist_b = calculate_histogram(img(:,:,3));
    bar(0:255, hist_b, 'b', 'BarWidth', 1);
    title('Blue Channel Histogram');
    xlim([0 255]);
end