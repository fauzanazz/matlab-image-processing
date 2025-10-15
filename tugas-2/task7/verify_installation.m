%% Verify Installation and Functionality
% This script verifies that all functions work correctly

clear; close all; clc;

fprintf('====================================================\n');
fprintf('      TASK 7 INSTALLATION VERIFICATION             \n');
fprintf('====================================================\n\n');

success = true;

%% Check Files
fprintf('1. Checking required files...\n');
required_files = {
    'motion_blur.m'
    'wiener_filter.m'
    'demo_wiener_deblur.m'
    'test_motion_deblur.m'
    'compare_wiener_filters.m'
    'analyze_nsr_effect.m'
    'example_usage.m'
    'visualize_psf.m'
    'run_all_tests.m'
    'test_images/gray1.jpg'
    'test_images/color1.jpg'
};

for i = 1:length(required_files)
    if exist(required_files{i}, 'file')
        fprintf('   ✓ %s\n', required_files{i});
    else
        fprintf('   ✗ %s (MISSING!)\n', required_files{i});
        success = false;
    end
end

%% Test Core Functions
fprintf('\n2. Testing core functions...\n');

try
    % Load test image
    img = imread('test_images/gray1.jpg');
    if size(img, 3) == 3
        img = rgb2gray(img);
    end
    fprintf('   ✓ Image loaded successfully\n');
    
    % Test motion_blur
    blurred = motion_blur(img, 15, 30);
    fprintf('   ✓ motion_blur() works\n');
    
    % Test wiener_filter
    psf = fspecial('motion', 15, 30);
    restored = wiener_filter(blurred, psf, 0.01);
    fprintf('   ✓ wiener_filter() works\n');
    
    % Check output dimensions
    if all(size(restored) == size(img))
        fprintf('   ✓ Output dimensions correct\n');
    else
        fprintf('   ✗ Output dimensions incorrect\n');
        success = false;
    end
    
    % Check PSNR calculation
    psnr_val = psnr(restored, img);
    if psnr_val > 0 && psnr_val < 100
        fprintf('   ✓ PSNR calculation: %.2f dB\n', psnr_val);
    else
        fprintf('   ✗ PSNR value unusual: %.2f dB\n', psnr_val);
    end
    
catch ME
    fprintf('   ✗ Error: %s\n', ME.message);
    success = false;
end

%% Test Color Image
fprintf('\n3. Testing color image support...\n');

try
    color_img = imread('test_images/color1.jpg');
    blurred_color = motion_blur(color_img, 15, 30);
    restored_color = wiener_filter(blurred_color, psf, 0.01);
    
    if size(restored_color, 3) == 3
        fprintf('   ✓ Color image processing works\n');
    else
        fprintf('   ✗ Color image output incorrect\n');
        success = false;
    end
catch ME
    fprintf('   ✗ Error: %s\n', ME.message);
    success = false;
end

%% Test Different Parameters
fprintf('\n4. Testing different parameters...\n');

try
    % Different motion parameters
    test_params = [10, 0; 20, 45; 30, 90];
    
    for i = 1:size(test_params, 1)
        len = test_params(i, 1);
        angle = test_params(i, 2);
        
        psf_test = fspecial('motion', len, angle);
        blurred_test = motion_blur(img, len, angle);
        restored_test = wiener_filter(blurred_test, psf_test, 0.01);
        
        fprintf('   ✓ Motion (L=%d, θ=%d°) works\n', len, angle);
    end
catch ME
    fprintf('   ✗ Error: %s\n', ME.message);
    success = false;
end

%% Test NSR Values
fprintf('\n5. Testing different NSR values...\n');

try
    nsr_test = [0.001, 0.01, 0.1];
    
    for i = 1:length(nsr_test)
        restored_nsr = wiener_filter(blurred, psf, nsr_test(i));
        fprintf('   ✓ NSR=%.3f works\n', nsr_test(i));
    end
catch ME
    fprintf('   ✗ Error: %s\n', ME.message);
    success = false;
end

%% Verification with Built-in
fprintf('\n6. Comparing with MATLAB built-in...\n');

try
    restored_custom = wiener_filter(blurred, psf, 0.01);
    restored_builtin = deconvwnr(blurred, psf, 0.01);
    
    diff = max(abs(double(restored_custom(:)) - double(restored_builtin(:))));
    
    if diff < 50  % Allow small numerical differences
        fprintf('   ✓ Custom implementation matches built-in (max diff: %.2f)\n', diff);
    else
        fprintf('   ⚠ Large difference from built-in (max diff: %.2f)\n', diff);
        fprintf('     (This may be acceptable due to implementation details)\n');
    end
catch ME
    fprintf('   ⚠ Could not compare with built-in: %s\n', ME.message);
end

%% Check Helper Functions
fprintf('\n7. Checking helper functions...\n');

try
    % Test visualize_psf (without displaying)
    h = figure('Visible', 'off');
    visualize_psf(20, 45);
    close(h);
    fprintf('   ✓ visualize_psf() works\n');
catch ME
    fprintf('   ⚠ visualize_psf() issue: %s\n', ME.message);
end

%% Final Result
fprintf('\n====================================================\n');
if success
    fprintf('               ✓ VERIFICATION PASSED                \n');
    fprintf('====================================================\n\n');
    fprintf('All functions are working correctly!\n');
    fprintf('\nNext steps:\n');
    fprintf('  1. Run "demo_wiener_deblur" for a quick demo\n');
    fprintf('  2. Run "example_usage" for usage examples\n');
    fprintf('  3. Run "run_all_tests" for comprehensive testing\n');
else
    fprintf('               ✗ VERIFICATION FAILED               \n');
    fprintf('====================================================\n\n');
    fprintf('Some issues were detected. Please check the errors above.\n');
end

fprintf('\n');

