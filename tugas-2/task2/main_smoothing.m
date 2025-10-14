%% MAIN_SMOOTHING - Program Testing Image Smoothing
clear; clc; close all;

%% 1. SETUP
fprintf('=== IMAGE SMOOTHING & BLURRING ===\n');
fprintf('Spatial Domain: Mean, Gaussian, Median Filters\n');
fprintf('Frequency Domain: ILPF, GLPF, BLPF\n\n');

addpath(genpath('.'));

%% 2. LOAD TEST IMAGES
try
    imgGray1 = imread('cameraman.tif');
    fprintf('Grayscale 1: cameraman.tif\n');
catch
    imgGray1 = imread('coins.png');
    fprintf('Grayscale 1: coins.png\n');
end

try
    imgGray2 = imread('pout.tif');
    fprintf('Grayscale 2: pout.tif\n');
catch
    imgGray2 = uint8(rand(256,256)*255);
    fprintf('Grayscale 2: random image\n');
end

try
    imgGray3 = imread('rice.png');
    fprintf('Grayscale 3: rice.png\n');
catch
    imgGray3 = uint8(rand(256,256)*255);
    fprintf('Grayscale 3: random image\n');
end

% Color images
try
    imgColor1 = imread('peppers.png');
    fprintf('Color 1: peppers.png\n');
catch
    imgColor1 = uint8(rand(256,256,3)*255);
    fprintf('Color 1: random image\n');
end

try
    imgColor2 = imread('autumn.tif');
    fprintf('Color 2: autumn.tif\n');
catch
    imgColor2 = uint8(rand(256,256,3)*255);
    fprintf('Color 2: random image\n');
end

try
    imgColor3 = imread('football.jpg');
    fprintf('Color 3: football.jpg\n');
catch
    imgColor3 = uint8(rand(256,256,3)*255);
    fprintf('Color 3: random image\n');
end

%% 3. TEST 1 - SPATIAL SMOOTHING PADA GRAYSCALE
fprintf('\n=== TEST 1: SPATIAL SMOOTHING - GRAYSCALE ===\n');

[noisyGray, noiseParams] = addNoise(imgGray1, 'gaussian', 0, 0.01);
fprintf('Noise added: Gaussian (mean=0, var=0.01)\n');

filterSizes = [3, 5, 7];

figure('Name', 'Spatial Smoothing - Grayscale', 'Position', [50 50 1400 900]);

subplot(3, 4, 1);
imshow(imgGray1); title('Original');

subplot(3, 4, 2);
imshow(noisyGray); title('Noisy (Gaussian)');

idx = 3;
for n = filterSizes
    % Mean filter
    smoothedMean = spatialSmoothing(noisyGray, 'mean', n);
    subplot(3, 4, idx);
    imshow(smoothedMean);
    title(sprintf('Mean %dx%d', n, n));
    idx = idx + 1;
end

idx = 7;
for n = filterSizes
    % Gaussian filter
    smoothedGauss = spatialSmoothing(noisyGray, 'gaussian', n, n/5);
    subplot(3, 4, idx);
    imshow(smoothedGauss);
    title(sprintf('Gaussian %dx%d', n, n));
    idx = idx + 1;
end

% Median filter 
[noisySP, ~] = addNoise(imgGray1, 'salt_pepper', 0.05);
subplot(3, 4, 11);
imshow(noisySP); title('Salt & Pepper Noise');

smoothedMedian = spatialSmoothing(noisySP, 'median', 5);
subplot(3, 4, 12);
imshow(smoothedMedian); title('Median Filter 5x5');

%% 4. TEST 2 - FREQUENCY SMOOTHING PADA GRAYSCALE
fprintf('\n=== TEST 2: FREQUENCY SMOOTHING - GRAYSCALE ===\n');

cutoffFreqs = [20, 40, 60];

figure('Name', 'Frequency Smoothing - Grayscale', 'Position', [50 50 1400 900]);

subplot(3, 4, 1);
imshow(imgGray1); title('Original');

subplot(3, 4, 2);
imshow(noisyGray); title('Noisy (Gaussian)');

idx = 3;
for D0 = cutoffFreqs
    % ILPF
    [smoothedILPF, ~, spectrum] = frequencySmoothing(noisyGray, 'ILPF', D0);
    subplot(3, 4, idx);
    imshow(smoothedILPF);
    title(sprintf('ILPF D0=%d', D0));
    idx = idx + 1;
