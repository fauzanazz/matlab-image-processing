%% MAIN_HIGHPASS 
clear; clc; close all;

%% 1. SETUP
fprintf('=== HIGH-PASS FILTERING ===\n');
fprintf('Frequency Domain: IHPF, GHPF, BHPF\n\n');
addpath(genpath('.'));

%% 2. LOAD TEST IMAGES
fprintf('Loading test images...\n');

try
    imgGray1 = imread('cat.jpg'); 
    if size(imgGray1, 3) == 3
        imgGray1 = rgb2gray(imgGray1);
    end
    fprintf('  ✓ Grayscale 1: cat.jpg\n');
catch
    imgGray1 = imread('cameraman.tif');
    fprintf('  ! Grayscale 1: cameraman.tif (fallback)\n');
end

try
    imgGray2 = imread('building.jpg'); 
    if size(imgGray2, 3) == 3
        imgGray2 = rgb2gray(imgGray2);
    end
    fprintf('Grayscale 2: building.jpg\n');
catch
    imgGray2 = imread('pout.tif');
    fprintf('Grayscale 2: pout.tif (fallback)\n');
end

try
    imgGray3 = imread('circuit.tif');
    fprintf('Grayscale 3: circuit.tif\n');
catch
    imgGray3 = imread('rice.png');
    fprintf('Grayscale 3: rice.png (fallback)\n');
end

try
    imgColor1 = imread('circuit_board.jpg'); % 
    fprintf('Color 1: circuit_board.jpg\n');
catch
    imgColor1 = imread('peppers.png');
    fprintf('Color 1: peppers.png (fallback)\n');
end

try
    imgColor2 = imread('autumn.tif');
    fprintf('Color 2: autumn.tif\n');
catch
    imgColor2 = uint8(rand(256,256,3)*255);
    fprintf('Color 2: random image (fallback)\n');
end

try
    imgColor3 = imread('peppers.png');
    fprintf('Color 3: peppers.png\n');
catch
    imgColor3 = uint8(rand(256,256,3)*255);
    fprintf('Color 3: random image (fallback)\n');
end

%% 3. TEST 1 - BASIC HIGH-PASS FILTERING (GRAYSCALE)
fprintf('\n=== TEST 1: BASIC HIGH-PASS FILTERING - GRAYSCALE ===\n');

cutoffFreqs = [20, 40, 60];

figure('Name', 'High-Pass Filtering - Grayscale', 'Position', [50 50 1400 900]);

subplot(4, 4, 1);
imshow(imgGray1); title('Original');

idx = 2;
for D0 = cutoffFreqs
    % IHPF
    filtered = frequencyHighPass(imgGray1, 'IHPF', D0);
    subplot(4, 4, idx);
    imshow(filtered);
    title(sprintf('IHPF D0=%d', D0));
    idx = idx + 1;
end

idx = 6;
for D0 = cutoffFreqs
    % GHPF
    filtered = frequencyHighPass(imgGray1, 'GHPF', D0);
    subplot(4, 4, idx);
    imshow(filtered);
    title(sprintf('GHPF D0=%d', D0));
    idx = idx + 1;
end

idx = 10;
for D0 = cutoffFreqs
    % BHPF
    filtered = frequencyHighPass(imgGray1, 'BHPF', D0, 2);
    subplot(4, 4, idx);
    imshow(filtered);
    title(sprintf('BHPF D0=%d n=2', D0));
    idx = idx + 1;
end

subplot(4, 4, 14);
[M, N] = size(imgGray1);
H_IHPF = createHighPassFilter(M, N, 'IHPF', 40);
H_GHPF = createHighPassFilter(M, N, 'GHPF', 40);
H_BHPF = createHighPassFilter(M, N, 'BHPF', 40, 2);
centerRow = round(M/2);
plot(H_IHPF(centerRow,:), 'b-', 'LineWidth', 2); hold on;
plot(H_GHPF(centerRow,:), 'r-', 'LineWidth', 2);
plot(H_BHPF(centerRow,:), 'g-', 'LineWidth', 2);
legend('IHPF', 'GHPF', 'BHPF');
title('Filter Cross-Sections');
xlabel('Frequency'); ylabel('H(u,v)');
grid on;

