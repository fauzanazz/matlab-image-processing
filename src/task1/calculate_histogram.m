function hist_values = calculate_histogram(img)
    if size(img, 3) == 3
        img = rgb2gray(img);
    end
    
    hist_values = zeros(1, 256);
    
    for i = 1:size(img, 1)
        for j = 1:size(img, 2)
            intensity = double(img(i, j)) + 1;
            hist_values(intensity) = hist_values(intensity) + 1;
        end
    end
end