end

idx = 7;
for D0 = cutoffFreqs
    % GLPF
    smoothedGLPF = frequencySmoothing(noisyGray, 'GLPF', D0);
    subplot(3, 4, idx);
    imshow(smoothedGLPF);
    title(sprintf('GLPF D0=%d', D0));
    idx = idx + 1;
end

idx = 11;
for D0 = [30, 50]
    % BLPF
    smoothedBLPF = frequencySmoothing(noisyGray, 'BLPF', D0, 2);
    subplot(3, 4, idx);
    imshow(smoothedBLPF);
    title(sprintf('BLPF D0=%d n=2', D0));
    idx = idx + 1;
end

%% 5. TEST 3 - VISUALISASI FILTER FREKUENSI
fprintf('\n=== TEST 3: VISUALISASI FILTER FREKUENSI ===\n');

[M, N] = size(noisyGray);
D0 = 40;

filterILPF = createLowPassFilter(M, N, 'ILPF', D0);
filterGLPF = createLowPassFilter(M, N, 'GLPF', D0);
filterBLPF = createLowPassFilter(M, N, 'BLPF', D0, 2);

figure('Name', 'Low-Pass Filters Visualization', 'Position', [50 50 1400 400]);

subplot(1, 4, 1);
imshow(filterILPF, []); title('ILPF');
colorbar;

subplot(1, 4, 2);
imshow(filterGLPF, []); title('GLPF');
colorbar;

subplot(1, 4, 3);
imshow(filterBLPF, []); title('BLPF (n=2)');
colorbar;

subplot(1, 4, 4);
centerRow = round(M/2);
plot(filterILPF(centerRow, :), 'b-', 'LineWidth', 2); hold on;
plot(filterGLPF(centerRow, :), 'r-', 'LineWidth', 2);
plot(filterBLPF(centerRow, :), 'g-', 'LineWidth', 2);
legend('ILPF', 'GLPF', 'BLPF');
title('Filter Cross-Section');
xlabel('Frequency'); ylabel('H(u,v)');
grid on;

%% 6. TEST 4 - SPEKTRUM FOURIER
fprintf('\n=== TEST 4: SPEKTRUM FOURIER ===\n');

F_orig = fft2(double(imgGray1));
F_orig_shifted = fftshift(F_orig);
spectrum_orig = log(1 + abs(F_orig_shifted));

F_noisy = fft2(double(noisyGray));
F_noisy_shifted = fftshift(F_noisy);
spectrum_noisy = log(1 + abs(F_noisy_shifted));

[smoothedGLPF, ~, spectrumGLPF] = frequencySmoothing(noisyGray, 'GLPF', 40);

figure('Name', 'Fourier Spectrum Analysis', 'Position', [50 50 1400 500]);

subplot(2, 4, 1);
imshow(imgGray1); title('Original Image');

subplot(2, 4, 2);
imshow(spectrum_orig, []); title('Original Spectrum');
colormap(gca, 'jet'); colorbar;

subplot(2, 4, 3);
imshow(noisyGray); title('Noisy Image');

subplot(2, 4, 4);
imshow(spectrum_noisy, []); title('Noisy Spectrum');
colormap(gca, 'jet'); colorbar;

subplot(2, 4, 5);
imshow(smoothedGLPF); title('Filtered Image (GLPF)');

subplot(2, 4, 6);
imshow(spectrumGLPF.filtered, []); title('Filtered Spectrum');
colormap(gca, 'jet'); colorbar;

subplot(2, 4, 7);
imshow(spectrumGLPF.filter, []); title('GLPF Filter');
colormap(gca, 'jet'); colorbar;

subplot(2, 4, 8);
diffSpectrum = abs(spectrum_noisy - spectrumGLPF.filtered);
imshow(diffSpectrum, []); title('Spectrum Difference');
colormap(gca, 'jet'); colorbar;

%% 7. TEST 5 - COLOR IMAGE SMOOTHING
fprintf('\n=== TEST 5: COLOR IMAGE SMOOTHING ===\n');

[noisyColor, ~] = addNoise(imgColor1, 'gaussian', 0, 0.01);

figure('Name', 'Color Image Smoothing', 'Position', [50 50 1400 800]);

subplot(3, 4, 1);
imshow(imgColor1); title('Original Color');

subplot(3, 4, 2);
imshow(noisyColor); title('Noisy Color');