%% 4. TEST 2 - FREQUENCY SPECTRUM ANALYSIS
fprintf('\n=== TEST 2: FREQUENCY SPECTRUM ANALYSIS ===\n');

[filtered_IHPF, ~, spectrum_IHPF] = frequencyHighPass(imgGray1, 'IHPF', 40);
[filtered_GHPF, ~, spectrum_GHPF] = frequencyHighPass(imgGray1, 'GHPF', 40);
[filtered_BHPF, ~, spectrum_BHPF] = frequencyHighPass(imgGray1, 'BHPF', 40, 2);

figure('Name', 'Frequency Spectrum Analysis', 'Position', [50 50 1400 800]);

% Original
subplot(3, 5, 1);
imshow(imgGray1); title('Original Image');

subplot(3, 5, 2);
imshow(spectrum_IHPF.original, []); title('Original Spectrum');
colormap(gca, 'jet'); colorbar;

% IHPF
subplot(3, 5, 3);
imshow(spectrum_IHPF.filter, []); title('IHPF Filter');
colormap(gca, 'jet'); colorbar;

subplot(3, 5, 4);
imshow(spectrum_IHPF.filtered, []); title('Filtered Spectrum');
colormap(gca, 'jet'); colorbar;

subplot(3, 5, 5);
imshow(filtered_IHPF); title('IHPF Result');

% GHPF
subplot(3, 5, 8);
imshow(spectrum_GHPF.filter, []); title('GHPF Filter');
colormap(gca, 'jet'); colorbar;

subplot(3, 5, 9);
imshow(spectrum_GHPF.filtered, []); title('Filtered Spectrum');
colormap(gca, 'jet'); colorbar;

subplot(3, 5, 10);
imshow(filtered_GHPF); title('GHPF Result');

% BHPF
subplot(3, 5, 13);
imshow(spectrum_BHPF.filter, []); title('BHPF Filter');
colormap(gca, 'jet'); colorbar;

subplot(3, 5, 14);
imshow(spectrum_BHPF.filtered, []); title('Filtered Spectrum');
colormap(gca, 'jet'); colorbar;

subplot(3, 5, 15);
imshow(filtered_BHPF); title('BHPF Result');

%% 5. TEST 3 - EDGE DETECTION WITH HPF
fprintf('\n=== TEST 3: EDGE DETECTION USING HPF ===\n');

figure('Name', 'Edge Detection - HPF', 'Position', [50 50 1400 600]);

subplot(2, 4, 1);
imshow(imgGray2); title('Original');

methods = {'IHPF', 'GHPF', 'BHPF'};
D0 = 30;

for i = 1:length(methods)
    [edges, magnitude, ~] = edgeDetectionFrequency(imgGray2, methods{i}, D0, 0.1);
    
    subplot(2, 4, i+1);
    imshow(magnitude, []); 
    title(sprintf('%s Magnitude', methods{i}));
    
    subplot(2, 4, i+5);
    imshow(edges); 
    title(sprintf('%s Edges', methods{i}));
end

subplot(2, 4, 8);
edges_canny = edge(imgGray2, 'canny');
imshow(edges_canny);
title('Canny (Spatial)');

%% 6. TEST 4 - IMAGE SHARPENING
fprintf('\n=== TEST 4: IMAGE SHARPENING ===\n');

blurred = imgaussfilt(imgGray3, 2);

figure('Name', 'Image Sharpening', 'Position', [50 50 1400 800]);

subplot(3, 4, 1);
imshow(imgGray3); title('Original');

subplot(3, 4, 2);
imshow(blurred); title('Blurred (sigma=2)');

idx = 3;
sharpenMethods = {'IHPF', 'GHPF', 'BHPF', 'unsharp'};
cutoffs = [30, 30, 30, 40];

for i = 1:length(sharpenMethods)
    [sharpened, mask] = sharpenImage(blurred, sharpenMethods{i}, cutoffs(i), 1.0, 0.7);
    
    subplot(3, 4, idx);
    imshow(sharpened);
    title(sprintf('%s Sharpened', sharpenMethods{i}));
    idx = idx + 1;
    
    subplot(3, 4, idx);
    imshow(mask, []);
    title(sprintf('%s Mask', sharpenMethods{i}));
    idx = idx + 1;
