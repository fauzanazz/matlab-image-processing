%% MAIN_SMOOTHING - Image Smoothing / Blurring
% Fitur:
%   RANAH SPASIAL (menggunakan konvolusi dari Task 1):
%     - Mean Filter n x n
%     - Gaussian Filter n x n
%
%   RANAH FREKUENSI (Slide 12-41):
%     - ILPF (Ideal Low-Pass Filter) - Slide 12
%     - GLPF (Gaussian Low-Pass Filter) - Slide 26
%     - BLPF (Butterworth Low-Pass Filter) - Slide 27
%
%   - Support citra grayscale dan RGB
%   - Testing pada citra dengan noise (derau)

clear; clc; close all;

fprintf('================================================================\n');
fprintf('    IMAGE SMOOTHING / BLURRING\n');
fprintf('    Ranah Spasial dan Ranah Frekuensi\n');
fprintf('================================================================\n\n');

%% 1. SETUP
fprintf('1. SETUP\n');
fprintf('   Ranah Spasial: Mean Filter, Gaussian Filter (Task 1 Convolution)\n');
fprintf('   Ranah Frekuensi: ILPF, GLPF, BLPF (Slide 12-41)\n\n');

%% 2. LOAD TEST IMAGES
fprintf('2. LOAD TEST IMAGES\n');
fprintf('   Requirement: 3 grayscale + 3 color + 2 tambahan\n\n');

try
    imgGray1 = imread('cameraman.tif');
    fprintf('   Grayscale 1: cameraman.tif\n');
catch
    imgGray1 = uint8(rand(256,256)*255);
    fprintf('   Grayscale 1: random image\n');
end

try
    imgGray2 = imread('pout.tif');
    fprintf('   Grayscale 2: pout.tif\n');
catch
    imgGray2 = uint8(rand(256,256)*255);
    fprintf('   Grayscale 2: random image\n');
end

try
    imgGray3 = imread('rice.png');
    fprintf('   Grayscale 3: rice.png\n');
catch
    imgGray3 = uint8(rand(256,256)*255);
    fprintf('   Grayscale 3: random image\n');
end

try
    imgGrayExtra = imread('coins.png');
    fprintf('   Grayscale Extra: coins.png\n');
catch
    imgGrayExtra = imgGray1;
    fprintf('   Grayscale Extra: using cameraman\n');
end

try
    imgColor1 = imread('peppers.png');
    fprintf('   Color 1: peppers.png\n');
catch
    imgColor1 = uint8(rand(256,256,3)*255);
    fprintf('   Color 1: random image\n');
end

try
    imgColor2 = imread('autumn.tif');
    fprintf('   Color 2: autumn.tif\n');
catch
    imgColor2 = uint8(rand(256,256,3)*255);
    fprintf('   Color 2: random image\n');
end

try
    imgColor3 = imread('football.jpg');
    fprintf('   Color 3: football.jpg\n');
catch
    imgColor3 = imgColor1;
    fprintf('   Color 3: using peppers\n');
end

try
    imgColorExtra = imread('flowers.tif');
    fprintf('   Color Extra: flowers.tif\n');
catch
    imgColorExtra = imgColor1;
    fprintf('   Color Extra: using peppers\n');
end

fprintf('\n');

%% 3. PARAMETER
fprintf('3. PARAMETER FILTERING\n');

n_mean = 5;           % Mean filter size
n_gauss = 5;          % Gaussian filter size
sigma_gauss = 1.0;    % Gaussian sigma

D0 = 50;              % Cutoff frequency
n_butter = 2;         % Butterworth order
usePadding = true;    % Padding 2x (Slide 13)

fprintf('   SPATIAL DOMAIN:\n');
fprintf('   - Mean filter: %dx%d\n', n_mean, n_mean);
fprintf('   - Gaussian filter: %dx%d (sigma=%.1f)\n', n_gauss, n_gauss, sigma_gauss);
fprintf('\n   FREQUENCY DOMAIN:\n');
fprintf('   - Cutoff frequency (D0): %d\n', D0);
fprintf('   - Butterworth order (n): %d\n', n_butter);
fprintf('   - Padding: %s\n\n', iif(usePadding, '2x (P=2M, Q=2N) - Slide 13', 'No padding'));

%% 4. TEST 1 - SMOOTHING PADA GRAYSCALE DENGAN NOISE
fprintf('4. TEST 1: SMOOTHING GRAYSCALE (dengan Gaussian Noise)\n');

