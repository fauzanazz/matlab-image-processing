%% MAIN_HIGHPASS - High-Pass Filtering dalam Ranah Frekuensi
%
% Fitur:
%   - IHPF (Ideal High-Pass Filter)
%   - GHPF (Gaussian High-Pass Filter)
%   - BHPF (Butterworth High-Pass Filter)
%   - Support citra grayscale dan RGB
%   - Demonstrasi ringing effect (Slide 24-25)
%   - Visualisasi 3D mesh (Slide 21, 33, 39)
clear; clc; close all;

fprintf('================================================================\n');
fprintf('    HIGH-PASS FILTERING DALAM RANAH FREKUENSI\n');
fprintf('    IHPF, GHPF, dan BHPF\n');
fprintf('================================================================\n\n');

%% 1. SETUP
fprintf('1. SETUP\n');
addpath(genpath('.'));

%% 2. LOAD TEST IMAGES
fprintf('2. LOAD TEST IMAGES\n');

% Grayscale images
try
    imgGray1 = imread('cameraman.tif');
    fprintf('   Grayscale 1: cameraman.tif\n');
catch
    try
        imgGray1 = imread('../task1/test_images/gray1.jpeg');
        fprintf('   Grayscale 1: gray1.jpeg\n');
    catch
        imgGray1 = uint8(rand(256,256)*255);
        fprintf('   Grayscale 1: random image\n');
    end
end

try
    imgGray2 = imread('pout.tif');
    fprintf('   Grayscale 2: pout.tif\n');
catch
    imgGray2 = uint8(rand(256,256)*255);
    fprintf('   Grayscale 2: random image\n');
end

% Color images
try
    imgColor1 = imread('peppers.png');
    fprintf('   Color 1: peppers.png\n');
catch
    try
        imgColor1 = imread('../task1/test_images/color1.jpeg');
        fprintf('   Color 1: color1.jpeg\n');
    catch
        imgColor1 = uint8(rand(256,256,3)*255);
        fprintf('   Color 1: random image\n');
    end
end

try
    imgColor2 = imread('autumn.tif');
    fprintf('   Color 2: autumn.tif\n');
catch
    imgColor2 = uint8(rand(256,256,3)*255);
    fprintf('   Color 2: random image\n');
end

fprintf('\n');

%% 3. PARAMETER FILTERING
fprintf('3. PARAMETER FILTERING\n');

D0 = 50;              
n_butterworth = 2;     
usePadding = true;     

fprintf('   Cutoff frequency (D0): %d\n', D0);
fprintf('   Butterworth order (n): %d\n', n_butterworth);
fprintf('   Padding: %s\n\n', iif(usePadding, '2x (P=2M, Q=2N)', 'No padding'));

%% 4. TEST 1 - BASIC HPF PADA GRAYSCALE
fprintf('4. TEST 1: BASIC HIGH-PASS FILTERING - GRAYSCALE\n');
fprintf('   Formula:\n');
fprintf('   - IHPF: H(u,v) = 0 jika D<=D0, 1 jika D>D0 (Slide 49)\n');
fprintf('   - GHPF: H(u,v) = 1 - exp(-D^2/(2*D0^2)) (Slide 51)\n');
fprintf('   - BHPF: H(u,v) = 1/(1 + [D0/D]^(2n)) (Slide 51)\n\n');

fprintf('   Applying IHPF... ');
tic; [ihpf_gray1, H_ihpf, spectrum_ihpf] = ihpf(imgGray1, D0, usePadding); time_ihpf = toc;
fprintf('Done (%.4fs)\n', time_ihpf);

fprintf('   Applying GHPF... ');
tic; [ghpf_gray1, H_ghpf, spectrum_ghpf] = ghpf(imgGray1, D0, usePadding); time_ghpf = toc;
fprintf('Done (%.4fs)\n', time_ghpf);

fprintf('   Applying BHPF... ');
tic; [bhpf_gray1, H_bhpf, spectrum_bhpf] = bhpf(imgGray1, D0, n_butterworth, usePadding); time_bhpf = toc;
fprintf('Done (%.4fs)\n\n', time_bhpf);