end

subplot(3, 4, 11);
[boosted, ~] = sharpenImage(blurred, 'GHPF', 30, 1.5, 1.0);
imshow(boosted);
title('High-Boost (k=1.5)');

subplot(3, 4, 12);
diff = double(boosted) - double(blurred);
imshow(diff, []);
title('Enhancement Difference');
colormap(gca, 'jet'); colorbar;

%% 7. TEST 5 - COLOR IMAGE HPF
fprintf('\n=== TEST 5: COLOR IMAGE HIGH-PASS FILTERING ===\n');

figure('Name', 'Color Image HPF', 'Position', [50 50 1400 800]);

subplot(3, 4, 1);
imshow(imgColor1); title('Original Color');

D0_values = [20, 40, 60];
idx = 2;

for D0 = D0_values
    % GHPF on color
    filtered = frequencyHighPass(imgColor1, 'GHPF', D0);
    subplot(3, 4, idx);
    imshow(filtered);
    title(sprintf('GHPF D0=%d', D0));
    idx = idx + 1;
end

idx = 5;
for D0 = D0_values
    % BHPF on color
    filtered = frequencyHighPass(imgColor1, 'BHPF', D0, 2);
    subplot(3, 4, idx);
    imshow(filtered);
    title(sprintf('BHPF D0=%d', D0));
    idx = idx + 1;
end

% Color edge detection
subplot(3, 4, 9);
grayVersion = rgb2gray(imgColor1);
edges = edgeDetectionFrequency(grayVersion, 'GHPF', 30, 0.12);
imshow(edges);
title('Edge Detection');

% Per-channel HPF
subplot(3, 4, 10);
R = frequencyHighPass(imgColor1(:,:,1), 'GHPF', 40);
imshow(R); title('Red Channel HPF');

subplot(3, 4, 11);
G = frequencyHighPass(imgColor1(:,:,2), 'GHPF', 40);
imshow(G); title('Green Channel HPF');

subplot(3, 4, 12);
B = frequencyHighPass(imgColor1(:,:,3), 'GHPF', 40);
imshow(B); title('Blue Channel HPF');

%% 8. TEST 6 - COMPREHENSIVE COMPARISON
fprintf('\n=== TEST 6: COMPREHENSIVE COMPARISON ===\n');

cutoffFreqsTest = [20, 40, 60];
results = compareFilters(imgGray1, cutoffFreqsTest, true);

%% 9. TEST 7 - FILTER VISUALIZATION 3D
fprintf('\n=== TEST 7: 3D FILTER VISUALIZATION ===\n');

[M, N] = size(imgGray1);
D0 = 40;

% Create filters
H_IHPF = createHighPassFilter(M, N, 'IHPF', D0);
H_GHPF = createHighPassFilter(M, N, 'GHPF', D0);
H_BHPF = createHighPassFilter(M, N, 'BHPF', D0, 2);

figure('Name', '3D Filter Visualization', 'Position', [50 50 1400 400]);

% IHPF 3D
subplot(1, 3, 1);
[X, Y] = meshgrid(1:10:N, 1:10:M);
Z = H_IHPF(1:10:M, 1:10:N);
surf(X, Y, Z, 'EdgeColor', 'none');
title('IHPF 3D View');
xlabel('u'); ylabel('v'); zlabel('H(u,v)');
colormap(gca, 'jet'); colorbar;
view(45, 30);

% GHPF 3D
subplot(1, 3, 2);
Z = H_GHPF(1:10:M, 1:10:N);
surf(X, Y, Z, 'EdgeColor', 'none');
title('GHPF 3D View');
xlabel('u'); ylabel('v'); zlabel('H(u,v)');
colormap(gca, 'jet'); colorbar;
view(45, 30);

% BHPF 3D
subplot(1, 3, 3);
Z = H_BHPF(1:10:M, 1:10:N);
surf(X, Y, Z, 'EdgeColor', 'none');
title('BHPF 3D View');
xlabel('u'); ylabel('v'); zlabel('H(u,v)');
colormap(gca, 'jet'); colorbar;
view(45, 30);

%% 10. TEST 8 - PARAMETER SENSITIVITY
fprintf('\n=== TEST 8: PARAMETER SENSITIVITY ===\n');