[noisyGray, noiseParams] = addNoise(imgGray1, 'gaussian', 0, 0.01);
fprintf('   Noise: Gaussian (mean=0, var=0.01)\n\n');

% Spatial domain
fprintf('   Spatial filtering...\n');
tic; [meanResult, meanKernel] = meanFilter(noisyGray, n_mean); t_mean = toc;
fprintf('   - Mean filter: %.4fs\n', t_mean);

tic; [gaussResult, gaussKernel] = gaussianFilter(noisyGray, n_gauss, sigma_gauss); t_gauss = toc;
fprintf('   - Gaussian filter: %.4fs\n', t_gauss);

% Frequency domain
fprintf('   Frequency filtering...\n');
tic; [ilpfResult, H_ilpf, spec_ilpf] = ilpf(noisyGray, D0, usePadding); t_ilpf = toc;
fprintf('   - ILPF: %.4fs\n', t_ilpf);

tic; [glpfResult, H_glpf, spec_glpf] = glpf(noisyGray, D0, usePadding); t_glpf = toc;
fprintf('   - GLPF: %.4fs\n', t_glpf);

tic; [blpfResult, H_blpf, spec_blpf] = blpf(noisyGray, D0, n_butter, usePadding); t_blpf = toc;
fprintf('   - BLPF: %.4fs\n\n', t_blpf);

figure('Name', 'Test 1: Smoothing Grayscale', 'Position', [50 50 1400 900]);

subplot(3, 4, 1);
imshow(imgGray1);
title('Original');

subplot(3, 4, 2);
imshow(noisyGray);
title('Noisy (Gaussian)');

subplot(3, 4, 3);
imshow(meanResult);
title(sprintf('Mean %dx%d (Spatial)', n_mean, n_mean));

subplot(3, 4, 4);
imshow(gaussResult);
title(sprintf('Gaussian %dx%d (Spatial)', n_gauss, n_gauss));

subplot(3, 4, 5);
text(0.5, 0.5, 'Frequency Domain', 'HorizontalAlignment', 'center', 'FontSize', 11, 'FontWeight', 'bold');
axis off;

subplot(3, 4, 6);
imshow(ilpfResult);
title(sprintf('ILPF D0=%d', D0));

subplot(3, 4, 7);
imshow(glpfResult);
title(sprintf('GLPF D0=%d', D0));

subplot(3, 4, 8);
imshow(blpfResult);
title(sprintf('BLPF D0=%d n=%d', D0, n_butter));

subplot(3, 4, 9);
imshow(meanKernel, []);
title('Mean Kernel');
colorbar;

subplot(3, 4, 10);
imshow(H_ilpf);
title('ILPF Filter H(u,v)');
colorbar;

subplot(3, 4, 11);
imshow(H_glpf);
title('GLPF Filter H(u,v)');
colorbar;

subplot(3, 4, 12);
imshow(H_blpf);
title('BLPF Filter H(u,v)');
colorbar;

sgtitle('Test 1: Smoothing/Blurring Grayscale dengan Noise', 'FontSize', 14, 'FontWeight', 'bold');

%% 5. TEST 2 - 3D FILTER VISUALIZATION 
fprintf('5. TEST 2: 3D FILTER VISUALIZATION \n\n');

figure('Name', 'Test 2: 3D Filter Visualization', 'Position', [100 100 1400 400]);

subplot(1, 3, 1);
mesh(H_ilpf);
title('ILPF - 3D View');
xlabel('u'); ylabel('v'); zlabel('H(u,v)');
colormap(gca, 'jet');
view(45, 30);

subplot(1, 3, 2);
mesh(H_glpf);
title('GLPF - 3D View');
xlabel('u'); ylabel('v'); zlabel('H(u,v)');
colormap(gca, 'jet');
view(45, 30);

subplot(1, 3, 3);
mesh(H_blpf);
title(sprintf('BLPF (n=%d) - 3D View', n_butter));
xlabel('u'); ylabel('v'); zlabel('H(u,v)');
colormap(gca, 'jet');
view(45, 30);

sgtitle('3D Filter Visualization (Slide 21, 33, 39)', 'FontSize', 12, 'FontWeight', 'bold');

%% 6. TEST 3 - RINGING EFFECT
fprintf('6. TEST 3: RINGING EFFECT DEMONSTRATION\n');
fprintf('   ILPF menimbulkan ringing, GLPF tidak\n\n');