figure('Name', 'Test 1: HPF Grayscale - Basic Results', 'Position', [50 50 1400 900]);

subplot(3, 4, 1);
imshow(imgGray1);
title('Original Grayscale');

subplot(3, 4, 2);
imshow(ihpf_gray1);
title(sprintf('IHPF D0=%d', D0));

subplot(3, 4, 3);
imshow(ghpf_gray1);
title(sprintf('GHPF D0=%d', D0));

subplot(3, 4, 4);
imshow(bhpf_gray1);
title(sprintf('BHPF D0=%d n=%d', D0, n_butterworth));

subplot(3, 4, 5);
text(0.5, 0.5, 'Filter H(u,v)', 'HorizontalAlignment', 'center', 'FontSize', 11, 'FontWeight', 'bold');
axis off;

subplot(3, 4, 6);
imshow(H_ihpf);
title('IHPF Filter');
colorbar;

subplot(3, 4, 7);
imshow(H_ghpf);
title('GHPF Filter');
colorbar;

subplot(3, 4, 8);
imshow(H_bhpf);
title('BHPF Filter');
colorbar;

subplot(3, 4, 9);
imshow(log(1 + abs(fftshift(fft2(double(imgGray1))))), []);
title('Original Spectrum');
colormap(gca, 'jet');

subplot(3, 4, 10);
imshow(spectrum_ihpf.filtered, []);
title('IHPF Spectrum');
colormap(gca, 'jet');

subplot(3, 4, 11);
imshow(spectrum_ghpf.filtered, []);
title('GHPF Spectrum');
colormap(gca, 'jet');

subplot(3, 4, 12);
imshow(spectrum_bhpf.filtered, []);
title('BHPF Spectrum');
colormap(gca, 'jet');

sgtitle('Test 1: High-Pass Filtering - Grayscale', 'FontSize', 14, 'FontWeight', 'bold');

%% 5. TEST 2 - 3D FILTER VISUALIZATION 
fprintf('5. TEST 2: 3D FILTER VISUALIZATION \n');
fprintf('   Mesh plot untuk melihat karakteristik filter\n\n');

figure('Name', 'Test 2: 3D Filter Visualization (mesh)', 'Position', [100 100 1400 400]);

subplot(1, 3, 1);
mesh(H_ihpf);
title('IHPF - 3D View');
xlabel('u'); ylabel('v'); zlabel('H(u,v)');
colormap(gca, 'jet');
view(45, 30);

subplot(1, 3, 2);
mesh(H_ghpf);
title('GHPF - 3D View');
xlabel('u'); ylabel('v'); zlabel('H(u,v)');
colormap(gca, 'jet');
view(45, 30);

subplot(1, 3, 3);
mesh(H_bhpf);
title(sprintf('BHPF (n=%d) - 3D View', n_butterworth));
xlabel('u'); ylabel('v'); zlabel('H(u,v)');
colormap(gca, 'jet');
view(45, 30);

sgtitle('3D Filter Visualization (Slide 21, 33, 39)', 'FontSize', 12, 'FontWeight', 'bold');

%% 6. TEST 3 - FILTER CROSS-SECTION (1D Profile)
fprintf('6. TEST 3: FILTER CROSS-SECTION (1D Profile)\n');
fprintf('   Menunjukkan karakteristik transisi filter\n\n');

figure('Name', 'Test 3: Filter Cross-Section', 'Position', [100 100 1400 400]);

centerRow = round(size(H_ihpf, 1) / 2);

subplot(1, 4, 1);
plot(H_ihpf(centerRow, :), 'b-', 'LineWidth', 2);
title('IHPF Profile');
xlabel('Frequency'); ylabel('H(u,v)');
grid on; ylim([0 1.1]);

subplot(1, 4, 2);
plot(H_ghpf(centerRow, :), 'r-', 'LineWidth', 2);
title('GHPF Profile');
xlabel('Frequency'); ylabel('H(u,v)');
grid on; ylim([0 1.1]);