% Effect of cutoff frequency
cutoffRange = 10:10:100;
edge_ratios_IHPF = zeros(size(cutoffRange));
edge_ratios_GHPF = zeros(size(cutoffRange));
edge_ratios_BHPF = zeros(size(cutoffRange));
contrast_IHPF = zeros(size(cutoffRange));
contrast_GHPF = zeros(size(cutoffRange));
contrast_BHPF = zeros(size(cutoffRange));

fprintf('Testing cutoff frequencies: ');
for i = 1:length(cutoffRange)
    D0 = cutoffRange(i);
    fprintf('%d ', D0);
    
    % IHPF
    filtered = frequencyHighPass(imgGray1, 'IHPF', D0);
    edges = edge(filtered, 'canny');
    edge_ratios_IHPF(i) = sum(edges(:)) / numel(edges);
    contrast_IHPF(i) = std(double(filtered(:)));
    
    % GHPF
    filtered = frequencyHighPass(imgGray1, 'GHPF', D0);
    edges = edge(filtered, 'canny');
    edge_ratios_GHPF(i) = sum(edges(:)) / numel(edges);
    contrast_GHPF(i) = std(double(filtered(:)));
    
    % BHPF
    filtered = frequencyHighPass(imgGray1, 'BHPF', D0, 2);
    edges = edge(filtered, 'canny');
    edge_ratios_BHPF(i) = sum(edges(:)) / numel(edges);
    contrast_BHPF(i) = std(double(filtered(:)));
end
fprintf('\n');

figure('Name', 'Parameter Sensitivity', 'Position', [50 50 1200 500]);

subplot(1, 2, 1);
plot(cutoffRange, edge_ratios_IHPF * 100, 'b-o', 'LineWidth', 2); hold on;
plot(cutoffRange, edge_ratios_GHPF * 100, 'r-s', 'LineWidth', 2);
plot(cutoffRange, edge_ratios_BHPF * 100, 'g-d', 'LineWidth', 2);
xlabel('Cutoff Frequency D0');
ylabel('Edge Ratio (%)');
title('Edge Detection vs Cutoff Frequency');
legend('IHPF', 'GHPF', 'BHPF');
grid on;

subplot(1, 2, 2);
plot(cutoffRange, contrast_IHPF, 'b-o', 'LineWidth', 2); hold on;
plot(cutoffRange, contrast_GHPF, 'r-s', 'LineWidth', 2);
plot(cutoffRange, contrast_BHPF, 'g-d', 'LineWidth', 2);
xlabel('Cutoff Frequency D0');
ylabel('Output Contrast (Std Dev)');
title('Output Contrast vs Cutoff Frequency');
legend('IHPF', 'GHPF', 'BHPF');
grid on;

%% 11. TEST 9 - BUTTERWORTH ORDER EFFECT
fprintf('\n=== TEST 9: BUTTERWORTH ORDER EFFECT ===\n');

orders = [1, 2, 4, 8];
D0 = 40;

figure('Name', 'Butterworth Order Effect', 'Position', [50 50 1400 700]);

subplot(2, length(orders)+1, 1);
imshow(imgGray1); title('Original');

for i = 1:length(orders)
    n = orders(i);

    [M, N] = size(imgGray1);
    H = createHighPassFilter(M, N, 'BHPF', D0, n);
    
    filtered = frequencyHighPass(imgGray1, 'BHPF', D0, n);
    
    subplot(2, length(orders)+1, i+1);
    imshow(H, []); 
    title(sprintf('BHPF n=%d', n));
    colorbar;
    
    subplot(2, length(orders)+1, length(orders)+1 + i+1);
    imshow(filtered);
    title(sprintf('Result n=%d', n));
end

subplot(2, length(orders)+1, length(orders)+1);
hold on;
colors = {'b', 'r', 'g', 'm'};
for i = 1:length(orders)
    H = createHighPassFilter(M, N, 'BHPF', D0, orders(i));
    centerRow = round(M/2);
    plot(H(centerRow, :), colors{i}, 'LineWidth', 2);