% Spatial methods
smoothedColorMean = spatialSmoothing(noisyColor, 'mean', 5);
subplot(3, 4, 3);
imshow(smoothedColorMean); title('Mean Filter 5x5');

smoothedColorGauss = spatialSmoothing(noisyColor, 'gaussian', 5, 1.0);
subplot(3, 4, 4);
imshow(smoothedColorGauss); title('Gaussian Filter 5x5');

smoothedColorMedian = spatialSmoothing(noisyColor, 'median', 5);
subplot(3, 4, 5);
imshow(smoothedColorMedian); title('Median Filter 5x5');

smoothedColorBilateral = spatialSmoothing(noisyColor, 'bilateral', 5, 1.0);
subplot(3, 4, 6);
imshow(smoothedColorBilateral); title('Bilateral Filter 5x5');

% Frequency methods
smoothedColorILPF = frequencySmoothing(noisyColor, 'ILPF', 40);
subplot(3, 4, 7);
imshow(smoothedColorILPF); title('ILPF D0=40');

smoothedColorGLPF = frequencySmoothing(noisyColor, 'GLPF', 40);
subplot(3, 4, 8);
imshow(smoothedColorGLPF); title('GLPF D0=40');

smoothedColorBLPF = frequencySmoothing(noisyColor, 'BLPF', 40, 2);
subplot(3, 4, 9);
imshow(smoothedColorBLPF); title('BLPF D0=40');

metricsColorGauss = evaluateQuality(imgColor1, smoothedColorGauss, noisyColor);
subplot(3, 4, 10);
bar([metricsColorGauss.PSNR]);
title(sprintf('PSNR: %.2f dB', metricsColorGauss.PSNR));
ylabel('PSNR (dB)');

metricsColorGLPF = evaluateQuality(imgColor1, smoothedColorGLPF, noisyColor);
subplot(3, 4, 11);
bar([metricsColorGLPF.PSNR]);
title(sprintf('PSNR: %.2f dB', metricsColorGLPF.PSNR));
ylabel('PSNR (dB)');

subplot(3, 4, 12);
methods_names = {'Mean', 'Gauss', 'Median', 'Bilateral', 'ILPF', 'GLPF', 'BLPF'};
psnr_values = [
    evaluateQuality(imgColor1, smoothedColorMean, noisyColor).PSNR,
    metricsColorGauss.PSNR,
    evaluateQuality(imgColor1, smoothedColorMedian, noisyColor).PSNR,
    evaluateQuality(imgColor1, smoothedColorBilateral, noisyColor).PSNR,
    evaluateQuality(imgColor1, smoothedColorILPF, noisyColor).PSNR,
    metricsColorGLPF.PSNR,
    evaluateQuality(imgColor1, smoothedColorBLPF, noisyColor).PSNR
];
bar(psnr_values);
set(gca, 'XTickLabel', methods_names);
xtickangle(45);
ylabel('PSNR (dB)');
title('Method Comparison');
grid on;

%% 8. TEST 6 - COMPREHENSIVE COMPARISON
fprintf('\n=== TEST 6: COMPREHENSIVE COMPARISON ===\n');

results = compareSmoothing(imgGray1, noisyGray, 5, 40);
figure('Name', 'Comprehensive Comparison', 'Position', [50 50 1400 800]);

subplot(3, 4, 1);
imshow(imgGray1); title('Original');

subplot(3, 4, 2);
imshow(noisyGray); title('Noisy');

for i = 1:length(results)
    subplot(3, 4, i+2);
    imshow(results(i).smoothed);
    title(sprintf('%s\nPSNR: %.2f dB', ...
        strrep(results(i).method, 'Spatial - ', ''), ...
        results(i).metrics.PSNR));
end

figure('Name', 'Metrics Comparison', 'Position', [50 50 1200 600]);

% PSNR
subplot(2, 3, 1);
psnr_vals = arrayfun(@(x) x.metrics.PSNR, results);
bar(psnr_vals);
set(gca, 'XTickLabel', 1:length(results));
ylabel('PSNR (dB)'); title('PSNR Comparison');
grid on;

% SSIM
subplot(2, 3, 2);
ssim_vals = arrayfun(@(x) x.metrics.SSIM, results);
bar(ssim_vals);
set(gca, 'XTickLabel', 1:length(results));
ylabel('SSIM'); title('SSIM Comparison');
grid on;

