clear; clc; close all;

disp('=== TASK 2: IMAGE ENHANCEMENT TESTING ===');
disp('Testing all enhancement methods...');
disp(' ');

test_images = {};
image_names = {};

% Grayscale test images
gray_files = {'test_images/ori.jpg', 'test_images/gray2.jpg', 'test_images/gray3.jpg', 'test_images/gray4.jpg'};
for i = 1:length(gray_files)
    try
        img = imread(gray_files{i});
        test_images{end+1} = img;
        image_names{end+1} = gray_files{i};
        fprintf('Loaded: %s\n', gray_files{i});
        break; 
    catch
        continue;
    end
end

% Color test images  
color_files = {'test_images/color1.jpg', 'test_images/color2.jpg', 'test_images/color3.jpg'};
for i = 1:length(color_files)
    try
        img = imread(color_files{i});
        test_images{end+1} = img;
        image_names{end+1} = color_files{i};
        fprintf(' Loaded: %s\n', color_files{i});
        break; 
    catch
        continue;
    end
end

if isempty(test_images)
    error('No test images found.');
end

%% Test 1: Image Brightening
disp(' ');
disp('=== TEST 1: Image Brightening ===');

for i = 1:length(test_images)
    img = test_images{i};
    name = image_names{i};
    
    fprintf('Testing %s...\n', name);
    
    % Test different brightening parameters
    test_params = [
        struct('a', 1.0, 'b', 50);    % Only brightness
        struct('a', 1.5, 'b', 0);     % Only contrast
        struct('a', 1.2, 'b', 30);    % Both
        struct('a', 0.8, 'b', -20);   % Darken
    ];
    
    for j = 1:length(test_params)
        a = test_params(j).a;
        b = test_params(j).b;
        
        result = image_brightening(img, a, b);
        method_name = sprintf('Brightening (a=%.1f, b=%d)', a, b);
        params = struct('a', a, 'b', b);
        
        display_enhancement_results(img, result, method_name, params);
        
        if j == 1, break; end 
    end
    
    if i == 1, break; end 
end

%% Test 2: Image Negative
disp(' ');
disp('=== TEST 2: Image Negative ===');

for i = 1:length(test_images)
    img = test_images{i};
    name = image_names{i};
    
    fprintf('Testing negative transformation on %s...\n', name);
    negative_img = image_negative(img);
    display_enhancement_results(img, negative_img, 'Negative', struct());
    double_negative = image_negative(negative_img);
    display_enhancement_results(negative_img, double_negative, 'Double Negative (Back to Original)', struct());
    
    if i == 1, break; end 
end

%% Test 3: Log Transformation  
disp(' ');
disp('=== TEST 3: Log Transformation ===');

for i = 1:length(test_images)
    img = test_images{i};
    name = image_names{i};
    
    fprintf('Testing log transformation on %s...\n', name);
    
    c_values = [1, 30, 50, 100];
    
    for j = 1:length(c_values)
        c = c_values(j);
        
        result = log_transformation(img, c);
        method_name = sprintf('Log Transform (c=%d)', c);
        params = struct('c', c);
        
        display_enhancement_results(img, result, method_name, params);
        
        if j == 1, break; end 
    end
    
    if i == 1, break; end 
end

%% Test 4: Power Transformation
disp(' ');
disp('=== TEST 4: Power Transformation ===');

for i = 1:length(test_images)
    img = test_images{i};
    name = image_names{i};
    
    fprintf('Testing power transformation on %s...\n', name);
    
    % Test different gamma values
    gamma_tests = [
        struct('c', 1, 'gamma', 0.5);   % Brighten (gamma < 1)
        struct('c', 1, 'gamma', 1.0);   % No change
        struct('c', 1, 'gamma', 2.0);   % Darken (gamma > 1) 
        struct('c', 2, 'gamma', 0.7);   % Different c and gamma
    ];
    
    for j = 1:length(gamma_tests)
        c = gamma_tests(j).c;
        gamma = gamma_tests(j).gamma;
        
        result = power_transformation(img, c, gamma);
        method_name = sprintf('Power Transform (c=%.1f, γ=%.1f)', c, gamma);
        params = struct('c', c, 'gamma', gamma);
        
        display_enhancement_results(img, result, method_name, params);
        
        if j == 1, break; end
    end
    
    if i == 1, break; end
end

%% Test 5: Contrast Stretching
disp(' ');
disp('=== TEST 5: Contrast Stretching ===');

for i = 1:length(test_images)
    img = test_images{i};
    name = image_names{i};
    
    fprintf('Testing contrast stretching on %s...\n', name);
    
    result = contrast_stretching(img);
    display_enhancement_results(img, result, 'Contrast Stretching (Auto)', struct());
end

%% Test 6: Create Low Contrast Test Image
disp(' ');
disp('=== TEST 6: Low Contrast Enhancement ===');

if ~isempty(test_images)
    original = test_images{1};
    if size(original, 3) == 3
        original = rgb2gray(original);
    end
    
    low_contrast = uint8(double(original) * 0.3 + 85);
    fprintf('Created low contrast test image...\n');
    
    methods = {
        @(img) image_brightening(img, 2.0, 0),
        @(img) log_transformation(img, 50),  
        @(img) power_transformation(img, 1, 0.5),
        @(img) contrast_stretching(img)
    };
    
    method_names = {
        'Brightening (a=2.0)',
        'Log Transform (c=50)', 
        'Power Transform (γ=0.5)',
        'Contrast Stretching'
    };
    
    for j = 1:length(methods)
        result = methods{j}(low_contrast);
        display_enhancement_results(low_contrast, result, method_names{j}, struct());
    end
end