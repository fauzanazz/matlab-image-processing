clear; clc; close all;

disp('=== TASK 3: HISTOGRAM EQUALIZATION TESTING ===');
disp('Testing custom histogram equalization implementation...');
disp(' ');

test_images = {};
image_names = {};
image_descriptions = {};

% Test image categories
test_categories = {
    {'test_images/low_contrast_portrait.jpg', 'Low contrast portrait'};
    {'test_images/low_contrast_texture.jpg', 'Low contrast texture'};  
    {'test_images/mixed_contrast_objects.png', 'Mixed contrast objects'};
    {'test_images/natural_scene.jpg', 'Natural scene'};
    {'test_images/color_image.jpg', 'Color image'};
    {'color_landscape.jpg', 'Color landscape'};
};

fprintf('Loading test images:\n');
for i = 1:length(test_categories)
    filename = test_categories{i}{1};
    description = test_categories{i}{2};
    
    try
        img = imread(filename);
        test_images{end+1} = img;
        image_names{end+1} = filename;
        image_descriptions{end+1} = description;
        fprintf('✓ %s (%s)\n', filename, description);
    catch
        fprintf('✗ %s not found\n', filename);
    end
end

if isempty(test_images)
    error('No test images found. Please ensure MATLAB sample images are available.');
end

fprintf('\nLoaded %d test images for evaluation.\n\n', length(test_images));

%% Test 1: Grayscale Images - Basic Functionality
disp('=== TEST 1: Grayscale Histogram Equalization ===');

for i = 1:length(test_images)
    img = test_images{i};
    name = image_names{i};
    description = image_descriptions{i};
    
    if size(img, 3) == 3
        img_gray = rgb2gray(img);
        fprintf('Testing %s (converted to grayscale) - %s\n', name, description);
    else
        img_gray = img;
        fprintf('Testing %s - %s\n', name, description);
    end
    
    fprintf('  Applying histogram equalization...\n');
    equalized = histogram_equalization(img_gray);
    
    display_equalization_results(img_gray, equalized, true);
    
    fprintf('  ✓ Completed: %s\n\n', name);
end

%% Test 2: Color Images - Multi-channel Processing
disp('=== TEST 2: Color Image Histogram Equalization ===');

for i = 1:length(test_images)
    img = test_images{i};
    name = image_names{i};
    description = image_descriptions{i};
    
    if size(img, 3) == 3
        fprintf('Testing color image: %s - %s\n', name, description);
        fprintf('  Applying RGB channel equalization...\n');
        equalized_color = histogram_equalization(img);
        display_equalization_results(img, equalized_color, true);
        
        fprintf('  ✓ Completed color processing: %s\n\n', name);
    end
end