subplot(1, 4, 3);
plot(H_bhpf(centerRow, :), 'g-', 'LineWidth', 2);
title(sprintf('BHPF (n=%d) Profile', n_butterworth));
xlabel('Frequency'); ylabel('H(u,v)');
grid on; ylim([0 1.1]);

subplot(1, 4, 4);
plot(H_ihpf(centerRow, :), 'b-', 'LineWidth', 2.5); hold on;
plot(H_ghpf(centerRow, :), 'r-', 'LineWidth', 2.5);
plot(H_bhpf(centerRow, :), 'g-', 'LineWidth', 2.5);
legend('IHPF (Tajam)', 'GHPF (Smooth)', sprintf('BHPF (n=%d)', n_butterworth), 'Location', 'best');
title('Combined Comparison');
xlabel('Frequency'); ylabel('H(u,v)');
grid on; ylim([0 1.1]);

sgtitle('Filter Cross-Section - Karakteristik Transisi', 'FontSize', 12);

%% 7. TEST 4 - RINGING EFFECT DEMONSTRATION 
fprintf('7. TEST 4: RINGING EFFECT DEMONSTRATION\n');
fprintf('   IHPF menimbulkan ringing, GHPF tidak\n\n');

D0_ring = 30;  
[ihpf_ring, ~, ~] = ihpf(imgGray1, D0_ring, usePadding);
[ghpf_ring, ~, ~] = ghpf(imgGray1, D0_ring, usePadding);
diff_ring = abs(double(ihpf_ring) - double(ghpf_ring));

figure('Name', 'Test 4: Ringing Effect (Slide 24-25)', 'Position', [50 50 1400 500]);

subplot(1, 4, 1);
imshow(imgGray1);
title('Original');

subplot(1, 4, 2);
imshow(ihpf_ring);
title(sprintf('IHPF D0=%d\nADA RINGING', D0_ring), 'Color', 'red');

subplot(1, 4, 3);
imshow(ghpf_ring);
title(sprintf('GHPF D0=%d\nTIDAK ADA RINGING', D0_ring), 'Color', 'green');

subplot(1, 4, 4);
imshow(diff_ring, []);
title('Difference (Ringing Artifact)');
colorbar; colormap(gca, 'hot');

sgtitle('Ringing Effect: IHPF (Diskontinuitas) vs GHPF (Smooth)', 'FontSize', 14);

fprintf('   Kesimpulan: IHPF menimbulkan ringing karena transisi tajam\n');
fprintf('               GHPF tidak ada ringing karena transisi smooth\n\n');

%% 8. TEST 5 - EFFECT OF CUTOFF FREQUENCY (D0)
fprintf('8. TEST 5: EFFECT OF CUTOFF FREQUENCY (D0)\n');
fprintf('   Testing berbagai nilai D0 pada GHPF\n\n');

D0_values = [10, 30, 50, 80, 120];

figure('Name', 'Test 5: Effect of D0 on GHPF', 'Position', [50 50 1400 800]);

for i = 1:length(D0_values)
    D0_test = D0_values(i);
    [result_test, ~, ~] = ghpf(imgGray1, D0_test, usePadding);

    subplot(2, 3, i);
    imshow(result_test);
    title(sprintf('GHPF D0=%d', D0_test));

    fprintf('   D0=%d: Mean intensity = %.2f\n', D0_test, mean(result_test(:)));
end

subplot(2, 3, 6);
imshow(imgGray1);
title('Original');

sgtitle('Effect of Cutoff Frequency (D0) on GHPF', 'FontSize', 14);
fprintf('\n');

%% 9. TEST 6 - EFFECT OF BUTTERWORTH ORDER
fprintf('9. TEST 6: EFFECT OF BUTTERWORTH ORDER (n)\n');
fprintf('   Testing berbagai orde Butterworth\n\n');

n_values = [1, 2, 4, 8];

figure('Name', 'Test 6: Effect of Butterworth Order', 'Position', [50 50 1400 800]);