end
legend(arrayfun(@(x) sprintf('n=%d', x), orders, 'UniformOutput', false));
xlabel('Frequency'); ylabel('H(u,v)');
title('Filter Profiles');
grid on;

%% 12. TEST 10 - FREQUENCY ANALYSIS
fprintf('\n=== TEST 10: DETAILED FREQUENCY ANALYSIS ===\n');

results_analysis = analyzeFrequency(imgGray1, true);

fprintf('Frequency Analysis Results:\n');
fprintf('  DC Magnitude: %.2f\n', results_analysis.DCMagnitude);
fprintf('  Total Energy: %.2e\n', results_analysis.totalEnergy);
fprintf('  Low Freq Energy: %.2e\n', results_analysis.lowFreqEnergy);
fprintf('  High Freq Energy: %.2e\n', results_analysis.highFreqEnergy);
fprintf('  Energy Ratio (Low/High): %.2f\n', results_analysis.energyRatio);

%% 13. TEST 11 - BATCH PROCESSING ALL IMAGES
fprintf('\n=== TEST 11: BATCH PROCESSING ===\n');

grayImages = {imgGray1, imgGray2, imgGray3};
colorImages = {imgColor1, imgColor2, imgColor3};
D0 = 40;

fprintf('Processing grayscale images with GHPF (D0=%d)...\n', D0);
figure('Name', 'Batch Processing - Grayscale', 'Position', [50 50 1400 400]);
for i = 1:length(grayImages)
    subplot(2, length(grayImages), i);
    imshow(grayImages{i});
    title(sprintf('Original %d', i));
    
    subplot(2, length(grayImages), i + length(grayImages));
    filtered = frequencyHighPass(grayImages{i}, 'GHPF', D0);
    imshow(filtered);
    title(sprintf('GHPF Filtered %d', i));
    
    fprintf('  Image %d: processed\n', i);
end

fprintf('Processing color images with GHPF (D0=%d)...\n', D0);
figure('Name', 'Batch Processing - Color', 'Position', [50 50 1400 400]);
for i = 1:length(colorImages)
    subplot(2, length(colorImages), i);
    imshow(colorImages{i});
    title(sprintf('Original %d', i));
    
    subplot(2, length(colorImages), i + length(colorImages));
    filtered = frequencyHighPass(colorImages{i}, 'GHPF', D0);
    imshow(filtered);
    title(sprintf('GHPF Filtered %d', i));
    
    fprintf('  Image %d: processed\n', i);
end

%% 14. TEST 12 - RINGING COMPARISON
fprintf('\n=== TEST 12: RINGING ARTIFACT ANALYSIS ===\n');

% IHPF has ringing, GHPF doesn't
figure('Name', 'Ringing Artifacts', 'Position', [50 50 1400 600]);

D0 = 50;

subplot(2, 4, 1);
imshow(imgGray3); title('Original');

% IHPF - has ringing
[filtered_IHPF, ~, spectrum_IHPF] = frequencyHighPass(imgGray3, 'IHPF', D0);
subplot(2, 4, 2);
imshow(filtered_IHPF); title('IHPF (Ringing)');

subplot(2, 4, 3);
imshow(spectrum_IHPF.filter, []); title('IHPF Filter');
colorbar;

% GHPF - smooth, no ringing
[filtered_GHPF, ~, spectrum_GHPF] = frequencyHighPass(imgGray3, 'GHPF', D0);
subplot(2, 4, 6);
imshow(filtered_GHPF); title('GHPF (No Ringing)');

subplot(2, 4, 7);
imshow(spectrum_GHPF.filter, []); title('GHPF Filter');
colorbar;

% Show difference
subplot(2, 4, 4);
diff = double(filtered_IHPF) - double(filtered_GHPF);
imshow(diff, []);
title('Difference (IHPF - GHPF)');
colormap(gca, 'jet'); colorbar;

% Line profiles
subplot(2, 4, 8);
centerRow = round(size(imgGray3, 1) / 2);
plot(double(filtered_IHPF(centerRow, :)), 'b-', 'LineWidth', 2); hold on;
plot(double(filtered_GHPF(centerRow, :)), 'r-', 'LineWidth', 2);
legend('IHPF', 'GHPF');
xlabel('Column'); ylabel('Intensity');
title('Cross-Section Comparison');
grid on;