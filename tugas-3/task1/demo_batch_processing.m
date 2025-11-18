clear all; close all; clc;

fprintf('==============================================\n');
fprintf('DEMO BATCH PROCESSING SEGMENTASI OBJEK\n');
fprintf('==============================================\n\n');

%% Choose folder
folder_path = uigetdir('', 'Pilih Folder yang Berisi Citra');

if isequal(folder_path, 0)
    disp('User cancelled folder selection');
    return;
end

image_files = dir(fullfile(folder_path, '*.jpg'));
image_files = [image_files; dir(fullfile(folder_path, '*.png'))];
image_files = [image_files; dir(fullfile(folder_path, '*.bmp'))];

num_images = length(image_files);
fprintf('Ditemukan %d gambar dalam folder.\n\n', num_images);

if num_images == 0
    fprintf('Tidak ada gambar yang ditemukan!\n');
    return;
end

%% Buat folder output
output_dir = fullfile(folder_path, 'batch_results');
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

%% Process citra
results_table = cell(num_images, 7);
results_table{1,1} = 'Filename';
results_table{1,2} = 'Laplace';
results_table{1,3} = 'LoG';
results_table{1,4} = 'Sobel';
results_table{1,5} = 'Prewitt';
results_table{1,6} = 'Roberts';
results_table{1,7} = 'Canny';

for idx = 1:num_images
    fprintf('Processing [%d/%d]: %s\n', idx, num_images, image_files(idx).name);
    
    img_path = fullfile(folder_path, image_files(idx).name);
    img_original = imread(img_path);
    
    if size(img_original, 3) == 3
        img_gray = rgb2gray(img_original);
    else
        img_gray = img_original;
    end
    img_double = double(img_gray);
    img_filtered = gaussian_filter(img_double, 1.0);
    try
        edge_laplace = laplace_edge_detection(img_filtered);
        edge_log = log_edge_detection(img_filtered, 2.0);
        edge_sobel = sobel_edge_detection(img_filtered);
        edge_prewitt = prewitt_edge_detection(img_filtered);
        edge_roberts = roberts_edge_detection(img_filtered);
        
        img_norm = mat2gray(img_filtered);
        edge_canny = edge(img_norm, 'Canny');
        
        seg_laplace = segment_from_edges(edge_laplace, img_original);
        seg_log = segment_from_edges(edge_log, img_original);
        seg_sobel = segment_from_edges(edge_sobel, img_original);
        seg_prewitt = segment_from_edges(edge_prewitt, img_original);
        seg_roberts = segment_from_edges(edge_roberts, img_original);
        seg_canny = segment_from_edges(edge_canny, img_original);
        
        [num_laplace, ~] = count_objects(seg_laplace);
        [num_log, ~] = count_objects(seg_log);
        [num_sobel, ~] = count_objects(seg_sobel);
        [num_prewitt, ~] = count_objects(seg_prewitt);
        [num_roberts, ~] = count_objects(seg_roberts);
        [num_canny, ~] = count_objects(seg_canny);
        
        [~, name, ~] = fileparts(image_files(idx).name);
        
        imwrite(edge_canny, fullfile(output_dir, sprintf('%s_edge_canny.png', name)));
        imwrite(edge_sobel, fullfile(output_dir, sprintf('%s_edge_sobel.png', name)));
        
        imwrite(seg_canny, fullfile(output_dir, sprintf('%s_seg_canny.png', name)));
        imwrite(seg_sobel, fullfile(output_dir, sprintf('%s_seg_sobel.png', name)));
        
        results_table{idx+1, 1} = image_files(idx).name;
        results_table{idx+1, 2} = num_laplace;
        results_table{idx+1, 3} = num_log;
        results_table{idx+1, 4} = num_sobel;
        results_table{idx+1, 5} = num_prewitt;
        results_table{idx+1, 6} = num_roberts;
        results_table{idx+1, 7} = num_canny;
        
        fprintf('  -> Objek terdeteksi (Canny): %d\n', num_canny);
        
    catch ME
        fprintf('  -> ERROR: %s\n', ME.message);
        results_table{idx+1, 1} = image_files(idx).name;
        for j = 2:7
            results_table{idx+1, j} = 'ERROR';
        end
    end
end

fprintf('\nMenyimpan hasil ke file...\n');

fid = fopen(fullfile(output_dir, 'segmentation_results.csv'), 'w');
for i = 1:size(results_table, 1)
    if i == 1
        fprintf(fid, '%s,%s,%s,%s,%s,%s,%s\n', results_table{i,:});
    else
        fprintf(fid, '%s,%d,%d,%d,%d,%d,%d\n', results_table{i,:});
    end
end
fclose(fid);

fprintf('\n==============================================\n');
fprintf('BATCH PROCESSING SELESAI\n');
fprintf('Hasil tersimpan di: %s\n', output_dir);
fprintf('==============================================\n');

fprintf('\nSUMMARY HASIL:\n');
fprintf('%-30s | %8s | %8s | %8s\n', 'Filename', 'Sobel', 'Canny', 'LoG');
fprintf('%s\n', repmat('-', 1, 65));
for i = 2:size(results_table, 1)
    fprintf('%-30s | %8d | %8d | %8d\n', ...
        results_table{i,1}, results_table{i,4}, results_table{i,7}, results_table{i,3});
end