for i = 1:length(n_values)
    n_test = n_values(i);
    [result_test, H_test, ~] = bhpf(imgGray1, D0, n_test, usePadding);

    subplot(2, 4, i);
    imshow(result_test);
    title(sprintf('BHPF n=%d', n_test));

    subplot(2, 4, i+4);
    plot(H_test(centerRow, :), 'LineWidth', 2);
    title(sprintf('Profile n=%d', n_test));
    xlabel('Frequency'); ylabel('H(u,v)');
    grid on; ylim([0 1.1]);

    fprintf('   n=%d: Transisi %s\n', n_test, iif(n_test < 3, 'smooth', 'tajam'));
end

sgtitle(sprintf('Effect of Butterworth Order (D0=%d)', D0), 'FontSize', 14);
fprintf('\n');

%% 10. TEST 7 - COLOR IMAGE HPF
fprintf('10. TEST 7: HIGH-PASS FILTERING - COLOR IMAGE\n');
fprintf('    Filtering dilakukan per-channel (R, G, B)\n\n');

fprintf('    Applying IHPF on color... ');
tic; [ihpf_color, ~, ~] = ihpf(imgColor1, D0, usePadding); t1 = toc;
fprintf('Done (%.4fs)\n', t1);

fprintf('    Applying GHPF on color... ');
tic; [ghpf_color, ~, ~] = ghpf(imgColor1, D0, usePadding); t2 = toc;
fprintf('Done (%.4fs)\n', t2);

fprintf('    Applying BHPF on color... ');
tic; [bhpf_color, ~, ~] = bhpf(imgColor1, D0, n_butterworth, usePadding); t3 = toc;
fprintf('Done (%.4fs)\n\n', t3);

figure('Name', 'Test 7: HPF on Color Image', 'Position', [50 50 1400 900]);

subplot(3, 4, 1);
imshow(imgColor1);
title('Original RGB');

subplot(3, 4, 2);
imshow(ihpf_color);
title('IHPF Result');

subplot(3, 4, 3);
imshow(ghpf_color);
title('GHPF Result');

subplot(3, 4, 4);
imshow(bhpf_color);
title('BHPF Result');

subplot(3, 4, 5);
text(0.5, 0.5, 'GHPF Per-Channel', 'HorizontalAlignment', 'center', 'FontSize', 11);
axis off;

subplot(3, 4, 6);
imshow(ghpf_color(:,:,1));
title('Red Channel');

subplot(3, 4, 7);
imshow(ghpf_color(:,:,2));
title('Green Channel');

subplot(3, 4, 8);
imshow(ghpf_color(:,:,3));
title('Blue Channel');

subplot(3, 4, 9);
gray_orig = rgb2gray(imgColor1);
imshow(gray_orig);
title('Grayscale Original');

subplot(3, 4, 10);
gray_ihpf = rgb2gray(ihpf_color);
imshow(gray_ihpf);
title('IHPF Edges');

subplot(3, 4, 11);
gray_ghpf = rgb2gray(ghpf_color);
imshow(gray_ghpf);
title('GHPF Edges');

subplot(3, 4, 12);
gray_bhpf = rgb2gray(bhpf_color);
imshow(gray_bhpf);
title('BHPF Edges');

sgtitle('High-Pass Filtering on RGB Image', 'FontSize', 14, 'FontWeight', 'bold');

%% 11. TEST 8 - SIDE-BY-SIDE COMPARISON
fprintf('11. TEST 8: SIDE-BY-SIDE COMPARISON\n\n');

figure('Name', 'Test 8: Side-by-Side Comparison', 'Position', [50 50 1400 400]);

% Grayscale
subplot(1, 2, 1);
gray_comparison = [imgGray1, ones(size(imgGray1,1), 10)*255, ...
                   uint8(ihpf_gray1*255), ones(size(imgGray1,1), 10)*255, ...
                   uint8(ghpf_gray1*255), ones(size(imgGray1,1), 10)*255, ...
                   uint8(bhpf_gray1*255)];