D0_ring = 30; 
[ilpf_ring, ~, ~] = ilpf(noisyGray, D0_ring, usePadding);
[glpf_ring, ~, ~] = glpf(noisyGray, D0_ring, usePadding);
diff_ring = abs(double(ilpf_ring) - double(glpf_ring));

figure('Name', 'Test 3: Ringing Effect', 'Position', [50 50 1400 500]);

subplot(1, 4, 1);
imshow(noisyGray);
title('Noisy Image');

subplot(1, 4, 2);
imshow(ilpf_ring);
title(sprintf('ILPF D0=%d\nADA RINGING', D0_ring), 'Color', 'red');

subplot(1, 4, 3);
imshow(glpf_ring);
title(sprintf('GLPF D0=%d\nTIDAK ADA RINGING', D0_ring), 'Color', 'green');

subplot(1, 4, 4);
imshow(diff_ring, []);
title('Difference (Ringing Artifact)');
colorbar; colormap(gca, 'hot');

sgtitle('Ringing Effect: ILPF (Diskontinuitas) vs GLPF (Smooth)', 'FontSize', 14);

%% 7. TEST 4 - EFFECT OF CUTOFF FREQUENCY (D0)
fprintf('7. TEST 4: EFFECT OF CUTOFF FREQUENCY (D0)\n');

D0_values = [10, 30, 50, 80, 120];

figure('Name', 'Test 4: Effect of D0 on GLPF', 'Position', [50 50 1400 800]);

for i = 1:length(D0_values)
    D0_test = D0_values(i);
    [result_test, ~, ~] = glpf(noisyGray, D0_test, usePadding);

    subplot(2, 3, i);
    imshow(result_test);
    title(sprintf('GLPF D0=%d', D0_test));

    fprintf('   D0=%d processed\n', D0_test);
end

subplot(2, 3, 6);
imshow(noisyGray);
title('Noisy Original');

sgtitle('Effect of Cutoff Frequency (D0) on GLPF', 'FontSize', 14);
fprintf('\n');

%% 8. TEST 5 - COLOR IMAGE SMOOTHING
fprintf('8. TEST 5: SMOOTHING COLOR IMAGE\n');

[noisyColor, ~] = addNoise(imgColor1, 'gaussian', 0, 0.01);
fprintf('   Noise: Gaussian (mean=0, var=0.01)\n\n');
fprintf('   Applying filters on color image...\n');
[meanColor, ~] = meanFilter(noisyColor, n_mean);
[gaussColor, ~] = gaussianFilter(noisyColor, n_gauss, sigma_gauss);
[ilpfColor, ~, ~] = ilpf(noisyColor, D0, usePadding);
[glpfColor, ~, ~] = glpf(noisyColor, D0, usePadding);
[blpfColor, ~, ~] = blpf(noisyColor, D0, n_butter, usePadding);

fprintf('   Done!\n\n');

figure('Name', 'Test 5: Smoothing Color Image', 'Position', [50 50 1400 800]);

subplot(3, 3, 1);
imshow(imgColor1);
title('Original RGB');

subplot(3, 3, 2);
imshow(noisyColor);
title('Noisy RGB');

subplot(3, 3, 3);
text(0.5, 0.5, 'Smoothing Results', 'HorizontalAlignment', 'center', 'FontSize', 11);
axis off;

% Spatial results
subplot(3, 3, 4);
imshow(meanColor);
title('Mean Filter (Spatial)');

subplot(3, 3, 5);
imshow(gaussColor);
title('Gaussian Filter (Spatial)');

subplot(3, 3, 6);
text(0.5, 0.5, sprintf('Spatial Domain\n(Task 1 Convolution)'), 'HorizontalAlignment', 'center', 'FontSize', 10);
axis off;

% Frequency results
subplot(3, 3, 7);
imshow(ilpfColor);
title('ILPF (Frequency)');

subplot(3, 3, 8);
imshow(glpfColor);
title('GLPF (Frequency)');

subplot(3, 3, 9);
imshow(blpfColor);
title('BLPF (Frequency)');

sgtitle('Smoothing/Blurring Color Image', 'FontSize', 14, 'FontWeight', 'bold');

%% 9. TEST 6 - BATCH PROCESSING (3 Grayscale Images)
fprintf('9. TEST 6: BATCH PROCESSING - 3 GRAYSCALE IMAGES\n');

