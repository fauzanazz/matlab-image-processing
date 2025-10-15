%% Run All Tests for Task 7: Motion Blur and Wiener Deconvolution
% This script runs all test and demo files

clear; close all; clc;

fprintf('====================================================\n');
fprintf('    TASK 7: MOTION BLUR & WIENER DECONVOLUTION    \n');
fprintf('====================================================\n\n');

%% 1. Simple Demo
fprintf('1. Running simple demo...\n');
fprintf('   File: demo_wiener_deblur.m\n\n');
pause(1);

try
    demo_wiener_deblur;
    fprintf('   ✓ Demo completed successfully!\n\n');
catch ME
    fprintf('   ✗ Error in demo: %s\n\n', ME.message);
end

pause(2);

%% 2. NSR Analysis
fprintf('2. Running NSR parameter analysis...\n');
fprintf('   File: analyze_nsr_effect.m\n\n');
pause(1);

try
    analyze_nsr_effect;
    fprintf('   ✓ NSR analysis completed successfully!\n\n');
catch ME
    fprintf('   ✗ Error in NSR analysis: %s\n\n', ME.message);
end

pause(2);

%% 3. Comprehensive Test
fprintf('3. Running comprehensive tests...\n');
fprintf('   File: test_motion_deblur.m\n\n');
pause(1);

try
    test_motion_deblur;
    fprintf('   ✓ Comprehensive test completed successfully!\n\n');
catch ME
    fprintf('   ✗ Error in comprehensive test: %s\n\n', ME.message);
end

pause(2);

%% 4. Comparison with Built-in
fprintf('4. Comparing with MATLAB built-in function...\n');
fprintf('   File: compare_wiener_filters.m\n\n');
pause(1);

try
    compare_wiener_filters;
    fprintf('   ✓ Comparison completed successfully!\n\n');
catch ME
    fprintf('   ✗ Error in comparison: %s\n\n', ME.message);
end

%% Summary
fprintf('====================================================\n');
fprintf('                  TEST SUMMARY                     \n');
fprintf('====================================================\n\n');
fprintf('All tests have been executed.\n');
fprintf('Check the generated figures for visual results.\n\n');
fprintf('Functions implemented:\n');
fprintf('  ✓ motion_blur.m        - Motion blur simulation\n');
fprintf('  ✓ wiener_filter.m      - Custom Wiener deconvolution\n\n');
fprintf('Key features:\n');
fprintf('  • Supports grayscale and color images\n');
fprintf('  • Custom Wiener filter (no built-in used)\n');
fprintf('  • Frequency domain implementation\n');
fprintf('  • Comprehensive testing and validation\n\n');
fprintf('====================================================\n');