imshow(gray_comparison);
title('Grayscale: Original | IHPF | GHPF | BHPF', 'FontSize', 12);

% Color
subplot(1, 2, 2);
white_sep = ones(size(imgColor1,1), 10, 3);
color_comparison = [imgColor1, white_sep, ...
                    ihpf_color, white_sep, ...
                    ghpf_color, white_sep, ...
                    bhpf_color];
imshow(color_comparison);
title('Color: Original | IHPF | GHPF | BHPF', 'FontSize', 12);

sgtitle('Side-by-Side Comparison', 'FontSize', 14, 'FontWeight', 'bold');

%% 12. TEST 9 - COMPARISON
fprintf('12. TEST 9: COMPARISON\n');
fprintf('    Berbagai D0 untuk semua filter\n\n');

D0_compare = [20, 40, 60];

figure('Name', 'Test 9: Comprehensive Comparison', 'Position', [50 50 1400 900]);

subplot(4, length(D0_compare)+1, 1);
imshow(imgGray2);
title('Original', 'FontWeight', 'bold');

for i = 1:length(D0_compare)
    D0_c = D0_compare(i);

    [r_ihpf, H_ihpf_c, ~] = ihpf(imgGray2, D0_c, usePadding);
    [r_ghpf, H_ghpf_c, ~] = ghpf(imgGray2, D0_c, usePadding);
    [r_bhpf, H_bhpf_c, ~] = bhpf(imgGray2, D0_c, n_butterworth, usePadding);

    subplot(4, length(D0_compare)+1, i+1);
    imshow(r_ihpf);
    title(sprintf('IHPF D0=%d', D0_c));

    subplot(4, length(D0_compare)+1, length(D0_compare)+1 + i+1);
    imshow(r_ghpf);
    title(sprintf('GHPF D0=%d', D0_c));

    subplot(4, length(D0_compare)+1, 2*(length(D0_compare)+1) + i+1);
    imshow(r_bhpf);
    title(sprintf('BHPF D0=%d', D0_c));

    subplot(4, length(D0_compare)+1, 3*(length(D0_compare)+1) + i+1);
    centerR = round(size(H_ihpf_c, 1) / 2);
    plot(H_ihpf_c(centerR, :), 'b-', 'LineWidth', 1.5); hold on;
    plot(H_ghpf_c(centerR, :), 'r-', 'LineWidth', 1.5);
    plot(H_bhpf_c(centerR, :), 'g-', 'LineWidth', 1.5);
    legend('IHPF', 'GHPF', 'BHPF', 'Location', 'best', 'FontSize', 7);
    title(sprintf('Profile D0=%d', D0_c), 'FontSize', 9);
    grid on; ylim([0 1.1]);
end

subplot(4, length(D0_compare)+1, length(D0_compare)+1 + 1);
text(0.5, 0.5, 'GHPF', 'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');
axis off;

subplot(4, length(D0_compare)+1, 2*(length(D0_compare)+1) + 1);
text(0.5, 0.5, 'BHPF', 'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');
axis off;

subplot(4, length(D0_compare)+1, 3*(length(D0_compare)+1) + 1);
text(0.5, 0.5, 'Profiles', 'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');
axis off;

sgtitle('Comprehensive HPF Comparison', 'FontSize', 14, 'FontWeight', 'bold');

%% 13. SUMMARY
fprintf('\n================================================================\n');
fprintf('SUMMARY\n');
fprintf('================================================================\n');
fprintf('Parameter:\n');
fprintf('  - D0 (cutoff frequency): %d\n', D0);
fprintf('  - Butterworth order (n): %d\n', n_butterworth);
fprintf('  - Padding: %s\n', iif(usePadding, '2x (P=2M, Q=2N)', 'No padding'));
fprintf('\nWaktu Komputasi (Grayscale):\n');
fprintf('  - IHPF: %.4f detik\n', time_ihpf);
fprintf('  - GHPF: %.4f detik\n', time_ghpf);
fprintf('  - BHPF: %.4f detik\n', time_bhpf);
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
