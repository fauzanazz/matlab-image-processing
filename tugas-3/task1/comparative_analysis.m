function comparative_analysis()
    clear all; close all; clc;
    
    fprintf('==============================================\n');
    fprintf('ANALISIS KOMPARATIF METODE SEGMENTASI\n');
    fprintf('==============================================\n\n');
    
    [filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp', 'Image Files'}, ...
        'Pilih Citra untuk Analisis');
    
    if isequal(filename,0)
        return;
    end
    
    img_original = imread(fullfile(pathname, filename));
    if size(img_original, 3) == 3
        img_gray = rgb2gray(img_original);
    else
        img_gray = img_original;
    end
    img_double = double(img_gray);
    img_filtered = gaussian_filter(img_double, 1.0);
    
    fprintf('Menjalankan deteksi tepi...\n');
    tic;
    edge_laplace = laplace_edge_detection(img_filtered);
    time_laplace = toc;
    
    tic;
    edge_log = log_edge_detection(img_filtered, 2.0);
    time_log = toc;
    
    tic;
    edge_sobel = sobel_edge_detection(img_filtered);
    time_sobel = toc;
    
    tic;
    edge_prewitt = prewitt_edge_detection(img_filtered);
    time_prewitt = toc;
    
    tic;
    edge_roberts = roberts_edge_detection(img_filtered);
    time_roberts = toc;
    
    tic;
    edge_canny = edge(mat2gray(img_filtered), 'Canny');
    time_canny = toc;
    
    fprintf('Menjalankan segmentasi...\n');
    seg_laplace = segment_from_edges(edge_laplace, img_original);
    seg_log = segment_from_edges(edge_log, img_original);
    seg_sobel = segment_from_edges(edge_sobel, img_original);
    seg_prewitt = segment_from_edges(edge_prewitt, img_original);
    seg_roberts = segment_from_edges(edge_roberts, img_original);
    seg_canny = segment_from_edges(edge_canny, img_original);
    
    fprintf('\nMenghitung metrik...\n');
    metrics = struct();
    [metrics.laplace.objects, ~] = count_objects(seg_laplace);
    [metrics.log.objects, ~] = count_objects(seg_log);
    [metrics.sobel.objects, ~] = count_objects(seg_sobel);
    [metrics.prewitt.objects, ~] = count_objects(seg_prewitt);
    [metrics.roberts.objects, ~] = count_objects(seg_roberts);
    [metrics.canny.objects, ~] = count_objects(seg_canny);
    
    total_pixels = numel(edge_laplace);
    metrics.laplace.edge_density = 100 * sum(edge_laplace(:)) / total_pixels;
    metrics.log.edge_density = 100 * sum(edge_log(:)) / total_pixels;
    metrics.sobel.edge_density = 100 * sum(edge_sobel(:)) / total_pixels;
    metrics.prewitt.edge_density = 100 * sum(edge_prewitt(:)) / total_pixels;
    metrics.roberts.edge_density = 100 * sum(edge_roberts(:)) / total_pixels;
    metrics.canny.edge_density = 100 * sum(edge_canny(:)) / total_pixels;
    
    metrics.laplace.time = time_laplace;
    metrics.log.time = time_log;
    metrics.sobel.time = time_sobel;
    metrics.prewitt.time = time_prewitt;
    metrics.roberts.time = time_roberts;
    metrics.canny.time = time_canny;
    display_results(metrics);
    
    create_comparison_figures(img_original, ...
        edge_laplace, edge_log, edge_sobel, edge_prewitt, edge_roberts, edge_canny, ...
        seg_laplace, seg_log, seg_sobel, seg_prewitt, seg_roberts, seg_canny);
    plot_metrics(metrics);
    
    fprintf('\n==============================================\n');
    fprintf('ANALISIS SELESAI\n');
    fprintf('==============================================\n');
end

