%% MAIN_BRIGHTENING 
clear; clc; close all;

%% 1. SETUP
fprintf('=== HOMOMORPHIC FILTERING - IMAGE BRIGHTENING ===\n');
fprintf('Memisahkan komponen iluminasi dan reflektansi\n');
fprintf('untuk mencerahkan citra gelap\n\n');

addpath(genpath('.'));

%% 2. LOAD TEST IMAGES
fprintf('Loading test images...\n');

try
    imgTunnel = imread('test_images/dark_tunnel.jpg');
    if size(imgTunnel, 3) == 3
        imgTunnel = rgb2gray(imgTunnel);
    end
    fprintf('  ✓ Dark tunnel image loaded\n');
catch
    imgTunnel = imread('pout.tif');
    fprintf('  ! Using fallback image: pout.tif\n');
end

try
    imgFlower = imread('test_images/dark_flower.jpg');
    fprintf('  ✓ Dark flower image loaded\n');
catch
    imgFlower = imread('peppers.png');
    fprintf('  ! Using fallback image: peppers.png\n');
end

try
    imgExtra1 = imread('cameraman.tif');
    fprintf('  ✓ Extra test image 1 loaded\n');
catch
    imgExtra1 = uint8(rand(256,256)*255);
    fprintf('  ! Using random image 1\n');
end

try
    imgExtra2 = imread('autumn.tif');
    fprintf('  ✓ Extra test image 2 loaded (color)\n');
catch
    imgExtra2 = uint8(rand(256,256,3)*255);
    fprintf('  ! Using random image 2\n');
end

%% 3. TEST 1
fprintf('\n=== TEST 1: DARK TUNNEL (GRAYSCALE) ===\n');
fprintf('Applying homomorphic filter...\n');
fprintf('  Parameters: γL=0.5, γH=2.0, c=1.0, D0=30\n');
[enhancedTunnel, spectrumTunnel] = homomorphicFilter(imgTunnel, 0.5, 2.0, 1.0, 30);

params1.gammaL = 0.5;
params1.gammaH = 2.0;
params1.c = 1.0;
params1.D0 = 30;
visualizeHomomorphic(imgTunnel, enhancedTunnel, spectrumTunnel, params1);

figure('Name', 'Contoh 1: Dark Tunnel (Input vs Output)', 'Position', [100 100 1200 500]);
subplot(1, 2, 1);
imshow(imgTunnel);
title('Input Image (Dark Tunnel)');

subplot(1, 2, 2);
imshow(enhancedTunnel);
title('Filtered Image (Brightened)');

sgtitle('Homomorphic Filtering: Dark Tunnel Enhancement', 'FontSize', 14, 'FontWeight', 'bold');

%% 4. TEST 2 
fprintf('\n=== TEST 2: DARK FLOWER (COLOR IMAGE) ===\n');

fprintf('Applying homomorphic filter to color image...\n');
fprintf('  Parameters: γL=0.5, γH=2.0, c=1.0, D0=30\n');
[enhancedFlower, spectrumFlower] = homomorphicFilter(imgFlower, 0.5, 2.0, 1.0, 30);

params2.gammaL = 0.5;
params2.gammaH = 2.0;
params2.c = 1.0;
params2.D0 = 30;
visualizeHomomorphic(imgFlower, enhancedFlower, spectrumFlower, params2);

figure('Name', 'Contoh 2: Dark Flower (Input: kiri, Filtered: kanan)', 'Position', [100 100 1000 500]);
comparison = [imgFlower, uint8(255*ones(size(imgFlower,1), 10, 3)), enhancedFlower];
imshow(comparison);
title('Left: Input (Dark Flower) | Right: Filtered (Brightened)', 'FontSize', 12);

%% 5. TEST 3 
fprintf('\n=== TEST 3: PARAMETER COMPARISON ===\n');

testParams = [
    struct('gammaL', 0.3, 'gammaH', 1.5, 'c', 1.0, 'D0', 30, 'name', 'Mild Enhancement'),
    struct('gammaL', 0.5, 'gammaH', 2.0, 'c', 1.0, 'D0', 30, 'name', 'Moderate Enhancement'),
    struct('gammaL', 0.7, 'gammaH', 2.5, 'c', 1.5, 'D0', 40, 'name', 'Strong Enhancement'),
    struct('gammaL', 0.4, 'gammaH', 2.0, 'c', 0.5, 'D0', 50, 'name', 'Wide Filter'),
    struct('gammaL', 0.5, 'gammaH', 2.0, 'c', 2.0, 'D0', 20, 'name', 'Narrow Filter')
];

