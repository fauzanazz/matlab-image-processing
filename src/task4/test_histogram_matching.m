clear; clc; close all;

disp('=== TASK 4: HISTOGRAM MATCHING TESTING ===');
disp('Testing custom histogram specification/matching implementation...');
disp(' ');

test_pairs = {
    {'test_images/low_contrast_portrait.jpg', 'test_images/natural_scene.jpg', 'Portrait to Natural'};
    {'test_images/mixed_contrast_objects.png', 'test_images/color_image.jpg', 'Objects to Color'};
};

matlab_samples = {
    {'cameraman.tif', 'rice.png', 'Cameraman to Rice'};
    {'coins.png', 'circuit.tif', 'Coins to Circuit'};
    {'peppers.png', 'autumn.tif', 'Peppers to Autumn'};
};

loaded_pairs = {};
pair_names = {};

fprintf('Loading test image pairs:\n');

for i = 1:length(test_pairs)
    input_file = test_pairs{i}{1};
    ref_file = test_pairs{i}{2};
    pair_name = test_pairs{i}{3};
    
    try
        input_img = imread(input_file);
        ref_img = imread(ref_file);
        
        if ~isequal(size(input_img), size(ref_img))
            ref_img = imresize(ref_img, [size(input_img,1), size(input_img,2)]);
            fprintf('  ⚠ Resized reference image to match input\n');
        end
        
        loaded_pairs{end+1} = {input_img, ref_img};
        pair_names{end+1} = pair_name;
        fprintf('✓ %s\n', pair_name);
    catch
        fprintf('✗ %s (files not found)\n', pair_name);
    end
end

% Try MATLAB sample images as fallback
for i = 1:length(matlab_samples)
    input_file = matlab_samples{i}{1};
    ref_file = matlab_samples{i}{2};
    pair_name = matlab_samples{i}{3};
    
    try
        input_img = imread(input_file);
        ref_img = imread(ref_file);
        
        if ~isequal(size(input_img), size(ref_img))
            ref_img = imresize(ref_img, [size(input_img,1), size(input_img,2)]);
        end
        
        loaded_pairs{end+1} = {input_img, ref_img};
        pair_names{end+1} = pair_name;
        fprintf('✓ %s (MATLAB sample)\n', pair_name);
    catch
        fprintf('✗ %s (not available)\n', pair_name);
    end
end

if isempty(loaded_pairs)
    fprintf('Creating synthetic test images...\n');
    dark_img = uint8(rand(200, 200) * 100 + 20);  % Dark image (20-120)
    bright_img = uint8(rand(200, 200) * 100 + 155); % Bright image (155-255)
    
    loaded_pairs{1} = {dark_img, bright_img};
    pair_names{1} = 'Synthetic: Dark to Bright';
    
    fprintf('✓ Synthetic: Dark to Bright\n');
end

fprintf('\nLoaded %d test image pairs for evaluation.\n\n', length(loaded_pairs));

%% Test 1: Basic Histogram Matching - Grayscale
disp('=== TEST 1: Grayscale Histogram Matching ===');

for i = 1:min(2, length(loaded_pairs))
    input_img = loaded_pairs{i}{1};
    ref_img = loaded_pairs{i}{2};
    pair_name = pair_names{i};
    
    if size(input_img, 3) == 3
        input_gray = rgb2gray(input_img);
    else
        input_gray = input_img;
    end
    
    if size(ref_img, 3) == 3
        ref_gray = rgb2gray(ref_img);
    else
        ref_gray = ref_img;
    end
    
    fprintf('Testing grayscale matching: %s\n', pair_name);
    fprintf('  Applying histogram matching...\n');
    matched_img = histogram_matching(input_gray, ref_gray);
    display_matching_results(input_gray, ref_gray, matched_img, true);
    fprintf('  ✓ Completed grayscale matching: %s\n\n', pair_name);
end

%% Test 2: Color Image Histogram Matching
disp('=== TEST 2: Color Image Histogram Matching ===');

for i = 1:min(2, length(loaded_pairs))
    input_img = loaded_pairs{i}{1};
    ref_img = loaded_pairs{i}{2};
    pair_name = pair_names{i};
    
    if size(input_img, 3) == 3 && size(ref_img, 3) == 3
        fprintf('Testing color matching: %s\n', pair_name);
        fprintf('  Applying RGB channel matching...\n');
        matched_color = histogram_matching(input_img, ref_img);
        display_matching_results(input_img, ref_img, matched_color, true);
        fprintf('  ✓ Completed color matching: %s\n\n', pair_name);
    else
        fprintf('Skipping color test for: %s (not both color images)\n', pair_name);
    end
end

%% Test 3: Cross-Type Matching (Color to Grayscale, etc.)
disp('=== TEST 3: Cross-Type Histogram Matching ===');

if length(loaded_pairs) >= 1
    input_img = loaded_pairs{1}{1};
    ref_img = loaded_pairs{1}{2};
    
    test_combinations = {
        {'Color Input to Grayscale Ref', input_img, rgb2gray(ref_img)};
        {'Grayscale Input to Color Ref', rgb2gray(input_img), ref_img};
    };
    
    for j = 1:length(test_combinations)
        test_name = test_combinations{j}{1};
        test_input = test_combinations{j}{2};
        test_ref = test_combinations{j}{3};
        
        fprintf('Testing %s...\n', test_name);
        
        try
            matched_result = histogram_matching(test_input, test_ref);
            display_matching_results(test_input, test_ref, matched_result, false);
            fprintf('  ✓ Completed: %s\n\n', test_name);
        catch err
            fprintf('  ✗ Error in %s: %s\n\n', test_name, err.message);
        end
    end