% Processing Time
subplot(2, 3, 3);
time_vals = arrayfun(@(x) x.time, results);
bar(time_vals);
set(gca, 'XTickLabel', 1:length(results));
ylabel('Time (s)'); title('Processing Time');
grid on;

% Noise Reduction
subplot(2, 3, 4);
noise_red = arrayfun(@(x) x.metrics.NoiseReduction, results);
bar(noise_red);
set(gca, 'XTickLabel', 1:length(results));
ylabel('Noise Reduction (%)'); title('Noise Reduction');
grid on;

% MSE
subplot(2, 3, 5);
mse_vals = arrayfun(@(x) x.metrics.MSE, results);
bar(mse_vals);
set(gca, 'XTickLabel', 1:length(results));
ylabel('MSE'); title('MSE Comparison');
grid on;

% Correlation
subplot(2, 3, 6);
corr_vals = arrayfun(@(x) x.metrics.Correlation, results);
bar(corr_vals);
set(gca, 'XTickLabel', 1:length(results));
ylabel('Correlation'); title('Correlation Coefficient');
grid on;

%% 9. TEST 7 - DIFFERENT NOISE TYPES
fprintf('\n=== TEST 7: BERBAGAI JENIS NOISE ===\n');

noiseTypes = {'gaussian', 'salt_pepper', 'speckle'};

figure('Name', 'Different Noise Types', 'Position', [50 50 1400 900]);

for i = 1:length(noiseTypes)
    switch noiseTypes{i}
        case 'gaussian'
            [noisy, ~] = addNoise(imgGray1, 'gaussian', 0, 0.01);
        case 'salt_pepper'
            [noisy, ~] = addNoise(imgGray1, 'salt_pepper', 0.05);
        case 'speckle'
            [noisy, ~] = addNoise(imgGray1, 'speckle', 0.04);
    end
    
    subplot(3, 5, (i-1)*5 + 1);
    imshow(imgGray1);
    if i == 1
        title('Original');
    end
    
    subplot(3, 5, (i-1)*5 + 2);
    imshow(noisy);
    title([upper(noiseTypes{i}(1)) noiseTypes{i}(2:end) ' Noise']);
    
    if strcmp(noiseTypes{i}, 'gaussian')
        smoothed1 = spatialSmoothing(noisy, 'gaussian', 5, 1.0);
        smoothed2 = frequencySmoothing(noisy, 'GLPF', 40);
        label1 = 'Gaussian 5x5';
        label2 = 'GLPF D0=40';
    elseif strcmp(noiseTypes{i}, 'salt_pepper')
        smoothed1 = spatialSmoothing(noisy, 'median', 5);
        smoothed2 = spatialSmoothing(noisy, 'gaussian', 5, 1.0);
        label1 = 'Median 5x5';
        label2 = 'Gaussian 5x5';
    else
        smoothed1 = spatialSmoothing(noisy, 'gaussian', 7, 1.4);
        smoothed2 = frequencySmoothing(noisy, 'GLPF', 35);
        label1 = 'Gaussian 7x7';
        label2 = 'GLPF D0=35';
    end
    
    subplot(3, 5, (i-1)*5 + 3);
    imshow(smoothed1);
    metrics1 = evaluateQuality(imgGray1, smoothed1, noisy);
    title(sprintf('%s\nPSNR: %.2f', label1, metrics1.PSNR));
    
    subplot(3, 5, (i-1)*5 + 4);
    imshow(smoothed2);
    metrics2 = evaluateQuality(imgGray1, smoothed2, noisy);
    title(sprintf('%s\nPSNR: %.2f', label2, metrics2.PSNR));
    
    subplot(3, 5, (i-1)*5 + 5);
    bar([metrics1.PSNR, metrics2.PSNR]);
    set(gca, 'XTickLabel', {'Method 1', 'Method 2'});
    ylabel('PSNR (dB)');
    title('Comparison');
    grid on;
end

%% 10. TEST 8 - PARAMETER SENSITIVITY
fprintf('\n=== TEST 8: PARAMETER SENSITIVITY ===\n');

filterSizesTest = 3:2:15;
psnr_mean = zeros(size(filterSizesTest));
psnr_gauss = zeros(size(filterSizesTest));

