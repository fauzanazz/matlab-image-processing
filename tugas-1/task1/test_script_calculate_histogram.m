% load gambar grayscale
img_gray = imread('test_images/gray1.bmp');
hist_val = calculate_histogram(img_gray);
grayscale_histogram(hist_val, 'Grayscale Histogram');

% load gambar color
img_color = imread('test_images/color1.jpg');
color_histogram(img_color);