grayImages = {imgGray1, imgGray2, imgGray3};
imageNames = {'Image 1', 'Image 2', 'Image 3'};

figure('Name', 'Test 6: Batch Grayscale Processing', 'Position', [50 50 1400 900]);

for i = 1:length(grayImages)
    img = grayImages{i};
    [noisy, ~] = addNoise(img, 'gaussian', 0, 0.01);

    [smoothed_spatial, ~] = gaussianFilter(noisy, 5, 1.0);
    [smoothed_freq, ~, ~] = glpf(noisy, D0, usePadding);

    % Original
    subplot(3, 4, (i-1)*4 + 1);
    imshow(img);
    if i == 1, title('Original'); else, title(''); end
    ylabel(imageNames{i}, 'FontWeight', 'bold');

    % Noisy
    subplot(3, 4, (i-1)*4 + 2);
    imshow(noisy);
    if i == 1, title('Noisy'); else, title(''); end

    % Spatial
    subplot(3, 4, (i-1)*4 + 3);
    imshow(smoothed_spatial);
    if i == 1, title('Gaussian Filter'); else, title(''); end

    % Frequency
    subplot(3, 4, (i-1)*4 + 4);
    imshow(smoothed_freq);
    if i == 1, title('GLPF'); else, title(''); end

    fprintf('   %s: Processed\n', imageNames{i});
end

sgtitle('Batch Processing: 3 Grayscale Images', 'FontSize', 14, 'FontWeight', 'bold');
fprintf('\n');

%% 10. TEST 7 - BATCH PROCESSING (3 Color Images)
fprintf('10. TEST 7: BATCH PROCESSING - 3 COLOR IMAGES\n');

colorImages = {imgColor1, imgColor2, imgColor3};
colorNames = {'Color 1', 'Color 2', 'Color 3'};

figure('Name', 'Test 7: Batch Color Processing', 'Position', [50 50 1400 900]);

for i = 1:length(colorImages)
    img = colorImages{i};
    [noisy, ~] = addNoise(img, 'gaussian', 0, 0.01);

    [smoothed_spatial, ~] = gaussianFilter(noisy, 5, 1.0);
    [smoothed_freq, ~, ~] = glpf(noisy, D0, usePadding);

    % Original
    subplot(3, 4, (i-1)*4 + 1);
    imshow(img);
    if i == 1, title('Original'); else, title(''); end
    ylabel(colorNames{i}, 'FontWeight', 'bold');

    % Noisy
    subplot(3, 4, (i-1)*4 + 2);
    imshow(noisy);
    if i == 1, title('Noisy'); else, title(''); end

    % Spatial
    subplot(3, 4, (i-1)*4 + 3);
    imshow(smoothed_spatial);
    if i == 1, title('Gaussian Filter'); else, title(''); end

    % Frequency
    subplot(3, 4, (i-1)*4 + 4);
    imshow(smoothed_freq);
    if i == 1, title('GLPF'); else, title(''); end

    fprintf('   %s: Processed\n', colorNames{i});
end

sgtitle('Batch Processing: 3 Color Images', 'FontSize', 14, 'FontWeight', 'bold');
fprintf('\n');

%% 11. TEST 8 - EXTRA IMAGES
fprintf('11. TEST 8: EXTRA IMAGES (Grayscale + Color)\n');

figure('Name', 'Test 8: Extra Images', 'Position', [50 50 1400 500]);

% Extra grayscale
[noisyGrayEx, ~] = addNoise(imgGrayExtra, 'gaussian', 0, 0.01);
[smoothGrayEx, ~] = gaussianFilter(noisyGrayEx, 5, 1.0);
[glpfGrayEx, ~, ~] = glpf(noisyGrayEx, D0, usePadding);

subplot(2, 4, 1);
imshow(imgGrayExtra);
title('Extra Grayscale - Original');

subplot(2, 4, 2);
imshow(noisyGrayEx);
title('Noisy');

subplot(2, 4, 3);
imshow(smoothGrayEx);
title('Gaussian Filter');

subplot(2, 4, 4);
imshow(glpfGrayEx);
title('GLPF');

% Extra color
[noisyColorEx, ~] = addNoise(imgColorExtra, 'gaussian', 0, 0.01);
[smoothColorEx, ~] = gaussianFilter(noisyColorEx, 5, 1.0);
[glpfColorEx, ~, ~] = glpf(noisyColorEx, D0, usePadding);

