clear all; close all; clc;

%% ========== KONFIGURASI ==========
fprintf('==============================================\n');
fprintf('PROGRAM SEGMENTASI OBJEK BERBASIS DETEKSI TEPI\n');
fprintf('==============================================\n\n');

% Pilih citra input
[filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp;*.tif', 'Image Files (*.jpg,*.png,*.bmp,*.tif)'}, ...
    'Pilih Citra Input');

if isequal(filename,0)
    disp('User cancelled file selection');
    return;
end

img_path = fullfile(pathname, filename);
img_original = imread(img_path);

if size(img_original, 3) == 3
    img_gray = rgb2gray(img_original);
else
    img_gray = img_original;
end

img_double = double(img_gray);

%% ========== PREPROCESSING ==========
% Noise reduction dengan Gaussian filter
sigma_noise = 1.0;
img_filtered = gaussian_filter(img_double, sigma_noise);

%% ========== DETEKSI TEPI ==========
% 1. Laplace
fprintf('  - Laplace Edge Detection\n');
edge_laplace = laplace_edge_detection(img_filtered);

% 2. LoG (Laplacian of Gaussian)
fprintf('  - LoG Edge Detection\n');
sigma_log = 2.0;
edge_log = log_edge_detection(img_filtered, sigma_log);

% 3. Sobel
fprintf('  - Sobel Edge Detection\n');
edge_sobel = sobel_edge_detection(img_filtered);

% 4. Prewitt
fprintf('  - Prewitt Edge Detection\n');
edge_prewitt = prewitt_edge_detection(img_filtered);

% 5. Roberts
fprintf('  - Roberts Edge Detection\n');
edge_roberts = roberts_edge_detection(img_filtered);

% 6. Canny 
fprintf('  - Canny Edge Detection\n');
% Normalisasi untuk Canny
img_norm = mat2gray(img_filtered);
edge_canny = edge(img_norm, 'Canny');

%% ========== SEGMENTASI OBJEK ==========
fprintf('  - Segmentasi dari Laplace\n');
seg_laplace = segment_from_edges(edge_laplace, img_original);

fprintf('  - Segmentasi dari LoG\n');
seg_log = segment_from_edges(edge_log, img_original);

fprintf('  - Segmentasi dari Sobel\n');
seg_sobel = segment_from_edges(edge_sobel, img_original);

fprintf('  - Segmentasi dari Prewitt\n');
seg_prewitt = segment_from_edges(edge_prewitt, img_original);

fprintf('  - Segmentasi dari Roberts\n');
seg_roberts = segment_from_edges(edge_roberts, img_original);

fprintf('  - Segmentasi dari Canny\n');
seg_canny = segment_from_edges(edge_canny, img_original);

%% ========== VISUALISASI HASIL ==========
% Figure 1: Citra Original dan Hasil Deteksi Tepi
figure('Name', 'Edge Detection Results', 'Position', [100 100 1400 900]);

subplot(3,3,1);
imshow(img_original);
title('Original Image', 'FontSize', 12, 'FontWeight', 'bold');

subplot(3,3,2);
imshow(edge_laplace);
title('Laplace Edge', 'FontSize', 12);

subplot(3,3,3);
imshow(edge_log);
title('LoG Edge', 'FontSize', 12);

subplot(3,3,4);
imshow(edge_sobel);
title('Sobel Edge', 'FontSize', 12);

subplot(3,3,5);
imshow(edge_prewitt);
title('Prewitt Edge', 'FontSize', 12);

subplot(3,3,6);
imshow(edge_roberts);
title('Roberts Edge', 'FontSize', 12);

subplot(3,3,7);
imshow(edge_canny);
title('Canny Edge', 'FontSize', 12);

% Figure 2: Hasil Segmentasi
figure('Name', 'Segmentation Results', 'Position', [150 50 1400 900]);

subplot(3,3,1);
imshow(img_original);
title('Original Image', 'FontSize', 12, 'FontWeight', 'bold');

subplot(3,3,2);
imshow(seg_laplace);
title('Segmentation (Laplace)', 'FontSize', 12);

subplot(3,3,3);
imshow(seg_log);
title('Segmentation (LoG)', 'FontSize', 12);

