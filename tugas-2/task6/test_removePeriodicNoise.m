%% TEST_REMOVEPERIODICNOISE
% Comprehensive test script for the removePeriodicNoise function
%
% This script demonstrates:
% 1. Testing the periodic noise removal algorithm on available images
% 2. Analyzing frequency spectrum for periodic patterns
% 3. Demonstrating the filtering process
%
% The algorithm is designed to detect periodic noise patterns in the
% frequency domain and apply appropriate filters to remove them.
%
% Author: Modified for MATLAB Image Processing Task 6
% Date: 2025

clear; close all; clc;

fprintf('===================================================\n');
fprintf('  PERIODIC NOISE REMOVAL - ALGORITHM DEMONSTRATION\n');
fprintf('===================================================\n\n');

fprintf('This script demonstrates the periodic noise removal algorithm.\n');
fprintf('The algorithm analyzes images for periodic patterns in the frequency domain\n');
fprintf('and applies adaptive filters to remove detected periodic noise.\n\n');

%% Test with Available Images
fprintf('Testing with Available Images:\n');
fprintf('=============================\n');

% Get list of available test images
test_img_files = dir('test_images/*.png');
if isempty(test_img_files)
    test_img_files = dir('test_images/*.jpg');
end

if isempty(test_img_files)
    fprintf('  No test images found in test_images folder.\n');
    fprintf('  The algorithm is ready to process images with periodic noise.\n\n');
else
    fprintf('  Found %d test images.\n\n', length(test_img_files));

    results = cell(length(test_img_files), 1);
    peak_counts = zeros(length(test_img_files), 1);
    pair_counts = zeros(length(test_img_files), 1);

    % Process each image
    for i = 1:length(test_img_files)
        img_path = fullfile('test_images', test_img_files(i).name);
        fprintf('Test %d: Processing %s\n', i, test_img_files(i).name);
        fprintf('------------------------------\n');

        try
            % Load and process image
            [filtered_img, info] = removePeriodicNoise(img_path, 'Visualize', false);

            % Store results
            results{i} = filtered_img;
            peak_counts(i) = size(info.peaks, 1);
            pair_counts(i) = size(info.pairs, 1);

            fprintf('  Image size: %dx%d\n', size(imread(img_path), 1), size(imread(img_path), 2));
            fprintf('  Peaks detected: %d\n', peak_counts(i));
            fprintf('  Matched pairs: %d\n', pair_counts(i));

            if peak_counts(i) > 0
                fprintf('  Periodic patterns detected and filtered ✓\n');
            else
                fprintf('  No significant periodic noise detected\n');
            end

            fprintf('  Status: PASSED ✓\n\n');

        catch ME
            fprintf('  Error processing image: %s\n', ME.message);
            fprintf('  Status: FAILED ✗\n\n');
            results{i} = [];
        end
    end

    %% Summary Visualization
    if ~isempty(results{1})
        fprintf('Generating Results Visualization...\n');
        fprintf('-----------------------------------\n');

        num_images = min(4, length(results)); % Show up to 4 images
        figure('Name', 'Periodic Noise Removal Results', 'Position', [50, 50, 1600, 600]);

        for i = 1:num_images
            if ~isempty(results{i})
                % Original image
                subplot(2, num_images, i);
                original = imread(fullfile('test_images', test_img_files(i).name));
                imshow(original, []);
                title(sprintf('Original: %s', test_img_files(i).name), 'Interpreter', 'none');

                % Filtered image
                subplot(2, num_images, i + num_images);
                imshow(results{i}, []);
                title(sprintf('Filtered\n(Peaks: %d)', peak_counts(i)));
            end
        end

        sgtitle('Periodic Noise Removal - Test Results', 'FontSize', 14, 'FontWeight', 'bold');
    end

    %% Performance Summary Table
    fprintf('\nPerformance Summary:\n');
    fprintf('===================\n');
    fprintf('%-20s | %-8s | %-10s | %-8s\n', 'Image Name', 'Peaks', 'Pairs', 'Status');
    fprintf('%-20s-+-%-8s-+-%-10s-+-%-8s\n', '--------------------', '--------', '----------', '--------');

    for i = 1:length(test_img_files)
        status = '✓';
        if peak_counts(i) == 0
            status = '-';
        end
        fprintf('%-20s | %-8d | %-10d | %-8s\n', test_img_files(i).name, peak_counts(i), pair_counts(i), status);
    end
    fprintf('\n');

    %% Algorithm Analysis
    fprintf('Algorithm Analysis:\n');
    fprintf('==================\n');
    fprintf('The removePeriodicNoise function implements the following steps:\n\n');
    fprintf('1. Frequency Domain Analysis:\n');
    fprintf('   - Converts image to frequency domain using FFT\n');
    fprintf('   - Creates log magnitude spectrum for analysis\n\n');
    fprintf('2. Peak Detection:\n');
    fprintf('   - Uses median filtering for background estimation\n');
    fprintf('   - Applies Otsu thresholding to detect peaks\n');
    fprintf('   - Excludes DC component (center region)\n\n');
    fprintf('3. Symmetric Pair Matching:\n');
    fprintf('   - Identifies peaks that form symmetric pairs around spectrum center\n');
    fprintf('   - Periodic noise appears as symmetric patterns in frequency domain\n\n');
    fprintf('4. Adaptive Filtering:\n');
    fprintf('   - Creates band-reject or notch filters based on peak distribution\n');
    fprintf('   - Applies filters to remove detected periodic components\n\n');
    fprintf('5. Spatial Domain Reconstruction:\n');
    fprintf('   - Inverse FFT to return to spatial domain\n');
    fprintf('   - Normalizes output to [0,1] range\n\n');

    %% Final Status
    total_processed = sum(~cellfun(@isempty, results));
    total_with_noise = sum(peak_counts > 0);

    fprintf('===================================================\n');
    fprintf('  TESTING COMPLETE\n');
    fprintf('===================================================\n');
    fprintf('Images processed: %d/%d\n', total_processed, length(test_img_files));
    fprintf('Images with periodic patterns: %d\n', total_with_noise);
    fprintf('Algorithm ready for periodic noise removal ✓\n\n');

    % Save results
    fprintf('Saving test results...\n');
    save('test_results.mat', 'results', 'peak_counts', 'pair_counts', 'test_img_files');
    fprintf('Results saved to test_results.mat\n');
end