subplot(2, 4, 5);
imshow(imgColorExtra);
title('Extra Color - Original');

subplot(2, 4, 6);
imshow(noisyColorEx);
title('Noisy');

subplot(2, 4, 7);
imshow(smoothColorEx);
title('Gaussian Filter');

subplot(2, 4, 8);
imshow(glpfColorEx);
title('GLPF');

sgtitle('Extra Images Processing', 'FontSize', 14, 'FontWeight', 'bold');
fprintf('   Extra images processed\n\n');

%% 12. TEST 9 - COMPARISON 
fprintf('12. TEST 9: COMPARISON\n');

figure('Name', 'Test 9: Comparison', 'Position', [50 50 1400 600]);

[noisyTest, ~] = addNoise(imgGray1, 'gaussian', 0, 0.01);

[mean_res, ~] = meanFilter(noisyTest, 5);
[gauss_res, ~] = gaussianFilter(noisyTest, 5, 1.0);
[ilpf_res, ~, ~] = ilpf(noisyTest, D0, usePadding);
[glpf_res, ~, ~] = glpf(noisyTest, D0, usePadding);
[blpf_res, ~, ~] = blpf(noisyTest, D0, n_butter, usePadding);

subplot(2, 4, 1);
imshow(imgGray1);
title('Original');

subplot(2, 4, 2);
imshow(noisyTest);
title('Noisy');

subplot(2, 4, 3);
imshow(mean_res);
title('Mean (Spatial)');

subplot(2, 4, 4);
imshow(gauss_res);
title('Gaussian (Spatial)');

subplot(2, 4, 5);
text(0.5, 0.5, 'Domain Comparison', 'HorizontalAlignment', 'center', 'FontSize', 11);
axis off;

subplot(2, 4, 6);
imshow(ilpf_res);
title('ILPF (Frequency)');

subplot(2, 4, 7);
imshow(glpf_res);
title('GLPF (Frequency)');

subplot(2, 4, 8);
imshow(blpf_res);
title('BLPF (Frequency)');

sgtitle('Comparison: All Smoothing Methods', 'FontSize', 14, 'FontWeight', 'bold');

%% 13. SUMMARY
fprintf('\n================================================================\n');
fprintf('SUMMARY\n');
fprintf('================================================================\n');
fprintf('Images Tested:\n');
fprintf('  - Grayscale: 3 required + 1 extra = 4 images\n');
fprintf('  - Color: 3 required + 1 extra = 4 images\n');
fprintf('  - Total: 8 images\n\n');
fprintf('Methods Implemented:\n');
fprintf('  SPATIAL DOMAIN (using Task 1 convolution):\n');
fprintf('    - Mean Filter %dx%d\n', n_mean, n_mean);
fprintf('    - Gaussian Filter %dx%d (sigma=%.1f)\n', n_gauss, n_gauss, sigma_gauss);
fprintf('  FREQUENCY DOMAIN:\n');
fprintf('    - ILPF (D0=%d)\n', D0);
fprintf('    - GLPF (D0=%d)\n', D0);
fprintf('    - BLPF (D0=%d, n=%d)\n', D0, n_butter);
fprintf('\nWaktu Komputasi (Grayscale, single image):\n');
fprintf('  Spatial:\n');
fprintf('    - Mean: %.4fs\n', t_mean);
fprintf('    - Gaussian: %.4fs\n', t_gauss);
fprintf('  Frequency:\n');
fprintf('    - ILPF: %.4fs\n', t_ilpf);
fprintf('    - GLPF: %.4fs\n', t_glpf);
fprintf('    - BLPF: %.4fs\n', t_blpf);
fprintf('\nRinging Effect:\n');
fprintf('  - ILPF: MENIMBULKAN ringing (transisi tajam)\n');
fprintf('  - GLPF: TIDAK ADA ringing (transisi smooth)\n');
fprintf('  - BLPF: Minimal ringing (transisi dapat dikontrol)\n');
fprintf('================================================================\n\n');

% Hitung jumlah figures
allFigs = findall(0, 'Type', 'figure');
numFigs = length(allFigs);
fprintf('Program selesai! Total %d figures ditampilkan.\n', numFigs);

%% Helper function
function result = iif(condition, trueVal, falseVal)
    if condition
        result = trueVal;
    else
        result = falseVal;
    end
end
