%% MAIN 
clear; clc; close all;

%% 1. SETUP
addpath(genpath('.'));

%% 2. LOAD TEST IMAGES
fprintf('Loading test images...\n');

try
    imgGray = imread('test_images/gray1.jpeg');
    fprintf('Citra grayscale loaded\n');
catch
    imgGray = uint8(rand(256, 256) * 255);
    fprintf('Menggunakan citra random (cameraman.tif tidak ditemukan)\n');
end

try
    imgColor = imread('test_images/color1.jpeg');
    fprintf('Citra berwarna loaded\n');
catch
    imgColor = uint8(rand(256, 256, 3) * 255);
    fprintf('Menggunakan citra random (peppers.png tidak ditemukan)\n');
end

%% 3. DEFINISIKAN BERBAGAI MASK
fprintf('\nMembuat berbagai mask konvolusi...\n');

masks = struct();

% Average filter 3x3
masks.avg3 = createMask('average', 3);
fprintf('Average 3x3\n');

% Average filter 5x5
masks.avg5 = createMask('average', 5);
fprintf('Average 5x5\n');

% Gaussian filter 5x5
masks.gauss5 = createMask('gaussian', 5, 1.0);
fprintf('Gaussian 5x5 (sigma=1.0)\n');

% Gaussian filter 7x7
masks.gauss7 = createMask('gaussian', 7, 1.5);
fprintf('Gaussian 7x7 (sigma=1.5)\n');

% Sobel X
masks.sobelX = createMask('sobel_x', 3);
fprintf('Sobel X 3x3\n');

% Sobel Y
masks.sobelY = createMask('sobel_y', 3);
fprintf('Sobel Y 3x3\n');

% Laplacian
masks.laplacian = createMask('laplacian', 3);
fprintf('Laplacian 3x3\n');

% Mask dari soal (contoh pertama: 1/16 * [1 2 1; 2 4 2; 1 2 1])
masks.custom1 = (1/16) * [1 2 1; 2 4 2; 1 2 1];
fprintf('Custom mask 1 (dari soal)\n');

% Mask Laplacian dari soal
masks.custom2 = [0 -1 0; -1 4 -1; 0 -1 0];
fprintf('Custom mask 2 (Laplacian dari soal)\n');

%% 4. TEST PADA CITRA GRAYSCALE
fprintf('\n=== TEST 1: CITRA GRAYSCALE ===\n');

fprintf('\nTest dengan Gaussian 5x5...\n');
[customGray, matlabGray, diffGray, metricsGray] = compareResults(...
    imgGray, masks.gauss5, 'replicate');

figure('Name', 'Konvolusi Grayscale - Gaussian 5x5', 'Position', [100 100 1200 400]);
subplot(1,4,1); imshow(imgGray); title('Original');
subplot(1,4,2); imshow(customGray); title('Custom Convolution');
subplot(1,4,3); imshow(matlabGray); title('MATLAB Built-in');
subplot(1,4,4); imshow(uint8(diffGray*10)); title('Difference (10x)');

%% 5. TEST PADA CITRA BERWARNA
fprintf('\n=== TEST 2: CITRA BERWARNA ===\n');

fprintf('\nTest dengan Gaussian 7x7...\n');
[customColor, matlabColor, diffColor, metricsColor] = compareResults(...
    imgColor, masks.gauss7, 'replicate');

figure('Name', 'Konvolusi Color - Gaussian 7x7', 'Position', [100 100 1200 400]);
subplot(1,4,1); imshow(imgColor); title('Original');
subplot(1,4,2); imshow(customColor); title('Custom Convolution');
subplot(1,4,3); imshow(matlabColor); title('MATLAB Built-in');
subplot(1,4,4); imshow(uint8(sum(diffColor,3)*10)); title('Difference (10x)');

%% 6. TEST EDGE DETECTION
fprintf('\n=== TEST 3: EDGE DETECTION ===\n');

fprintf('\nSobel Edge Detection...\n');
sobelX = applyConvolution(imgGray, masks.sobelX, 'replicate');
sobelY = applyConvolution(imgGray, masks.sobelY, 'replicate');
sobelMagnitude = uint8(sqrt(double(sobelX).^2 + double(sobelY).^2));

figure('Name', 'Edge Detection - Sobel', 'Position', [100 100 1200 300]);
subplot(1,4,1); imshow(imgGray); title('Original');
subplot(1,4,2); imshow(sobelX); title('Sobel X');
subplot(1,4,3); imshow(sobelY); title('Sobel Y');
subplot(1,4,4); imshow(sobelMagnitude); title('Magnitude');

%% 7. TEST BERBAGAI UKURAN MASK
fprintf('\n=== TEST 4: BERBAGAI UKURAN MASK ===\n');

sizes = [3, 5, 7, 9];
figure('Name', 'Perbandingan Ukuran Mask', 'Position', [100 100 1200 800]);

for i = 1:length(sizes)
    n = sizes(i);
    mask = createMask('gaussian', n, n/5);
    result = applyConvolution(imgGray, mask, 'replicate');
    
    subplot(2, length(sizes), i);
    imshow(result);
    title(sprintf('Gaussian %dx%d', n, n));
    
    subplot(2, length(sizes), i + length(sizes));
    surf(mask);
    title(sprintf('Kernel %dx%d', n, n));
    axis tight;
end

%% 8. TEST PADDING METHODS
fprintf('\n=== TEST 5: METODE PADDING ===\n');

paddingMethods = {'zero', 'replicate', 'symmetric'};
mask = masks.gauss5;

figure('Name', 'Perbandingan Metode Padding', 'Position', [100 100 1200 400]);
subplot(1,4,1); imshow(imgGray); title('Original');

for i = 1:length(paddingMethods)
    result = applyConvolution(imgGray, mask, paddingMethods{i});
    subplot(1,4,i+1);
    imshow(result);
    title(['Padding: ' paddingMethods{i}]);
end

%% 9. PERFORMANCE TEST
fprintf('\n=== TEST 6: PERFORMANCE ===\n');

testSizes = [3, 5, 7, 9, 11];
times = zeros(length(testSizes), 2);

for i = 1:length(testSizes)
    n = testSizes(i);
    mask = createMask('gaussian', n, n/5);
    
    % Custom
    tic;
    applyConvolution(imgGray, mask, 'zero');
    times(i, 1) = toc;
    
    % MATLAB
    tic;
    imfilter(imgGray, mask, 0, 'conv');
    times(i, 2) = toc;
    
    fprintf('Mask %dx%d - Custom: %.4fs, MATLAB: %.4fs\n', ...
            n, n, times(i,1), times(i,2));
end

% Plot performance
figure('Name', 'Performance Comparison');
plot(testSizes, times(:,1), '-o', 'LineWidth', 2); hold on;
plot(testSizes, times(:,2), '-s', 'LineWidth', 2);
xlabel('Ukuran Mask (nxn)');
ylabel('Waktu (detik)');
title('Perbandingan Kecepatan Konvolusi');
legend('Custom Function', 'MATLAB Built-in');
grid on;