results = compareEnhancement(imgTunnel, testParams);

figure('Name', 'Parameter Comparison', 'Position', [50 50 1400 800]);

subplot(2, 3, 1);
imshow(imgTunnel);
title('Original');

for i = 1:length(results)
    subplot(2, 3, i+1);
    imshow(results(i).enhanced);
    title(sprintf('%s\nγL=%.1f, γH=%.1f\nMean: %.1f', ...
        results(i).name, results(i).params.gammaL, results(i).params.gammaH, ...
        results(i).metrics.meanBrightnessEnh));
end

sgtitle('Parameter Comparison for Dark Tunnel Image', 'FontSize', 14, 'FontWeight', 'bold');

%% 6. TEST 4 
fprintf('\n=== TEST 4: METRICS ANALYSIS ===\n');

figure('Name', 'Enhancement Metrics', 'Position', [50 50 1400 600]);

subplot(2, 4, 1);
brightness = arrayfun(@(x) x.metrics.meanBrightnessEnh, results);
bar(brightness);
set(gca, 'XTickLabel', 1:length(results));
ylabel('Mean Brightness');
title('Brightness After Enhancement');
grid on;

subplot(2, 4, 2);
ratios = arrayfun(@(x) x.metrics.brightnessRatio, results);
bar(ratios);
set(gca, 'XTickLabel', 1:length(results));
ylabel('Ratio');
title('Brightness Ratio (Enh/Orig)');
grid on;

subplot(2, 4, 3);
contrast = arrayfun(@(x) x.metrics.contrastEnh, results);
bar(contrast);
set(gca, 'XTickLabel', 1:length(results));
ylabel('Contrast (Std)');
title('Contrast After Enhancement');
grid on;

subplot(2, 4, 4);
entropy_vals = arrayfun(@(x) x.metrics.entropyEnh, results);
bar(entropy_vals);
set(gca, 'XTickLabel', 1:length(results));
ylabel('Entropy');
title('Information Content');
grid on;

subplot(2, 4, 5);
edges = arrayfun(@(x) x.metrics.edgeContentEnh, results);
bar(edges);
set(gca, 'XTickLabel', 1:length(results));
ylabel('Edge Content');
title('Edge Strength');
grid on;

subplot(2, 4, 6);
times = arrayfun(@(x) x.metrics.processingTime, results);
bar(times);
set(gca, 'XTickLabel', 1:length(results));
ylabel('Time (s)');
title('Processing Time');
grid on;