subplot(3,3,4);
imshow(seg_sobel);
title('Segmentation (Sobel)', 'FontSize', 12);

subplot(3,3,5);
imshow(seg_prewitt);
title('Segmentation (Prewitt)', 'FontSize', 12);

subplot(3,3,6);
imshow(seg_roberts);
title('Segmentation (Roberts)', 'FontSize', 12);

subplot(3,3,7);
imshow(seg_canny);
title('Segmentation (Canny)', 'FontSize', 12);

% Figure 3: Perbandingan Detail
figure('Name', 'Detailed Comparison', 'Position', [200 100 1200 400]);

subplot(1,3,1);
imshow(img_original);
title('Original Image', 'FontSize', 14, 'FontWeight', 'bold');

subplot(1,3,2);
imshow(edge_canny);
title('Edge Detection (Canny)', 'FontSize', 14, 'FontWeight', 'bold');

subplot(1,3,3);
imshow(seg_canny);
title('Object Segmentation', 'FontSize', 14, 'FontWeight', 'bold');

%% ========== EVALUASI HASIL ==========
fprintf('\n==============================================\n');
fprintf('EVALUASI HASIL SEGMENTASI\n');
fprintf('==============================================\n');

[num_objects_laplace, ~] = count_objects(seg_laplace);
[num_objects_log, ~] = count_objects(seg_log);
[num_objects_sobel, ~] = count_objects(seg_sobel);
[num_objects_prewitt, ~] = count_objects(seg_prewitt);
[num_objects_roberts, ~] = count_objects(seg_roberts);
[num_objects_canny, ~] = count_objects(seg_canny);

fprintf('Jumlah objek terdeteksi:\n');
fprintf('  - Laplace  : %d objek\n', num_objects_laplace);
fprintf('  - LoG      : %d objek\n', num_objects_log);
fprintf('  - Sobel    : %d objek\n', num_objects_sobel);
fprintf('  - Prewitt  : %d objek\n', num_objects_prewitt);
fprintf('  - Roberts  : %d objek\n', num_objects_roberts);
fprintf('  - Canny    : %d objek\n', num_objects_canny);

%% ========== SIMPAN HASIL ==========
response = input('Simpan hasil segmentasi? (y/n): ', 's');

if strcmpi(response, 'y')
    output_dir = 'segmentation_results';
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end
    
    [~, name, ~] = fileparts(filename);
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    
    imwrite(edge_laplace, fullfile(output_dir, sprintf('%s_edge_laplace_%s.png', name, timestamp)));
    imwrite(edge_log, fullfile(output_dir, sprintf('%s_edge_log_%s.png', name, timestamp)));
    imwrite(edge_sobel, fullfile(output_dir, sprintf('%s_edge_sobel_%s.png', name, timestamp)));
    imwrite(edge_prewitt, fullfile(output_dir, sprintf('%s_edge_prewitt_%s.png', name, timestamp)));
    imwrite(edge_roberts, fullfile(output_dir, sprintf('%s_edge_roberts_%s.png', name, timestamp)));
    imwrite(edge_canny, fullfile(output_dir, sprintf('%s_edge_canny_%s.png', name, timestamp)));
    
    imwrite(seg_laplace, fullfile(output_dir, sprintf('%s_seg_laplace_%s.png', name, timestamp)));
    imwrite(seg_log, fullfile(output_dir, sprintf('%s_seg_log_%s.png', name, timestamp)));
    imwrite(seg_sobel, fullfile(output_dir, sprintf('%s_seg_sobel_%s.png', name, timestamp)));
    imwrite(seg_prewitt, fullfile(output_dir, sprintf('%s_seg_prewitt_%s.png', name, timestamp)));
    imwrite(seg_roberts, fullfile(output_dir, sprintf('%s_seg_roberts_%s.png', name, timestamp)));
    imwrite(seg_canny, fullfile(output_dir, sprintf('%s_seg_canny_%s.png', name, timestamp)));
    
    fprintf('Hasil tersimpan di folder: %s\n', output_dir);
end

fprintf('\n==============================================\n');
fprintf('PROGRAM SELESAI\n');
fprintf('==============================================\n');