end

%% Test 4: Edge Cases and Special Scenarios
disp('=== TEST 4: Edge Cases and Special Scenarios ===');

fprintf('Creating special test cases...\n');
% Test Case 1: Uniform images
uniform_dark = uint8(ones(100, 100) * 50);
uniform_bright = uint8(ones(100, 100) * 200);

fprintf('Testing uniform images (all pixels same value)...\n');
try
    uniform_result = histogram_matching(uniform_dark, uniform_bright);
    display_matching_results(uniform_dark, uniform_bright, uniform_result, false);
    fprintf('  ✓ Uniform image test completed\n');
catch err
    fprintf('  ✗ Uniform image test error: %s\n', err.message);
end

% Test Case 2: Binary images
binary_input = uint8((rand(100, 100) > 0.7) * 255);
binary_ref = uint8((rand(100, 100) > 0.3) * 255);

fprintf('Testing binary images (only 0 and 255 values)...\n');
try
    binary_result = histogram_matching(binary_input, binary_ref);
    display_matching_results(binary_input, binary_ref, binary_result, false);
    fprintf('  ✓ Binary image test completed\n');
catch err
    fprintf('  ✗ Binary image test error: %s\n', err.message);
end

% Test Case 3: High contrast vs Low contrast
high_contrast = uint8([zeros(50, 100); ones(50, 100) * 255]);
low_contrast = uint8(rand(100, 100) * 50 + 100);

fprintf('Testing high contrast to low contrast matching...\n');
try
    contrast_result = histogram_matching(high_contrast, low_contrast);
    display_matching_results(high_contrast, low_contrast, contrast_result, false);
    fprintf('  ✓ Contrast matching test completed\n');
catch err
    fprintf('  ✗ Contrast matching test error: %s\n', err.message);
end

%% Test 5: Quality Assessment and Metrics
disp('=== TEST 5: Quality Assessment and Metrics ===');

if ~isempty(loaded_pairs)
    fprintf('Evaluating matching quality for different image pairs...\n');
    
    quality_results = [];
    
    for i = 1:min(3, length(loaded_pairs))
        input_img = loaded_pairs{i}{1};
        ref_img = loaded_pairs{i}{2};
        pair_name = pair_names{i};
        
        if size(input_img, 3) == 3
            input_gray = rgb2gray(input_img);
        else
            input_gray = input_img;
        end
        
        if size(ref_img, 3) == 3
            ref_gray = rgb2gray(ref_img);
        else
            ref_gray = ref_img;
        end
        
        fprintf('  Analyzing: %s\n', pair_name);
        matched_img = histogram_matching(input_gray, ref_gray);
        analysis = analyze_histogram_matching(input_gray, ref_gray, matched_img);
        quality_results(i).name = pair_name;
        quality_results(i).similarity = analysis.histogram_similarity;
        quality_results(i).quality = analysis.overall_quality;
        quality_results(i).success = analysis.matching_success;
        
        fprintf('    Similarity: %.3f, Quality: %s\n', ...
            analysis.histogram_similarity, analysis.overall_quality);
    end
    
    fprintf('\n--- QUALITY ASSESSMENT SUMMARY ---\n');
    successful_matches = 0;
    for i = 1:length(quality_results)
        fprintf('%s: %.3f (%s)\n', quality_results(i).name, ...
            quality_results(i).similarity, quality_results(i).quality);
        if quality_results(i).success
            successful_matches = successful_matches + 1;
        end
    end
    fprintf('Successful matches: %d/%d\n', successful_matches, length(quality_results));
end

%% Test 6: Performance Evaluation
disp('=== TEST 6: Performance Evaluation ===');

fprintf('Evaluating performance with different image sizes...\n');

sizes = [64, 128, 256];
times_grayscale = zeros(size(sizes));
times_color = zeros(size(sizes));

for i = 1:length(sizes)
    sz = sizes(i);
    test_input = uint8(rand(sz, sz) * 255);
    test_ref = uint8(rand(sz, sz) * 255);
    test_input_color = uint8(rand(sz, sz, 3) * 255);
    test_ref_color = uint8(rand(sz, sz, 3) * 255);
    
    tic;
    for rep = 1:3 
        matched_gray = histogram_matching(test_input, test_ref);
    end
    times_grayscale(i) = toc / 3;
    
    tic;
    for rep = 1:3
        matched_color = histogram_matching(test_input_color, test_ref_color);
    end
    times_color(i) = toc / 3;
    
    fprintf('  Size %dx%d: Grayscale=%.3fs, Color=%.3fs\n', ...
        sz, sz, times_grayscale(i), times_color(i));
end

figure('Name', 'Histogram Matching Performance');
plot(sizes, times_grayscale, 'bo-', 'LineWidth', 2, 'DisplayName', 'Grayscale');
hold on;
plot(sizes, times_color, 'ro-', 'LineWidth', 2, 'DisplayName', 'Color (3 channels)');
hold off;
xlabel('Image Size (pixels)');
ylabel('Execution Time (seconds)');
title('Performance Analysis: Histogram Matching');
legend();
grid on;
set(gca, 'XScale', 'log', 'YScale', 'log');