subplot(2, 4, 7);
gammaL = arrayfun(@(x) x.params.gammaL, results);
gammaH = arrayfun(@(x) x.params.gammaH, results);
bar([gammaL; gammaH]');
set(gca, 'XTickLabel', 1:length(results));
ylabel('Gamma Value');
title('γL vs γH');
legend('γL', 'γH', 'Location', 'best');
grid on;

subplot(2, 4, 8);
D0_vals = arrayfun(@(x) x.params.D0, results);
bar(D0_vals);
set(gca, 'XTickLabel', 1:length(results));
ylabel('D0');
title('Cutoff Frequency');
grid on;

%% 8. TEST 5 
fprintf('\n=== TEST 5: EFFECT OF GAMMA_L (Low Frequency Gain) ===\n');

gammaL_range = [0.2, 0.4, 0.6, 0.8, 1.0];
figure('Name', 'Effect of Gamma_L', 'Position', [50 50 1400 700]);

subplot(2, length(gammaL_range)+1, 1);
imshow(imgTunnel);
title('Original');

for i = 1:length(gammaL_range)
    gL = gammaL_range(i);
    [enhanced, spectrum] = homomorphicFilter(imgTunnel, gL, 2.0, 1.0, 30);

    subplot(2, length(gammaL_range)+1, i+1);
    imshow(enhanced);
    title(sprintf('γ_L = %.1f\nMean: %.1f', gL, mean(double(enhanced(:)))));

    subplot(2, length(gammaL_range)+1, length(gammaL_range)+1 + i+1);
    imshow(spectrum.filter, []);
    title(sprintf('Filter (γ_L=%.1f)', gL));
    colormap(gca, 'jet');

    fprintf('  γL=%.1f: Mean brightness = %.1f\n', gL, mean(double(enhanced(:))));
end

sgtitle('Effect of γ_L on Enhancement (γ_H=2.0, c=1.0, D_0=30)', 'FontSize', 14);

%% 9. TEST 6 
fprintf('\n=== TEST 6: EFFECT OF GAMMA_H (High Frequency Gain) ===\n');

gammaH_range = [1.0, 1.5, 2.0, 2.5, 3.0];
figure('Name', 'Effect of Gamma_H', 'Position', [50 50 1400 700]);

subplot(2, length(gammaH_range)+1, 1);
imshow(imgTunnel);
title('Original');

for i = 1:length(gammaH_range)
    gH = gammaH_range(i);
    [enhanced, spectrum] = homomorphicFilter(imgTunnel, 0.5, gH, 1.0, 30);

    subplot(2, length(gammaH_range)+1, i+1);
    imshow(enhanced);
    title(sprintf('γ_H = %.1f\nContrast: %.1f', gH, std(double(enhanced(:)))));

    subplot(2, length(gammaH_range)+1, length(gammaH_range)+1 + i+1);
    imshow(spectrum.filter, []);
    title(sprintf('Filter (γ_H=%.1f)', gH));
    colormap(gca, 'jet');

    fprintf('  γH=%.1f: Contrast = %.1f\n', gH, std(double(enhanced(:))));
end

sgtitle('Effect of γ_H on Enhancement (γ_L=0.5, c=1.0, D_0=30)', 'FontSize', 14);

%% 10. TEST 7 
fprintf('\n=== TEST 7: EFFECT OF D0 (CUTOFF FREQUENCY) ===\n');

D0_range = [10, 20, 40, 60, 80];
figure('Name', 'Effect of D0', 'Position', [50 50 1400 700]);

subplot(2, length(D0_range)+1, 1);
imshow(imgTunnel);
title('Original');

for i = 1:length(D0_range)
    d = D0_range(i);
    [enhanced, spectrum] = homomorphicFilter(imgTunnel, 0.5, 2.0, 1.0, d);

    subplot(2, length(D0_range)+1, i+1);
    imshow(enhanced);
    title(sprintf('D_0 = %d', d));

    subplot(2, length(D0_range)+1, length(D0_range)+1 + i+1);
    imshow(spectrum.filter, []);
    title(sprintf('Filter (D_0=%d)', d));
    colormap(gca, 'jet');

    fprintf('  D0=%d: Mean brightness = %.1f\n', d, mean(double(enhanced(:))));
end

sgtitle('Effect of D_0 on Enhancement (γ_L=0.5, γ_H=2.0, c=1.0)', 'FontSize', 14);

%% 11. TEST 8 
fprintf('\n=== TEST 8: ADDITIONAL TEST IMAGES ===\n');

figure('Name', 'Additional Test Images', 'Position', [50 50 1400 600]);

subplot(2, 4, 1);
imshow(imgExtra1);
title('Extra Image 1 (Original)');

[enhanced1, ~] = homomorphicFilter(imgExtra1, 0.5, 2.0, 1.0, 30);
subplot(2, 4, 2);
imshow(enhanced1);
title('Enhanced 1');

subplot(2, 4, 3);
imhist(imgExtra1);
title('Histogram Original 1');

subplot(2, 4, 4);
imhist(enhanced1);
title('Histogram Enhanced 1');

subplot(2, 4, 5);
imshow(imgExtra2);
title('Extra Image 2 (Original)');

[enhanced2, ~] = homomorphicFilter(imgExtra2, 0.4, 2.2, 1.5, 40);
subplot(2, 4, 6);
imshow(enhanced2);
title('Enhanced 2');

subplot(2, 4, 7);
imhist(rgb2gray(imgExtra2));
title('Histogram Original 2');

subplot(2, 4, 8);
imhist(rgb2gray(enhanced2));
title('Histogram Enhanced 2');

%% 12. SAVE RESULTS
fprintf('\n=== SAVING RESULTS ===\n');

outputDir = 'output_brightening';
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

imwrite(enhancedTunnel, fullfile(outputDir, 'enhanced_tunnel.jpg'));
imwrite(enhancedFlower, fullfile(outputDir, 'enhanced_flower.jpg'));
imwrite(enhanced1, fullfile(outputDir, 'enhanced_extra1.jpg'));
imwrite(enhanced2, fullfile(outputDir, 'enhanced_extra2.jpg'));

fprintf('Enhanced images saved to %s/\n', outputDir);