function display_results(metrics)
    fprintf('\n==============================================\n');
    fprintf('HASIL ANALISIS KUANTITATIF\n');
    fprintf('==============================================\n\n');
    
    fprintf('%-12s | %8s | %12s | %10s\n', 'Method', 'Objects', 'Edge Density', 'Time (s)');
    fprintf('%s\n', repmat('-', 1, 55));
    
    methods = {'laplace', 'log', 'sobel', 'prewitt', 'roberts', 'canny'};
    method_names = {'Laplace', 'LoG', 'Sobel', 'Prewitt', 'Roberts', 'Canny'};
    
    for i = 1:length(methods)
        m = methods{i};
        fprintf('%-12s | %8d | %11.2f%% | %10.4f\n', ...
            method_names{i}, ...
            metrics.(m).objects, ...
            metrics.(m).edge_density, ...
            metrics.(m).time);
    end
    fprintf('\n');
end

function create_comparison_figures(img_original, ...
    edge_laplace, edge_log, edge_sobel, edge_prewitt, edge_roberts, edge_canny, ...
    seg_laplace, seg_log, seg_sobel, seg_prewitt, seg_roberts, seg_canny)
    figure('Name', 'Edge Detection Comparison', 'Position', [50 100 1500 800]);
    methods = {edge_laplace, edge_log, edge_sobel, edge_prewitt, edge_roberts, edge_canny};
    titles = {'Laplace', 'LoG', 'Sobel', 'Prewitt', 'Roberts', 'Canny'};
    
    for i = 1:6
        subplot(2, 3, i);
        imshow(methods{i});
        title(titles{i}, 'FontSize', 14, 'FontWeight', 'bold');
    end
    
    figure('Name', 'Segmentation Comparison', 'Position', [100 50 1500 800]);
    seg_methods = {seg_laplace, seg_log, seg_sobel, seg_prewitt, seg_roberts, seg_canny};
    
    for i = 1:6
        subplot(2, 3, i);
        imshow(seg_methods{i});
        title(['Segmentation - ' titles{i}], 'FontSize', 14, 'FontWeight', 'bold');
    end
    
    figure('Name', 'Best Methods Comparison', 'Position', [150 150 1400 400]);
    subplot(1,4,1);
    imshow(img_original);
    title('Original', 'FontSize', 14, 'FontWeight', 'bold');
    
    subplot(1,4,2);
    imshow(seg_canny);
    title('Canny Segmentation', 'FontSize', 14, 'FontWeight', 'bold');
    
    subplot(1,4,3);
    imshow(seg_sobel);
    title('Sobel Segmentation', 'FontSize', 14, 'FontWeight', 'bold');
    
    subplot(1,4,4);
    imshow(seg_log);
    title('LoG Segmentation', 'FontSize', 14, 'FontWeight', 'bold');
end

function plot_metrics(metrics)
    figure('Name', 'Quantitative Metrics', 'Position', [200 200 1200 400]);
    methods = {'laplace', 'log', 'sobel', 'prewitt', 'roberts', 'canny'};
    method_names = {'Laplace', 'LoG', 'Sobel', 'Prewitt', 'Roberts', 'Canny'};
    num_objects = zeros(1, 6);
    edge_density = zeros(1, 6);
    proc_time = zeros(1, 6);
    
    for i = 1:6
        m = methods{i};
        num_objects(i) = metrics.(m).objects;
        edge_density(i) = metrics.(m).edge_density;
        proc_time(i) = metrics.(m).time;
    end
    
    % Plot 1: Number of Objects
    subplot(1,3,1);
    bar(num_objects);
    set(gca, 'XTickLabel', method_names);
    ylabel('Number of Objects');
    title('Objects Detected', 'FontWeight', 'bold');
    grid on;
    
    % Plot 2: Edge Density
    subplot(1,3,2);
    bar(edge_density);
    set(gca, 'XTickLabel', method_names);
    ylabel('Edge Density (%)');
    title('Edge Pixel Density', 'FontWeight', 'bold');
    grid on;
    
    % Plot 3: Processing Time
    subplot(1,3,3);
    bar(proc_time * 1000);
    set(gca, 'XTickLabel', method_names);
    ylabel('Time (ms)');
    title('Processing Time', 'FontWeight', 'bold');
    grid on;
end