fprintf('Testing filter sizes: ');
for i = 1:length(filterSizesTest)
    n = filterSizesTest(i);
    fprintf('%d ', n);
    
    smoothedMean = spatialSmoothing(noisyGray, 'mean', n);
    metrics = evaluateQuality(imgGray1, smoothedMean, noisyGray);
    psnr_mean(i) = metrics.PSNR;
    
    smoothedGauss = spatialSmoothing(noisyGray, 'gaussian', n, n/5);
    metrics = evaluateQuality(imgGray1, smoothedGauss, noisyGray);
    psnr_gauss(i) = metrics.PSNR;
end
fprintf('\n');

cutoffFreqsTest = 10:10:100;
psnr_ilpf = zeros(size(cutoffFreqsTest));
psnr_glpf = zeros(size(cutoffFreqsTest));
psnr_blpf = zeros(size(cutoffFreqsTest));

fprintf('Testing cutoff frequencies: ');
for i = 1:length(cutoffFreqsTest)
    D0 = cutoffFreqsTest(i);
    fprintf('%d ', D0);
    
    smoothedILPF = frequencySmoothing(noisyGray, 'ILPF', D0);
    metrics = evaluateQuality(imgGray1, smoothedILPF, noisyGray);
    psnr_ilpf(i) = metrics.PSNR;
    
    smoothedGLPF = frequencySmoothing(noisyGray, 'GLPF', D0);
    metrics = evaluateQuality(imgGray1, smoothedGLPF, noisyGray);
    psnr_glpf(i) = metrics.PSNR;
    
    smoothedBLPF = frequencySmoothing(noisyGray, 'BLPF', D0, 2);
    metrics = evaluateQuality(imgGray1, smoothedBLPF, noisyGray);
    psnr_blpf(i) = metrics.PSNR;
end
fprintf('\n');
figure('Name', 'Parameter Sensitivity Analysis', 'Position', [50 50 1200 500]);

subplot(1, 2, 1);
plot(filterSizesTest, psnr_mean, 'b-o', 'LineWidth', 2); hold on;
plot(filterSizesTest, psnr_gauss, 'r-s', 'LineWidth', 2);
xlabel('Filter Size (n×n)');
ylabel('PSNR (dB)');
title('Spatial Domain - Filter Size Effect');
legend('Mean Filter', 'Gaussian Filter');
grid on;

subplot(1, 2, 2);
plot(cutoffFreqsTest, psnr_ilpf, 'b-o', 'LineWidth', 2); hold on;
plot(cutoffFreqsTest, psnr_glpf, 'r-s', 'LineWidth', 2);
plot(cutoffFreqsTest, psnr_blpf, 'g-d', 'LineWidth', 2);
xlabel('Cutoff Frequency (D0)');
ylabel('PSNR (dB)');
title('Frequency Domain - Cutoff Frequency Effect');
legend('ILPF', 'GLPF', 'BLPF');
grid on;

%% 11. TEST 9 - MULTIPLE IMAGES BATCH PROCESSING
fprintf('\n=== TEST 9: BATCH PROCESSING ===\n');

grayImages = {imgGray1, imgGray2, imgGray3};
colorImages = {imgColor1, imgColor2, imgColor3};

fprintf('Processing grayscale images...\n');
for i = 1:length(grayImages)
    img = grayImages{i};
    [noisy, ~] = addNoise(img, 'gaussian', 0, 0.01);
    
    smoothedSpatial = spatialSmoothing(noisy, 'gaussian', 5, 1.0);
    smoothedFreq = frequencySmoothing(noisy, 'GLPF', 40);
    
    metricsSpatial = evaluateQuality(img, smoothedSpatial, noisy);
    metricsFreq = evaluateQuality(img, smoothedFreq, noisy);
    
    fprintf('  Image %d - Spatial PSNR: %.2f, Frequency PSNR: %.2f\n', ...
        i, metricsSpatial.PSNR, metricsFreq.PSNR);
end

fprintf('Processing color images...\n');
for i = 1:length(colorImages)
    img = colorImages{i};
    [noisy, ~] = addNoise(img, 'gaussian', 0, 0.01);
    
    smoothedSpatial = spatialSmoothing(noisy, 'gaussian', 5, 1.0);
    smoothedFreq = frequencySmoothing(noisy, 'GLPF', 40);
    
    metricsSpatial = evaluateQuality(img, smoothedSpatial, noisy);
    metricsFreq = evaluateQuality(img, smoothedFreq, noisy);
    
    fprintf('  Image %d - Spatial PSNR: %.2f, Frequency PSNR: %.2f\n', ...
        i, metricsSpatial.PSNR, metricsFreq.PSNR);
end