function ImageProcessingGUI()
    % ImageProcessingGUI - Main GUI for IF4073 Image Processing Assignment 2
    % Integrates all 7 tasks into a single tabbed interface
    %
    % Course: IF4073 Pemrosesan Citra Digital
    % Semester I Tahun 2025/2026

    % Create main figure
    fig = uifigure('Name', 'IF4073 - Image Processing Assignment 2', ...
                   'Position', [100, 100, 1200, 700], ...
                   'Color', [0.95 0.95 0.95]);

    % Create tab group
    tabGroup = uitabgroup(fig, 'Position', [10, 10, 1180, 680]);

    % Create tabs for each task
    tab1 = uitab(tabGroup, 'Title', 'Task 1: Convolution');
    tab2 = uitab(tabGroup, 'Title', 'Task 2: Smoothing/Blurring');
    tab3 = uitab(tabGroup, 'Title', 'Task 3: High-Pass Filter');
    tab4 = uitab(tabGroup, 'Title', 'Task 4: Image Brightening');
    tab5 = uitab(tabGroup, 'Title', 'Task 5: Noise Addition/Removal');
    tab6 = uitab(tabGroup, 'Title', 'Task 6: Periodic Noise Removal');
    tab7 = uitab(tabGroup, 'Title', 'Task 7: Motion Blur/Deblur');

    % Initialize each tab
    createTask1Tab(tab1);
    createTask2Tab(tab2);
    createTask3Tab(tab3);
    createTask4Tab(tab4);
    createTask5Tab(tab5);
    createTask6Tab(tab6);
    createTask7Tab(tab7);
end

%% Task 1: Image Convolution
function createTask1Tab(parent)
    % Task 1: Konvolusi Citra

    % Store data
    data = struct();
    data.originalImage = [];
    data.customResult = [];
    data.matlabResult = [];
    parent.UserData = data;

    % Control Panel
    controlPanel = uipanel(parent, 'Title', 'Controls', ...
                          'Position', [10, 10, 280, 650]);

    % Load Image Button
    uibutton(controlPanel, 'Position', [10, 480, 125, 30], ...
             'Text', 'Load Image', ...
             'ButtonPushedFcn', @(btn,event) loadImageTask1(parent));

    % Load Test Image Button
    uibutton(controlPanel, 'Position', [145, 480, 115, 30], ...
             'Text', 'Load Test', ...
             'ButtonPushedFcn', @(btn,event) loadTestImageTask1(parent));

    % Mask Type
    uilabel(controlPanel, 'Position', [10, 450, 100, 22], 'Text', 'Mask Type:');
    maskType = uidropdown(controlPanel, 'Position', [10, 420, 260, 22], ...
                          'Items', {'Average', 'Gaussian', 'Sobel X', 'Sobel Y', 'Laplacian'}, ...
                          'Value', 'Gaussian');

    % Mask Size
    uilabel(controlPanel, 'Position', [10, 390, 100, 22], 'Text', 'Mask Size:');
    maskSize = uidropdown(controlPanel, 'Position', [10, 360, 260, 22], ...
                          'Items', {'3x3', '5x5', '7x7'}, ...
                          'Value', '5x5');

    % Gaussian Sigma (only for Gaussian)
    uilabel(controlPanel, 'Position', [10, 330, 150, 22], 'Text', 'Sigma (Gaussian):');
    sigmaParam = uispinner(controlPanel, 'Position', [170, 330, 100, 22], ...
                          'Value', 1.0, 'Limits', [0.1, 5.0], 'Step', 0.1);

    % Padding Method
    uilabel(controlPanel, 'Position', [10, 300, 150, 22], 'Text', 'Padding Method:');
    paddingMethod = uidropdown(controlPanel, 'Position', [10, 270, 260, 22], ...
                              'Items', {'zero', 'replicate', 'symmetric'}, ...
                              'Value', 'replicate');

    % Apply Convolution Button
    uibutton(controlPanel, 'Position', [10, 230, 260, 30], ...
             'Text', 'Apply Convolution', ...
             'ButtonPushedFcn', @(btn,event) applyConvolutionTask1(parent, maskType, maskSize, sigmaParam, paddingMethod));

    % Clear Button
    uibutton(controlPanel, 'Position', [10, 190, 260, 30], ...
             'Text', 'Clear All', ...
             'ButtonPushedFcn', @(btn,event) clearAllTask1(parent));

    % Display Panel
    displayPanel = uipanel(parent, 'Title', 'Image Display', ...
                          'Position', [300, 10, 860, 650]);

    % Image axes
    ax1 = uiaxes(displayPanel, 'Position', [10, 280, 270, 230]);
    title(ax1, 'Original Image');
    ax1.Tag = 'OriginalAxes';

    ax2 = uiaxes(displayPanel, 'Position', [295, 280, 270, 230]);
    title(ax2, 'Custom Convolution');
    ax2.Tag = 'CustomAxes';

    ax3 = uiaxes(displayPanel, 'Position', [580, 280, 270, 230]);
    title(ax3, 'MATLAB Built-in');
    ax3.Tag = 'MatlabAxes';

    % Difference and info
    ax4 = uiaxes(displayPanel, 'Position', [10, 10, 270, 230]);
    title(ax4, 'Difference (10x)');
    ax4.Tag = 'DifferenceAxes';

    infoText = uitextarea(displayPanel, 'Position', [295, 10, 555, 230], ...
                         'Value', 'Load an image to start...', ...
                         'Editable', 'off');
    infoText.Tag = 'InfoText';
end

%% Helper Functions for Task 1

function loadImageTask1(parent)
    [file, path] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp;*.tif', 'Image Files'});
    if isequal(file, 0)
        return;
    end

    img = imread(fullfile(path, file));

    % Store in parent data
    parent.UserData.originalImage = img;
    parent.UserData.customResult = [];
    parent.UserData.matlabResult = [];

    % Display
    ax = findobj(parent, 'Tag', 'OriginalAxes');
    imshow(img, 'Parent', ax);
    title(ax, 'Original Image');

    % Clear other axes
    ax2 = findobj(parent, 'Tag', 'CustomAxes');
    cla(ax2);
    title(ax2, 'Custom Convolution');

    ax3 = findobj(parent, 'Tag', 'MatlabAxes');
    cla(ax3);
    title(ax3, 'MATLAB Built-in');

    ax4 = findobj(parent, 'Tag', 'DifferenceAxes');
    cla(ax4);
    title(ax4, 'Difference (10x)');

    % Update info
    infoText = findobj(parent, 'Tag', 'InfoText');
    infoText.Value = {sprintf('Image loaded: %s', file), ...
                     sprintf('Size: %d x %d', size(img, 1), size(img, 2)), ...
                     sprintf('Channels: %d', size(img, 3))};
end

function applyConvolutionTask1(parent, maskType, maskSize, sigmaParam, paddingMethod)
    if isempty(parent.UserData.originalImage)
        uialert(ancestor(parent, 'figure'), 'Please load an image first!', 'Error');
        return;
    end

    img = parent.UserData.originalImage;

    % Parse mask size
    switch maskSize.Value
        case '3x3'
            n = 3;
        case '5x5'
            n = 5;
        case '7x7'
            n = 7;
    end

    % Add path to task1 folder
    task1Path = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'task1');
    addpath(task1Path);

    % Create progress dialog
    dlg = uiprogressdlg(ancestor(parent, 'figure'), 'Title', 'Processing Convolution...', ...
                        'Message', 'Applying convolution filter...', ...
                        'Indeterminate', 'on');

    % Disable controls during processing
    controlPanel = findobj(parent, 'Type', 'uipanel', 'Title', 'Controls');
    set(findobj(controlPanel, 'Type', 'uibutton'), 'Enable', 'off');
    set(findobj(controlPanel, 'Type', 'uidropdown'), 'Enable', 'off');
    set(findobj(controlPanel, 'Type', 'uispinner'), 'Enable', 'off');

    try
        % Create mask based on type
        switch maskType.Value
            case 'Average'
                mask = createMask('average', n);
            case 'Gaussian'
                mask = createMask('gaussian', n, sigmaParam.Value);
            case 'Sobel X'
                if n ~= 3
                    uialert(ancestor(parent, 'figure'), 'Sobel filters only work with 3x3 size!', 'Error');
                    return;
                end
                mask = createMask('sobel_x', n);
            case 'Sobel Y'
                if n ~= 3
                    uialert(ancestor(parent, 'figure'), 'Sobel filters only work with 3x3 size!', 'Error');
                    return;
                end
                mask = createMask('sobel_y', n);
            case 'Laplacian'
                mask = createMask('laplacian', n);
        end

        tic;
        customResult = applyConvolution(img, mask, paddingMethod.Value);
        customTime = toc;

        tic;
        % Convert padding method for MATLAB's imfilter
        if strcmp(paddingMethod.Value, 'zero')
            matlabPadding = 0;
        else
            matlabPadding = paddingMethod.Value;
        end
        
        if size(img, 3) == 1
            matlabResult = imfilter(double(img), mask, matlabPadding, 'conv');
            matlabResult = uint8(matlabResult);
        else
            matlabResult = imfilter(img, mask, matlabPadding, 'conv');
        end
        matlabTime = toc;

        % Calculate difference
        difference = abs(double(customResult) - double(matlabResult));

        % Store results
        parent.UserData.customResult = customResult;
        parent.UserData.matlabResult = matlabResult;

        % Display results
        ax2 = findobj(parent, 'Tag', 'CustomAxes');
        imshow(customResult, 'Parent', ax2);
        title(ax2, 'Custom Convolution');

        ax3 = findobj(parent, 'Tag', 'MatlabAxes');
        imshow(matlabResult, 'Parent', ax3);
        title(ax3, 'MATLAB Built-in');

        ax4 = findobj(parent, 'Tag', 'DifferenceAxes');
        imshow(uint8(difference*10), 'Parent', ax4);
        title(ax4, 'Difference (10x)');

        % Calculate metrics
        mseVal = mean(difference(:).^2);
        maeVal = mean(difference(:));
        maxError = max(difference(:));

        if mseVal > 0
            psnrVal = 10 * log10(255^2 / mseVal);
        else
            psnrVal = Inf;
        end

        customVec = double(customResult(:));
        matlabVec = double(matlabResult(:));
        
        % Calculate correlation without Statistics Toolbox
        meanCustom = mean(customVec);
        meanMatlab = mean(matlabVec);
        numerator = sum((customVec - meanCustom) .* (matlabVec - meanMatlab));
        denominator = sqrt(sum((customVec - meanCustom).^2) * sum((matlabVec - meanMatlab).^2));
        correlation = numerator / denominator;

        % Update info
        infoText = findobj(parent, 'Tag', 'InfoText');
        infoText.Value = {sprintf('Mask: %s (%dx%d)', maskType.Value, n, n), ...
                         sprintf('Padding: %s', paddingMethod.Value), ...
                         sprintf('Custom Time: %.4f s', customTime), ...
                         sprintf('MATLAB Time: %.4f s', matlabTime), ...
                         sprintf('Speed Ratio: %.2fx %s', matlabTime/customTime, ...
                                 ternary(matlabTime/customTime < 1, '(custom faster)', '(MATLAB faster)')), ...
                         sprintf('MSE: %.6f', mseVal), ...
                         sprintf('MAE: %.6f', maeVal), ...
                         sprintf('Max Error: %.6f', maxError), ...
                         sprintf('PSNR: %.2f dB', psnrVal), ...
                         sprintf('Correlation: %.6f', correlation)};

        % Close progress dialog and re-enable controls
        close(dlg);
        set(findobj(controlPanel, 'Type', 'uibutton'), 'Enable', 'on');
        set(findobj(controlPanel, 'Type', 'uidropdown'), 'Enable', 'on');
        set(findobj(controlPanel, 'Type', 'uispinner'), 'Enable', 'on');

    catch ME
        % Close progress dialog and re-enable controls on error
        close(dlg);
        set(findobj(controlPanel, 'Type', 'uibutton'), 'Enable', 'on');
        set(findobj(controlPanel, 'Type', 'uidropdown'), 'Enable', 'on');
        set(findobj(controlPanel, 'Type', 'uispinner'), 'Enable', 'on');
        uialert(ancestor(parent, 'figure'), ME.message, 'Error');
    end
end

function loadTestImageTask1(parent)
    % Load test images from task1 folder
    task1Path = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'task1', 'test_images');

    % Get list of test images
    imageFiles = dir(fullfile(task1Path, '*.jpeg'));
    if isempty(imageFiles)
        imageFiles = dir(fullfile(task1Path, '*.jpg'));
    end
    if isempty(imageFiles)
        imageFiles = dir(fullfile(task1Path, '*.png'));
    end

    if isempty(imageFiles)
        uialert(ancestor(parent, 'figure'), 'No test images found in task1/test_images folder!', 'Error');
        return;
    end

    % Create selection dialog
    imageNames = {imageFiles.name};
    [idx, tf] = listdlg('ListString', imageNames, 'SelectionMode', 'single', ...
                       'Name', 'Select Test Image', 'PromptString', 'Choose a test image:');

    if tf
        selectedFile = imageNames{idx};
        img = imread(fullfile(task1Path, selectedFile));

        % Store in parent data
        parent.UserData.originalImage = img;
        parent.UserData.customResult = [];
        parent.UserData.matlabResult = [];

        % Display
        ax = findobj(parent, 'Tag', 'OriginalAxes');
        imshow(img, 'Parent', ax);
        title(ax, 'Original Image');

        % Clear other axes
        ax2 = findobj(parent, 'Tag', 'CustomAxes');
        cla(ax2);
        title(ax2, 'Custom Convolution');

        ax3 = findobj(parent, 'Tag', 'MatlabAxes');
        cla(ax3);
        title(ax3, 'MATLAB Built-in');

        ax4 = findobj(parent, 'Tag', 'DifferenceAxes');
        cla(ax4);
        title(ax4, 'Difference (10x)');

        % Update info
        infoText = findobj(parent, 'Tag', 'InfoText');
        infoText.Value = {sprintf('Test image loaded: %s', selectedFile), ...
                         sprintf('Size: %d x %d', size(img, 1), size(img, 2)), ...
                         sprintf('Channels: %d', size(img, 3))};
    end
end

function clearAllTask1(parent)
    parent.UserData.originalImage = [];
    parent.UserData.customResult = [];
    parent.UserData.matlabResult = [];

    % Clear all axes
    ax1 = findobj(parent, 'Tag', 'OriginalAxes');
    cla(ax1);
    title(ax1, 'Original Image');

    ax2 = findobj(parent, 'Tag', 'CustomAxes');
    cla(ax2);
    title(ax2, 'Custom Convolution');

    ax3 = findobj(parent, 'Tag', 'MatlabAxes');
    cla(ax3);
    title(ax3, 'MATLAB Built-in');

    ax4 = findobj(parent, 'Tag', 'DifferenceAxes');
    cla(ax4);
    title(ax4, 'Difference (10x)');

    % Clear info
    infoText = findobj(parent, 'Tag', 'InfoText');
    infoText.Value = 'Cleared. Load an image to start...';

    filterDropdown = findobj(parent, 'Tag', 'FilterTypeDropdown');
    if ~isempty(filterDropdown)
        filterDropdown.Value = 'Auto';
    end
end

%% Task 2: Image Smoothing and Blurring
function createTask2Tab(parent)
    % Task 2: Image Smoothing dan Blurring

    % Store data
    data = struct();
    data.originalImage = [];
    data.noisyImage = [];
    data.smoothedImage = [];
    parent.UserData = data;

    % Control Panel
    controlPanel = uipanel(parent, 'Title', 'Controls', ...
                          'Position', [10, 10, 280, 650]);

    % Load Image Button
    uibutton(controlPanel, 'Position', [10, 480, 125, 30], ...
             'Text', 'Load Image', ...
             'ButtonPushedFcn', @(btn,event) loadImageTask2(parent));

    % Load Test Image Button
    uibutton(controlPanel, 'Position', [145, 480, 115, 30], ...
             'Text', 'Load Test', ...
             'ButtonPushedFcn', @(btn,event) loadTestImageTask2(parent));

    % Domain Selection
    uilabel(controlPanel, 'Position', [10, 450, 100, 22], 'Text', 'Domain:');
    domainType = uidropdown(controlPanel, 'Position', [10, 420, 260, 22], ...
                           'Items', {'Spatial', 'Frequency'}, ...
                           'Value', 'Spatial', ...
                           'ValueChangedFcn', @(dd,event) updateDomainVisibility(parent, dd));

    % Noise Type
    uilabel(controlPanel, 'Position', [10, 390, 100, 22], 'Text', 'Noise Type:');
    noiseType = uidropdown(controlPanel, 'Position', [10, 360, 260, 22], ...
                          'Items', {'Gaussian', 'Salt & Pepper', 'Speckle'}, ...
                          'Value', 'Gaussian');

    % Noise Parameters
    uilabel(controlPanel, 'Position', [10, 330, 150, 22], 'Text', 'Noise Density/Variance:');
    noiseParam = uispinner(controlPanel, 'Position', [170, 330, 100, 22], ...
                          'Value', 0.05, 'Limits', [0, 1], 'Step', 0.01);

    % Add Noise Button
    uibutton(controlPanel, 'Position', [10, 290, 260, 30], ...
             'Text', 'Add Noise', ...
             'ButtonPushedFcn', @(btn,event) addNoiseTask2(parent, noiseType, noiseParam));

    % Filter Type (Spatial)
    spatialFilterLabel = uilabel(controlPanel, 'Position', [10, 260, 100, 22], 'Text', 'Spatial Filter:');
    spatialFilterLabel.Tag = 'SpatialControl';
    spatialFilterType = uidropdown(controlPanel, 'Position', [10, 230, 260, 22], ...
                                  'Items', {'Mean', 'Gaussian', 'Median', 'Bilateral'}, ...
                                  'Value', 'Gaussian');
    spatialFilterType.Tag = 'SpatialControl';

    % Frequency Filter Type
    freqFilterLabel = uilabel(controlPanel, 'Position', [10, 260, 120, 22], 'Text', 'Freq Filter:');
    freqFilterLabel.Tag = 'FrequencyControl';
    freqFilterLabel.Visible = 'off';
    freqFilterType = uidropdown(controlPanel, 'Position', [10, 230, 260, 22], ...
                               'Items', {'ILPF', 'GLPF', 'BLPF'}, ...
                               'Value', 'GLPF');
    freqFilterType.Tag = 'FrequencyControl';
    freqFilterType.Visible = 'off';

    % Filter Size (Spatial only)
    filterSizeLabel = uilabel(controlPanel, 'Position', [10, 200, 100, 22], 'Text', 'Filter Size:');
    filterSizeLabel.Tag = 'SpatialControl';
    filterSize = uispinner(controlPanel, 'Position', [120, 200, 150, 22], ...
                          'Value', 5, 'Limits', [3, 15], 'Step', 2);
    filterSize.Tag = 'SpatialControl';

    % Sigma (for Gaussian/Bilateral - Spatial only)
    sigmaLabel = uilabel(controlPanel, 'Position', [10, 170, 100, 22], 'Text', 'Sigma:');
    sigmaLabel.Tag = 'SpatialControl';
    sigmaParam = uispinner(controlPanel, 'Position', [120, 170, 150, 22], ...
                          'Value', 1.0, 'Limits', [0.1, 5.0], 'Step', 0.1);
    sigmaParam.Tag = 'SpatialControl';

    % Frequency Domain Parameters
    cutoffFreqLabel = uilabel(controlPanel, 'Position', [10, 200, 150, 22], 'Text', 'Cutoff Freq (D0):');
    cutoffFreqLabel.Tag = 'FrequencyControl';
    cutoffFreqLabel.Visible = 'off';
    cutoffFreq = uispinner(controlPanel, 'Position', [10, 170, 260, 22], ...
                          'Value', 40, 'Limits', [1, 200], 'Step', 5);
    cutoffFreq.Tag = 'FrequencyControl';
    cutoffFreq.Visible = 'off';

    filterOrderLabel = uilabel(controlPanel, 'Position', [10, 140, 100, 22], 'Text', 'Filter Order:');
    filterOrderLabel.Tag = 'FrequencyControl';
    filterOrderLabel.Visible = 'off';
    filterOrder = uispinner(controlPanel, 'Position', [120, 140, 150, 22], ...
                           'Value', 2, 'Limits', [1, 10], 'Step', 1);
    filterOrder.Tag = 'FrequencyControl';
    filterOrder.Visible = 'off';

    % Apply Filter Button
    uibutton(controlPanel, 'Position', [10, 50, 260, 30], ...
             'Text', 'Apply Filter', ...
             'ButtonPushedFcn', @(btn,event) applyFilterTask2(parent, domainType, spatialFilterType, freqFilterType, filterSize, sigmaParam, cutoffFreq, filterOrder));

    % Clear Button
    uibutton(controlPanel, 'Position', [10, 10, 260, 30], ...
             'Text', 'Clear All', ...
             'ButtonPushedFcn', @(btn,event) clearAllTask2(parent));

    % Display Panel
    displayPanel = uipanel(parent, 'Title', 'Image Display', ...
                          'Position', [300, 10, 860, 650]);

    % Image axes
    ax1 = uiaxes(displayPanel, 'Position', [10, 280, 270, 230]);
    title(ax1, 'Original Image');
    ax1.Tag = 'OriginalAxes';

    ax2 = uiaxes(displayPanel, 'Position', [295, 280, 270, 230]);
    title(ax2, 'Noisy Image');
    ax2.Tag = 'NoisyAxes';

    ax3 = uiaxes(displayPanel, 'Position', [580, 280, 270, 230]);
    title(ax3, 'Filtered Image');
    ax3.Tag = 'FilteredAxes';

    % Spectrum displays (for frequency domain)
    ax4 = uiaxes(displayPanel, 'Position', [10, 10, 270, 230]);
    title(ax4, 'Original FFT Spectrum');
    ax4.Tag = 'OriginalSpectrumAxes';

    ax5 = uiaxes(displayPanel, 'Position', [295, 10, 270, 230]);
    title(ax5, 'Filtered FFT Spectrum');
    ax5.Tag = 'FilteredSpectrumAxes';

    % Info text
    infoText = uitextarea(displayPanel, 'Position', [580, 10, 270, 230], ...
                         'Value', 'Load an image to start...', ...
                         'Editable', 'off');
    infoText.Tag = 'InfoText';
end

%% Helper Functions for Task 2

function loadImageTask2(parent)
    [file, path] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp;*.tif', 'Image Files'});
    if isequal(file, 0)
        return;
    end

    img = imread(fullfile(path, file));

    % Store in parent data
    parent.UserData.originalImage = img;
    parent.UserData.noisyImage = [];
    parent.UserData.smoothedImage = [];

    % Display
    ax = findobj(parent, 'Tag', 'OriginalAxes');
    imshow(img, 'Parent', ax);
    title(ax, 'Original Image');

    % Clear other axes
    ax2 = findobj(parent, 'Tag', 'NoisyAxes');
    cla(ax2);
    title(ax2, 'Noisy Image');

    ax3 = findobj(parent, 'Tag', 'FilteredAxes');
    cla(ax3);
    title(ax3, 'Filtered Image');

    % Update info
    infoText = findobj(parent, 'Tag', 'InfoText');
    infoText.Value = {sprintf('Image loaded: %s', file), ...
                     sprintf('Size: %d x %d', size(img, 1), size(img, 2))};
end

function addNoiseTask2(parent, noiseType, noiseParam)
    if isempty(parent.UserData.originalImage)
        uialert(ancestor(parent, 'figure'), 'Please load an image first!', 'Error');
        return;
    end

    img = parent.UserData.originalImage;

    % Add path to task2 folder
    task2Path = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'task2');
    addpath(task2Path);

    try
        % Add noise based on type
        switch noiseType.Value
            case 'Gaussian'
                noisyImg = addNoise(img, 'gaussian', 0, noiseParam.Value);
            case 'Salt & Pepper'
                noisyImg = addNoise(img, 'salt_pepper', noiseParam.Value);
            case 'Speckle'
                noisyImg = addNoise(img, 'speckle', noiseParam.Value);
        end

        parent.UserData.noisyImage = noisyImg;

        % Display
        ax = findobj(parent, 'Tag', 'NoisyAxes');
        imshow(noisyImg, 'Parent', ax);
        title(ax, sprintf('Noisy Image (%s)', noiseType.Value));

        % Update info
        infoText = findobj(parent, 'Tag', 'InfoText');
        infoText.Value = {sprintf('Noise Type: %s', noiseType.Value), ...
                         sprintf('Parameter: %.3f', noiseParam.Value), ...
                         'Ready to apply filter...'};

    catch ME
        uialert(ancestor(parent, 'figure'), ME.message, 'Error');
    end
end

function applyFilterTask2(parent, domainType, spatialFilterType, freqFilterType, filterSize, sigmaParam, cutoffFreq, filterOrder)
    if isempty(parent.UserData.noisyImage)
        uialert(ancestor(parent, 'figure'), 'Please add noise first!', 'Error');
        return;
    end

    img = parent.UserData.noisyImage;

    % Add path to task2 folder
    task2Path = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'task2');
    addpath(task2Path);

    % Create progress dialog
    dlg = uiprogressdlg(ancestor(parent, 'figure'), 'Title', 'Processing Filter...', ...
                        'Message', 'Applying smoothing filter...', ...
                        'Indeterminate', 'on');

    % Disable controls during processing
    controlPanel = findobj(parent, 'Type', 'uipanel', 'Title', 'Controls');
    set(findobj(controlPanel, 'Type', 'uibutton'), 'Enable', 'off');
    set(findobj(controlPanel, 'Type', 'uidropdown'), 'Enable', 'off');
    set(findobj(controlPanel, 'Type', 'uispinner'), 'Enable', 'off');

    try
        tic;
        if strcmp(domainType.Value, 'Spatial')
            % Spatial domain filtering
            switch spatialFilterType.Value
                case 'Mean'
                    smoothedImg = spatialSmoothing(img, 'mean', filterSize.Value);
                    filterDesc = sprintf('Mean %dx%d', filterSize.Value, filterSize.Value);
                case 'Gaussian'
                    smoothedImg = spatialSmoothing(img, 'gaussian', filterSize.Value, sigmaParam.Value);
                    filterDesc = sprintf('Gaussian %dx%d (σ=%.1f)', filterSize.Value, filterSize.Value, sigmaParam.Value);
                case 'Median'
                    smoothedImg = spatialSmoothing(img, 'median', filterSize.Value);
                    filterDesc = sprintf('Median %dx%d', filterSize.Value, filterSize.Value);
                case 'Bilateral'
                    smoothedImg = spatialSmoothing(img, 'bilateral', filterSize.Value, sigmaParam.Value);
                    filterDesc = sprintf('Bilateral %dx%d (σ=%.1f)', filterSize.Value, filterSize.Value, sigmaParam.Value);
            end

            % Clear spectrum displays for spatial domain
            ax4 = findobj(parent, 'Tag', 'OriginalSpectrumAxes');
            cla(ax4);
            title(ax4, 'Original FFT Spectrum');
            text(ax4, 0.5, 0.5, 'Not applicable for Spatial domain', ...
                'Units', 'normalized', 'HorizontalAlignment', 'center', ...
                'FontSize', 12, 'Color', [0.7 0.7 0.7]);
            ax4.XTick = [];
            ax4.YTick = [];

            ax5 = findobj(parent, 'Tag', 'FilteredSpectrumAxes');
            cla(ax5);
            title(ax5, 'Filtered FFT Spectrum');
            text(ax5, 0.5, 0.5, 'Not applicable for Spatial domain', ...
                'Units', 'normalized', 'HorizontalAlignment', 'center', ...
                'FontSize', 12, 'Color', [0.7 0.7 0.7]);
            ax5.XTick = [];
            ax5.YTick = [];

        else
            % Frequency domain filtering (same approach as main_smoothing.m)
            [smoothedImg, ~, spectrum] = frequencySmoothing(img, freqFilterType.Value, cutoffFreq.Value, filterOrder.Value);
            filterDesc = sprintf('%s D0=%d n=%d', freqFilterType.Value, cutoffFreq.Value, filterOrder.Value);

            % Display original spectrum
            ax4 = findobj(parent, 'Tag', 'OriginalSpectrumAxes');
            imshow(spectrum.original, [], 'Parent', ax4);
            title(ax4, 'Original FFT Spectrum');
            colormap(ax4, 'jet');

            % Display filtered spectrum
            ax5 = findobj(parent, 'Tag', 'FilteredSpectrumAxes');
            imshow(spectrum.filtered, [], 'Parent', ax5);
            title(ax5, sprintf('Filtered Spectrum (%s)', freqFilterType.Value));
            colormap(ax5, 'jet');
        end
        elapsedTime = toc;

        parent.UserData.smoothedImage = smoothedImg;

        % Display filtered image
        ax = findobj(parent, 'Tag', 'FilteredAxes');
        imshow(smoothedImg, 'Parent', ax);
        title(ax, sprintf('Filtered (%s)', domainType.Value));

        % Calculate metrics
        if ~isempty(parent.UserData.originalImage)
            original = im2double(parent.UserData.originalImage);
            smoothedDbl = im2double(smoothedImg);
            imgDbl = im2double(img);
            
            % Convert to grayscale if dimensions don't match
            if size(original, 3) ~= size(smoothedDbl, 3)
                if size(original, 3) == 3
                    original = rgb2gray(original);
                end
                if size(imgDbl, 3) == 3
                    imgDbl = rgb2gray(imgDbl);
                end
            end
            
            mseVal = mean((original(:) - smoothedDbl(:)).^2);
            psnrVal = 10 * log10(1 / mseVal);

            % Noise reduction (compare noisy vs filtered)
            noisyMSE = mean((original(:) - imgDbl(:)).^2);
            filteredMSE = mean((original(:) - smoothedDbl(:)).^2);
            noiseReduction = ((noisyMSE - filteredMSE) / noisyMSE) * 100;

            infoText = findobj(parent, 'Tag', 'InfoText');
            infoText.Value = {sprintf('Domain: %s', domainType.Value), ...
                             sprintf('Filter: %s', filterDesc), ...
                             sprintf('Processing Time: %.3f seconds', elapsedTime), ...
                             sprintf('MSE: %.6f', mseVal), ...
                             sprintf('PSNR: %.2f dB', psnrVal), ...
                             sprintf('Noise Reduction: %.1f%%', noiseReduction)};
        end

        % Close progress dialog and re-enable controls
        close(dlg);
        set(findobj(controlPanel, 'Type', 'uibutton'), 'Enable', 'on');
        set(findobj(controlPanel, 'Type', 'uidropdown'), 'Enable', 'on');
        set(findobj(controlPanel, 'Type', 'uispinner'), 'Enable', 'on');

    catch ME
        % Close progress dialog and re-enable controls on error
        close(dlg);
        set(findobj(controlPanel, 'Type', 'uibutton'), 'Enable', 'on');
        set(findobj(controlPanel, 'Type', 'uidropdown'), 'Enable', 'on');
        set(findobj(controlPanel, 'Type', 'uispinner'), 'Enable', 'on');
        uialert(ancestor(parent, 'figure'), ME.message, 'Error');
    end
end

function loadTestImageTask2(parent)
    % Load test images from task2 folder
    task2Path = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'task2', 'test_images');

    % Get list of test images
    imageFiles = dir(fullfile(task2Path, '*.jpg'));
    if isempty(imageFiles)
        imageFiles = dir(fullfile(task2Path, '*.jpeg'));
    end
    if isempty(imageFiles)
        imageFiles = dir(fullfile(task2Path, '*.png'));
    end

    if isempty(imageFiles)
        uialert(ancestor(parent, 'figure'), 'No test images found in task2/test_images folder!', 'Error');
        return;
    end

    % Create selection dialog
    imageNames = {imageFiles.name};
    [idx, tf] = listdlg('ListString', imageNames, 'SelectionMode', 'single', ...
                       'Name', 'Select Test Image', 'PromptString', 'Choose a test image:');

    if tf
        selectedFile = imageNames{idx};
        img = imread(fullfile(task2Path, selectedFile));

        % Store in parent data
        parent.UserData.originalImage = img;
        parent.UserData.noisyImage = [];
        parent.UserData.smoothedImage = [];

        % Display
        ax = findobj(parent, 'Tag', 'OriginalAxes');
        imshow(img, 'Parent', ax);
        title(ax, 'Original Image');

        % Clear other axes
        ax2 = findobj(parent, 'Tag', 'NoisyAxes');
        cla(ax2);
        title(ax2, 'Noisy Image');

        ax3 = findobj(parent, 'Tag', 'FilteredAxes');
        cla(ax3);
        title(ax3, 'Filtered Image');

        % Update info
        infoText = findobj(parent, 'Tag', 'InfoText');
        infoText.Value = {sprintf('Test image loaded: %s', selectedFile), ...
                         sprintf('Size: %d x %d', size(img, 1), size(img, 2))};
    end
end

function updateDomainVisibility(parent, domainDropdown)
    % Get all controls with tags
    controlPanel = findobj(parent, 'Type', 'uipanel', 'Title', 'Controls');
    spatialControls = findobj(controlPanel, 'Tag', 'SpatialControl');
    freqControls = findobj(controlPanel, 'Tag', 'FrequencyControl');
    
    if strcmp(domainDropdown.Value, 'Spatial')
        % Show spatial controls, hide frequency controls
        set(spatialControls, 'Visible', 'on');
        set(freqControls, 'Visible', 'off');
    else
        % Show frequency controls, hide spatial controls
        set(spatialControls, 'Visible', 'off');
        set(freqControls, 'Visible', 'on');
    end
end

function clearAllTask2(parent)
    parent.UserData.originalImage = [];
    parent.UserData.noisyImage = [];
    parent.UserData.smoothedImage = [];

    % Clear all axes
    ax1 = findobj(parent, 'Tag', 'OriginalAxes');
    cla(ax1);
    title(ax1, 'Original Image');

    ax2 = findobj(parent, 'Tag', 'NoisyAxes');
    cla(ax2);
    title(ax2, 'Noisy Image');

    ax3 = findobj(parent, 'Tag', 'FilteredAxes');
    cla(ax3);
    title(ax3, 'Filtered Image');

    % Clear info
    infoText = findobj(parent, 'Tag', 'InfoText');
    infoText.Value = 'Cleared. Load an image to start...';
end

%% Task 3: High-Pass Filter
function createTask3Tab(parent)
    % Task 3: Penapisan Citra Frekuensi (High-Pass Filter)

    % Store data
    data = struct();
    data.originalImage = [];
    data.filteredImage = [];
    parent.UserData = data;

    % Control Panel
    controlPanel = uipanel(parent, 'Title', 'Controls', ...
                          'Position', [10, 10, 280, 650]);

    % Load Image Button
    uibutton(controlPanel, 'Position', [10, 480, 125, 30], ...
             'Text', 'Load Image', ...
             'ButtonPushedFcn', @(btn,event) loadImageTask3(parent));

    % Load Test Image Button
    uibutton(controlPanel, 'Position', [145, 480, 115, 30], ...
             'Text', 'Load Test', ...
             'ButtonPushedFcn', @(btn,event) loadTestImageTask3(parent));

    % Filter Type
    uilabel(controlPanel, 'Position', [10, 450, 100, 22], 'Text', 'Filter Type:');
    filterType = uidropdown(controlPanel, 'Position', [10, 420, 260, 22], ...
                           'Items', {'IHPF', 'GHPF', 'BHPF'}, ...
                           'Value', 'GHPF');

    % Cutoff Frequency
    uilabel(controlPanel, 'Position', [10, 390, 150, 22], 'Text', 'Cutoff Frequency (D0):');
    cutoffFreq = uispinner(controlPanel, 'Position', [170, 390, 100, 22], ...
                          'Value', 30, 'Limits', [1, 200], 'Step', 5);

    % Filter Order (for Butterworth)
    uilabel(controlPanel, 'Position', [10, 360, 150, 22], 'Text', 'Filter Order (n):');
    filterOrder = uispinner(controlPanel, 'Position', [170, 360, 100, 22], ...
                           'Value', 2, 'Limits', [1, 10], 'Step', 1);

    % Boost Factor
    uilabel(controlPanel, 'Position', [10, 330, 150, 22], 'Text', 'Boost Factor:');
    boostFactor = uispinner(controlPanel, 'Position', [170, 330, 100, 22], ...
                           'Value', 1.0, 'Limits', [0.5, 5.0], 'Step', 0.1);

    % Processing Type
    uilabel(controlPanel, 'Position', [10, 300, 150, 22], 'Text', 'Processing Type:');
    processingType = uidropdown(controlPanel, 'Position', [10, 270, 260, 22], ...
                               'Items', {'High-Pass Filter', 'Sharpening', 'Edge Detection'}, ...
                               'Value', 'High-Pass Filter');

    % Apply Filter Button
    uibutton(controlPanel, 'Position', [10, 230, 260, 30], ...
             'Text', 'Apply Filter', ...
             'ButtonPushedFcn', @(btn,event) applyFilterTask3(parent, filterType, cutoffFreq, filterOrder, boostFactor, processingType));

    % Clear Button
    uibutton(controlPanel, 'Position', [10, 190, 260, 30], ...
             'Text', 'Clear All', ...
             'ButtonPushedFcn', @(btn,event) clearAllTask3(parent));

    % Display Panel
    displayPanel = uipanel(parent, 'Title', 'Image Display', ...
                          'Position', [300, 10, 860, 650]);

    % Image axes
    ax1 = uiaxes(displayPanel, 'Position', [10, 280, 270, 230]);
    title(ax1, 'Original Image');
    ax1.Tag = 'OriginalAxes';

    ax2 = uiaxes(displayPanel, 'Position', [295, 280, 270, 230]);
    title(ax2, 'Filtered Image');
    ax2.Tag = 'FilteredAxes';

    ax3 = uiaxes(displayPanel, 'Position', [580, 280, 270, 230]);
    title(ax3, 'Processing Result');
    ax3.Tag = 'ResultAxes';

    % Spectrum display
    ax4 = uiaxes(displayPanel, 'Position', [10, 10, 270, 230]);
    title(ax4, 'FFT Spectrum');
    ax4.Tag = 'SpectrumAxes';

    ax5 = uiaxes(displayPanel, 'Position', [295, 10, 270, 230]);
    title(ax5, 'Filter Response');
    ax5.Tag = 'FilterAxes';

    % Info text
    infoText = uitextarea(displayPanel, 'Position', [580, 10, 270, 230], ...
                         'Value', 'Load an image to start...', ...
                         'Editable', 'off');
    infoText.Tag = 'InfoText';
end

%% Helper Functions for Task 3

function loadImageTask3(parent)
    [file, path] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp;*.tif', 'Image Files'});
    if isequal(file, 0)
        return;
    end

    img = imread(fullfile(path, file));

    % Store in parent data
    parent.UserData.originalImage = img;
    parent.UserData.filteredImage = [];

    % Display
    ax = findobj(parent, 'Tag', 'OriginalAxes');
    imshow(img, 'Parent', ax);
    title(ax, 'Original Image');

    % Clear other axes
    ax2 = findobj(parent, 'Tag', 'FilteredAxes');
    cla(ax2);
    title(ax2, 'Filtered Image');

    ax3 = findobj(parent, 'Tag', 'ResultAxes');
    cla(ax3);
    title(ax3, 'Processing Result');

    ax4 = findobj(parent, 'Tag', 'SpectrumAxes');
    cla(ax4);
    title(ax4, 'FFT Spectrum');

    ax5 = findobj(parent, 'Tag', 'FilterAxes');
    cla(ax5);
    title(ax5, 'Filter Response');

    % Update info
    infoText = findobj(parent, 'Tag', 'InfoText');
    infoText.Value = {sprintf('Image loaded: %s', file), ...
                     sprintf('Size: %d x %d', size(img, 1), size(img, 2))};
end

function applyFilterTask3(parent, filterType, cutoffFreq, filterOrder, boostFactor, processingType)
    if isempty(parent.UserData.originalImage)
        uialert(ancestor(parent, 'figure'), 'Please load an image first!', 'Error');
        return;
    end

    img = parent.UserData.originalImage;

    % Add path to task3 folder
    task3Path = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'task3');
    addpath(task3Path);

    % Create progress dialog
    dlg = uiprogressdlg(ancestor(parent, 'figure'), 'Title', 'Processing High-Pass Filter...', ...
                        'Message', 'Applying frequency domain filter...', ...
                        'Indeterminate', 'on');

    % Disable controls during processing
    controlPanel = findobj(parent, 'Type', 'uipanel', 'Title', 'Controls');
    set(findobj(controlPanel, 'Type', 'uibutton'), 'Enable', 'off');
    set(findobj(controlPanel, 'Type', 'uidropdown'), 'Enable', 'off');
    set(findobj(controlPanel, 'Type', 'uispinner'), 'Enable', 'off');

    try
        tic;
        [filteredImg, filterUsed, spectrum] = frequencyHighPass(img, filterType.Value, cutoffFreq.Value, filterOrder.Value, boostFactor.Value);
        elapsedTime = toc;

        parent.UserData.filteredImage = filteredImg;

        % Process based on type
        switch processingType.Value
            case 'High-Pass Filter'
                resultImg = filteredImg;
                resultTitle = 'High-Pass Filtered';

            case 'Sharpening'
                % Sharpening: original + filtered
                resultImg = im2double(img) + im2double(filteredImg);
                resultImg = im2uint8(mat2gray(resultImg));
                resultTitle = 'Sharpened Image';

            case 'Edge Detection'
                % Edge detection: just show the filtered result
                resultImg = filteredImg;
                resultTitle = 'Edge Detection';
        end

        % Display results
        ax2 = findobj(parent, 'Tag', 'FilteredAxes');
        imshow(filteredImg, 'Parent', ax2);
        title(ax2, sprintf('High-Pass (%s)', filterType.Value));

        ax3 = findobj(parent, 'Tag', 'ResultAxes');
        imshow(resultImg, 'Parent', ax3);
        title(ax3, resultTitle);

        % Display spectrum
        ax4 = findobj(parent, 'Tag', 'SpectrumAxes');
        imshow(spectrum.filtered, [], 'Parent', ax4);
        title(ax4, 'Filtered Spectrum');
        colormap(ax4, 'jet');

        % Display filter
        ax5 = findobj(parent, 'Tag', 'FilterAxes');
        imshow(filterUsed, [], 'Parent', ax5);
        title(ax5, sprintf('%s Filter', filterType.Value));
        colormap(ax5, 'jet');

        % Calculate metrics
        if ~isempty(parent.UserData.originalImage)
            original = im2double(parent.UserData.originalImage);
            resultDouble = im2double(resultImg);
            mseVal = mean((original(:) - resultDouble(:)).^2);
            psnrVal = 10 * log10(1 / mseVal);

            infoText = findobj(parent, 'Tag', 'InfoText');
            infoText.Value = {sprintf('Filter: %s', filterType.Value), ...
                             sprintf('Cutoff: D0=%d, Order=%d', cutoffFreq.Value, filterOrder.Value), ...
                             sprintf('Boost Factor: %.1f', boostFactor.Value), ...
                             sprintf('Processing: %s', processingType.Value), ...
                             sprintf('Processing Time: %.3f seconds', elapsedTime), ...
                             sprintf('MSE: %.6f', mseVal), ...
                             sprintf('PSNR: %.2f dB', psnrVal)};
        end

        % Close progress dialog and re-enable controls
        close(dlg);
        set(findobj(controlPanel, 'Type', 'uibutton'), 'Enable', 'on');
        set(findobj(controlPanel, 'Type', 'uidropdown'), 'Enable', 'on');
        set(findobj(controlPanel, 'Type', 'uispinner'), 'Enable', 'on');

    catch ME
        % Close progress dialog and re-enable controls on error
        close(dlg);
        set(findobj(controlPanel, 'Type', 'uibutton'), 'Enable', 'on');
        set(findobj(controlPanel, 'Type', 'uidropdown'), 'Enable', 'on');
        set(findobj(controlPanel, 'Type', 'uispinner'), 'Enable', 'on');
        uialert(ancestor(parent, 'figure'), ME.message, 'Error');
    end
end

function loadTestImageTask3(parent)
    % Load test images - use MATLAB built-in images or task2 images since task3 doesn't have dedicated test images
    testImages = {'cameraman.tif', 'coins.png', 'rice.png', 'eight.tif', 'moon.tif'};

    [idx, tf] = listdlg('ListString', testImages, 'SelectionMode', 'single', ...
                       'Name', 'Select Test Image', 'PromptString', 'Choose a test image:');

    if tf
        try
            selectedFile = testImages{idx};
            img = imread(selectedFile);

            % Store in parent data
            parent.UserData.originalImage = img;
            parent.UserData.filteredImage = [];

            % Display
            ax = findobj(parent, 'Tag', 'OriginalAxes');
            imshow(img, 'Parent', ax);
            title(ax, 'Original Image');

            % Clear other axes
            ax2 = findobj(parent, 'Tag', 'FilteredAxes');
            cla(ax2);
            title(ax2, 'Filtered Image');

            ax3 = findobj(parent, 'Tag', 'ResultAxes');
            cla(ax3);
            title(ax3, 'Processing Result');

            ax4 = findobj(parent, 'Tag', 'SpectrumAxes');
            cla(ax4);
            title(ax4, 'FFT Spectrum');

            ax5 = findobj(parent, 'Tag', 'FilterAxes');
            cla(ax5);
            title(ax5, 'Filter Response');

            % Update info
            infoText = findobj(parent, 'Tag', 'InfoText');
            infoText.Value = {sprintf('Test image loaded: %s', selectedFile), ...
                             sprintf('Size: %d x %d', size(img, 1), size(img, 2))};

        catch ME
            % Try loading from task2 folder as fallback
            try
                task2Path = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'task2', 'test_images');
                img = imread(fullfile(task2Path, 'gray1.jpg'));

                % Store in parent data
                parent.UserData.originalImage = img;
                parent.UserData.filteredImage = [];

                % Display
                ax = findobj(parent, 'Tag', 'OriginalAxes');
                imshow(img, 'Parent', ax);
                title(ax, 'Original Image');

                % Clear other axes
                ax2 = findobj(parent, 'Tag', 'FilteredAxes');
                cla(ax2);
                title(ax2, 'Filtered Image');

                ax3 = findobj(parent, 'Tag', 'ResultAxes');
                cla(ax3);
                title(ax3, 'Processing Result');

                ax4 = findobj(parent, 'Tag', 'SpectrumAxes');
                cla(ax4);
                title(ax4, 'FFT Spectrum');

                ax5 = findobj(parent, 'Tag', 'FilterAxes');
                cla(ax5);
                title(ax5, 'Filter Response');

                infoText = findobj(parent, 'Tag', 'InfoText');
                infoText.Value = {sprintf('Fallback test image loaded: gray1.jpg'), ...
                                 sprintf('Size: %d x %d', size(img, 1), size(img, 2))};

            catch ME2
                uialert(ancestor(parent, 'figure'), 'Could not load test images. Please use Load Image instead.', 'Error');
            end
        end
    end
end

function clearAllTask3(parent)
    parent.UserData.originalImage = [];
    parent.UserData.filteredImage = [];

    % Clear all axes
    ax1 = findobj(parent, 'Tag', 'OriginalAxes');
    cla(ax1);
    title(ax1, 'Original Image');

    ax2 = findobj(parent, 'Tag', 'FilteredAxes');
    cla(ax2);
    title(ax2, 'Filtered Image');

    ax3 = findobj(parent, 'Tag', 'ResultAxes');
    cla(ax3);
    title(ax3, 'Processing Result');

    ax4 = findobj(parent, 'Tag', 'SpectrumAxes');
    cla(ax4);
    title(ax4, 'FFT Spectrum');

    ax5 = findobj(parent, 'Tag', 'FilterAxes');
    cla(ax5);
    title(ax5, 'Filter Response');

    % Clear info
    infoText = findobj(parent, 'Tag', 'InfoText');
    infoText.Value = 'Cleared. Load an image to start...';
end

%% Task 4: Image Brightening
function createTask4Tab(parent)
    % Task 4: Pencerahan Citra dengan Penapisan Frekuensi

    % Store data
    data = struct();
    data.originalImage = [];
    data.enhancedImage = [];
    parent.UserData = data;

    % Control Panel
    controlPanel = uipanel(parent, 'Title', 'Controls', ...
                          'Position', [10, 10, 280, 650]);

    % Load Image Button
    uibutton(controlPanel, 'Position', [10, 480, 125, 30], ...
             'Text', 'Load Image', ...
             'ButtonPushedFcn', @(btn,event) loadImageTask4(parent));

    % Load Test Image Button
    uibutton(controlPanel, 'Position', [145, 480, 115, 30], ...
             'Text', 'Load Test', ...
             'ButtonPushedFcn', @(btn,event) loadTestImageTask4(parent));

    % Homomorphic Filter Parameters
    uilabel(controlPanel, 'Position', [10, 450, 150, 22], 'Text', 'Gamma Low (γ_L):');
    gammaL = uispinner(controlPanel, 'Position', [170, 450, 100, 22], ...
                      'Value', 0.25, 'Limits', [0.1, 1.0], 'Step', 0.05);

    uilabel(controlPanel, 'Position', [10, 420, 150, 22], 'Text', 'Gamma High (γ_H):');
    gammaH = uispinner(controlPanel, 'Position', [170, 420, 100, 22], ...
                      'Value', 2.0, 'Limits', [1.0, 5.0], 'Step', 0.1);

    uilabel(controlPanel, 'Position', [10, 390, 150, 22], 'Text', 'Slope (c):');
    slopeC = uispinner(controlPanel, 'Position', [170, 390, 100, 22], ...
                      'Value', 1.0, 'Limits', [0.1, 5.0], 'Step', 0.1);

    uilabel(controlPanel, 'Position', [10, 360, 150, 22], 'Text', 'Cutoff Freq (D0):');
    cutoffD0 = uispinner(controlPanel, 'Position', [170, 360, 100, 22], ...
                        'Value', 80, 'Limits', [10, 200], 'Step', 10);

    % Enhancement Type
    uilabel(controlPanel, 'Position', [10, 330, 150, 22], 'Text', 'Enhancement:');
    enhancementType = uidropdown(controlPanel, 'Position', [10, 300, 260, 22], ...
                                'Items', {'Homomorphic Filter', 'Brighten Only', 'Contrast Boost'}, ...
                                'Value', 'Homomorphic Filter');

    % Apply Filter Button
    uibutton(controlPanel, 'Position', [10, 260, 260, 30], ...
             'Text', 'Apply Homomorphic Filter', ...
             'ButtonPushedFcn', @(btn,event) applyHomomorphicFilterTask4(parent, gammaL, gammaH, slopeC, cutoffD0, enhancementType));

    % Preset Buttons
    uilabel(controlPanel, 'Position', [10, 230, 150, 22], 'Text', 'Presets:');

    uibutton(controlPanel, 'Position', [10, 200, 120, 25], ...
             'Text', 'Brighten', ...
             'ButtonPushedFcn', @(btn,event) setPresetTask4(gammaL, gammaH, slopeC, cutoffD0, 'brighten'));

    uibutton(controlPanel, 'Position', [140, 200, 120, 25], ...
             'Text', 'Enhance', ...
             'ButtonPushedFcn', @(btn,event) setPresetTask4(gammaL, gammaH, slopeC, cutoffD0, 'enhance'));

    uibutton(controlPanel, 'Position', [10, 170, 120, 25], ...
             'Text', 'High Contrast', ...
             'ButtonPushedFcn', @(btn,event) setPresetTask4(gammaL, gammaH, slopeC, cutoffD0, 'high_contrast'));

    uibutton(controlPanel, 'Position', [140, 170, 120, 25], ...
             'Text', 'Subtle', ...
             'ButtonPushedFcn', @(btn,event) setPresetTask4(gammaL, gammaH, slopeC, cutoffD0, 'subtle'));

    % Clear Button
    uibutton(controlPanel, 'Position', [10, 130, 260, 30], ...
             'Text', 'Clear All', ...
             'ButtonPushedFcn', @(btn,event) clearAllTask4(parent));

    % Display Panel
    displayPanel = uipanel(parent, 'Title', 'Image Display', ...
                          'Position', [300, 10, 860, 650]);

    % Image axes
    ax1 = uiaxes(displayPanel, 'Position', [10, 280, 270, 230]);
    title(ax1, 'Original Image');
    ax1.Tag = 'OriginalAxes';

    ax2 = uiaxes(displayPanel, 'Position', [295, 280, 270, 230]);
    title(ax2, 'Enhanced Image');
    ax2.Tag = 'EnhancedAxes';

    ax3 = uiaxes(displayPanel, 'Position', [580, 280, 270, 230]);
    title(ax3, 'Difference');
    ax3.Tag = 'DifferenceAxes';

    % Spectrum display
    ax4 = uiaxes(displayPanel, 'Position', [10, 10, 270, 230]);
    title(ax4, 'Log Spectrum');
    ax4.Tag = 'SpectrumAxes';

    ax5 = uiaxes(displayPanel, 'Position', [295, 10, 270, 230]);
    title(ax5, 'Homomorphic Filter');
    ax5.Tag = 'FilterAxes';

    % Info text
    infoText = uitextarea(displayPanel, 'Position', [580, 10, 270, 230], ...
                         'Value', 'Load an image to start...', ...
                         'Editable', 'off');
    infoText.Tag = 'InfoText';
end

%% Helper Functions for Task 4

function loadImageTask4(parent)
    [file, path] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp;*.tif', 'Image Files'});
    if isequal(file, 0)
        return;
    end

    img = imread(fullfile(path, file));

    % Store in parent data
    parent.UserData.originalImage = img;
    parent.UserData.enhancedImage = [];

    % Display
    ax = findobj(parent, 'Tag', 'OriginalAxes');
    imshow(img, 'Parent', ax);
    title(ax, 'Original Image');

    % Clear other axes
    ax2 = findobj(parent, 'Tag', 'EnhancedAxes');
    cla(ax2);
    title(ax2, 'Enhanced Image');

    ax3 = findobj(parent, 'Tag', 'DifferenceAxes');
    cla(ax3);
    title(ax3, 'Difference');

    ax4 = findobj(parent, 'Tag', 'SpectrumAxes');
    cla(ax4);
    title(ax4, 'Log Spectrum');

    ax5 = findobj(parent, 'Tag', 'FilterAxes');
    cla(ax5);
    title(ax5, 'Homomorphic Filter');

    % Update info
    infoText = findobj(parent, 'Tag', 'InfoText');
    infoText.Value = {sprintf('Image loaded: %s', file), ...
                     sprintf('Size: %d x %d', size(img, 1), size(img, 2)), ...
                     sprintf('Type: %s', ternary(size(img, 3) == 3, 'Color (RGB)', 'Grayscale'))};
end

function applyHomomorphicFilterTask4(parent, gammaL, gammaH, slopeC, cutoffD0, enhancementType)
    if isempty(parent.UserData.originalImage)
        uialert(ancestor(parent, 'figure'), 'Please load an image first!', 'Error');
        return;
    end

    img = parent.UserData.originalImage;

    % Add path to task4 folder
    task4Path = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'task4');
    addpath(task4Path);

    % Create progress dialog
    dlg = uiprogressdlg(ancestor(parent, 'figure'), 'Title', 'Processing Homomorphic Filter...', ...
                        'Message', 'Applying frequency domain enhancement...', ...
                        'Indeterminate', 'on');

    % Disable controls during processing
    controlPanel = findobj(parent, 'Type', 'uipanel', 'Title', 'Controls');
    set(findobj(controlPanel, 'Type', 'uibutton'), 'Enable', 'off');
    set(findobj(controlPanel, 'Type', 'uidropdown'), 'Enable', 'off');
    set(findobj(controlPanel, 'Type', 'uispinner'), 'Enable', 'off');

    try
        tic;
        [enhancedImg, spectrum] = homomorphicFilter(img, gammaL.Value, gammaH.Value, slopeC.Value, cutoffD0.Value);
        elapsedTime = toc;

        parent.UserData.enhancedImage = enhancedImg;

        % Process based on enhancement type
        switch enhancementType.Value
            case 'Brighten Only'
                % Just show brightened result
                resultImg = enhancedImg;
                resultTitle = 'Brightened Image';

            case 'Contrast Boost'
                % Apply additional contrast enhancement
                resultImg = imadjust(enhancedImg, stretchlim(enhancedImg), []);
                resultTitle = 'Enhanced Contrast';

            otherwise
                % Standard homomorphic filtering
                resultImg = enhancedImg;
                resultTitle = 'Homomorphic Enhanced';
        end

        % Calculate difference
        if size(img, 3) == 1
            diffImg = uint8(abs(double(resultImg) - double(img)));
        else
            diffImg = uint8(sum(abs(double(resultImg) - double(img)), 3) / 3);
        end

        % Display results
        ax2 = findobj(parent, 'Tag', 'EnhancedAxes');
        imshow(resultImg, 'Parent', ax2);
        title(ax2, resultTitle);

        ax3 = findobj(parent, 'Tag', 'DifferenceAxes');
        imshow(diffImg, 'Parent', ax3);
        title(ax3, 'Difference (10x)');
        % Amplify difference for better visibility
        imshow(uint8(double(diffImg) * 10), 'Parent', ax3);

        % Display spectrum
        ax4 = findobj(parent, 'Tag', 'SpectrumAxes');
        imshow(spectrum.original, [], 'Parent', ax4);
        title(ax4, 'Original Log Spectrum');
        colormap(ax4, 'jet');

        % Display filter
        ax5 = findobj(parent, 'Tag', 'FilterAxes');
        imshow(spectrum.filter, [], 'Parent', ax5);
        title(ax5, 'Homomorphic Filter H(u,v)');
        colormap(ax5, 'jet');

        % Calculate brightness metrics
        if size(img, 3) == 1
            origMean = mean(img(:));
            enhancedMean = mean(resultImg(:));
            brightnessIncrease = (enhancedMean - origMean) / origMean * 100;
        else
            origMean = mean(rgb2gray(img), 'all');
            enhancedMean = mean(rgb2gray(resultImg), 'all');
            brightnessIncrease = (enhancedMean - origMean) / origMean * 100;
        end

        % Update info
        infoText = findobj(parent, 'Tag', 'InfoText');
        infoText.Value = {sprintf('Homomorphic Filter Applied'), ...
                         sprintf('γ_L: %.2f, γ_H: %.2f', gammaL.Value, gammaH.Value), ...
                         sprintf('Slope c: %.1f, D0: %d', slopeC.Value, cutoffD0.Value), ...
                         sprintf('Enhancement: %s', enhancementType.Value), ...
                         sprintf('Processing Time: %.3f seconds', elapsedTime), ...
                         sprintf('Brightness Increase: %.1f%%', brightnessIncrease), ...
                         sprintf('Original Mean: %.1f', origMean), ...
                         sprintf('Enhanced Mean: %.1f', enhancedMean)};

        % Close progress dialog and re-enable controls
        close(dlg);
        set(findobj(controlPanel, 'Type', 'uibutton'), 'Enable', 'on');
        set(findobj(controlPanel, 'Type', 'uidropdown'), 'Enable', 'on');
        set(findobj(controlPanel, 'Type', 'uispinner'), 'Enable', 'on');

    catch ME
        % Close progress dialog and re-enable controls on error
        close(dlg);
        set(findobj(controlPanel, 'Type', 'uibutton'), 'Enable', 'on');
        set(findobj(controlPanel, 'Type', 'uidropdown'), 'Enable', 'on');
        set(findobj(controlPanel, 'Type', 'uispinner'), 'Enable', 'on');
        uialert(ancestor(parent, 'figure'), ME.message, 'Error');
    end
end

function setPresetTask4(gammaL, gammaH, slopeC, cutoffD0, presetType)
    switch presetType
        case 'brighten'
            gammaL.Value = 0.1;
            gammaH.Value = 1.5;
            slopeC.Value = 0.5;
            cutoffD0.Value = 100;

        case 'enhance'
            gammaL.Value = 0.25;
            gammaH.Value = 2.0;
            slopeC.Value = 1.0;
            cutoffD0.Value = 80;

        case 'high_contrast'
            gammaL.Value = 0.5;
            gammaH.Value = 3.0;
            slopeC.Value = 2.0;
            cutoffD0.Value = 50;

        case 'subtle'
            gammaL.Value = 0.75;
            gammaH.Value = 1.2;
            slopeC.Value = 0.5;
            cutoffD0.Value = 120;
    end
end

function loadTestImageTask4(parent)
    % Load test images from task4 folder
    task4Path = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'task4', 'test_images');

    % Get list of test images
    imageFiles = dir(fullfile(task4Path, '*.jpg'));
    if isempty(imageFiles)
        imageFiles = dir(fullfile(task4Path, '*.jpeg'));
    end
    if isempty(imageFiles)
        imageFiles = dir(fullfile(task4Path, '*.png'));
    end

    if isempty(imageFiles)
        uialert(ancestor(parent, 'figure'), 'No test images found in task4/test_images folder!', 'Error');
        return;
    end

    % Create selection dialog
    imageNames = {imageFiles.name};
    [idx, tf] = listdlg('ListString', imageNames, 'SelectionMode', 'single', ...
                       'Name', 'Select Test Image', 'PromptString', 'Choose a test image:');

    if tf
        selectedFile = imageNames{idx};
        img = imread(fullfile(task4Path, selectedFile));

        % Store in parent data
        parent.UserData.originalImage = img;
        parent.UserData.enhancedImage = [];

        % Display
        ax = findobj(parent, 'Tag', 'OriginalAxes');
        imshow(img, 'Parent', ax);
        title(ax, 'Original Image');

        % Clear other axes
        ax2 = findobj(parent, 'Tag', 'EnhancedAxes');
        cla(ax2);
        title(ax2, 'Enhanced Image');

        ax3 = findobj(parent, 'Tag', 'DifferenceAxes');
        cla(ax3);
        title(ax3, 'Difference');

        ax4 = findobj(parent, 'Tag', 'SpectrumAxes');
        cla(ax4);
        title(ax4, 'Log Spectrum');

        ax5 = findobj(parent, 'Tag', 'FilterAxes');
        cla(ax5);
        title(ax5, 'Homomorphic Filter');

        % Update info
        infoText = findobj(parent, 'Tag', 'InfoText');
        infoText.Value = {sprintf('Test image loaded: %s', selectedFile), ...
                         sprintf('Size: %d x %d', size(img, 1), size(img, 2)), ...
                         sprintf('Type: %s', ternary(size(img, 3) == 3, 'Color (RGB)', 'Grayscale'))};
    end
end

function clearAllTask4(parent)
    parent.UserData.originalImage = [];
    parent.UserData.enhancedImage = [];

    % Clear all axes
    ax1 = findobj(parent, 'Tag', 'OriginalAxes');
    cla(ax1);
    title(ax1, 'Original Image');

    ax2 = findobj(parent, 'Tag', 'EnhancedAxes');
    cla(ax2);
    title(ax2, 'Enhanced Image');

    ax3 = findobj(parent, 'Tag', 'DifferenceAxes');
    cla(ax3);
    title(ax3, 'Difference');

    ax4 = findobj(parent, 'Tag', 'SpectrumAxes');
    cla(ax4);
    title(ax4, 'Log Spectrum');

    ax5 = findobj(parent, 'Tag', 'FilterAxes');
    cla(ax5);
    title(ax5, 'Homomorphic Filter');

    % Clear info
    infoText = findobj(parent, 'Tag', 'InfoText');
    infoText.Value = 'Cleared. Load an image to start...';
end

%% Utility Functions

function result = ternary(condition, trueVal, falseVal)
% TERNARY Simple ternary operator equivalent
    if condition
        result = trueVal;
    else
        result = falseVal;
    end
end

%% Task 5: Noise Addition and Removal
function createTask5Tab(parent)
    % Task 5: Penambahan dan Penghilangan Derau

    % Store data in parent's UserData
    data = struct();
    data.originalImage = [];
    data.noisyImage = [];
    data.filteredImage = [];
    parent.UserData = data;

    % Control Panel
    controlPanel = uipanel(parent, 'Title', 'Controls', ...
                          'Position', [10, 10, 280, 650]);

    % Load Image Button
    uibutton(controlPanel, 'Position', [10, 480, 125, 30], ...
             'Text', 'Load Image', ...
             'ButtonPushedFcn', @(btn,event) loadImageTask5(parent));

    % Load Test Image Button
    uibutton(controlPanel, 'Position', [145, 480, 115, 30], ...
             'Text', 'Load Test', ...
             'ButtonPushedFcn', @(btn,event) loadTestImageTask5(parent));

    % Noise Type
    uilabel(controlPanel, 'Position', [10, 450, 100, 22], 'Text', 'Noise Type:');
    noiseType = uidropdown(controlPanel, 'Position', [120, 450, 150, 22], ...
                          'Items', {'Salt & Pepper', 'Gaussian'}, ...
                          'Value', 'Salt & Pepper');

    % Noise Parameters
    uilabel(controlPanel, 'Position', [10, 420, 150, 22], 'Text', 'Noise Density/Variance:');
    noiseParam = uispinner(controlPanel, 'Position', [170, 420, 100, 22], ...
                          'Value', 0.05, 'Limits', [0, 1], 'Step', 0.01);

    % Add Noise Button
    uibutton(controlPanel, 'Position', [10, 380, 260, 30], ...
             'Text', 'Add Noise', ...
             'ButtonPushedFcn', @(btn,event) addNoiseTask5(parent, noiseType, noiseParam));

    % Filter Type
    uilabel(controlPanel, 'Position', [10, 350, 100, 22], 'Text', 'Filter Type:');
    filterType = uidropdown(controlPanel, 'Position', [10, 320, 260, 22], ...
                           'Items', {'Min Filter', 'Max Filter', 'Median Filter', ...
                                    'Arithmetic Mean', 'Geometric Mean', 'Harmonic Mean', ...
                                    'Contraharmonic Mean', 'Midpoint', 'Alpha-trimmed Mean'}, ...
                           'Value', 'Median Filter');

    % Filter Size
    uilabel(controlPanel, 'Position', [10, 290, 100, 22], 'Text', 'Filter Size:');
    filterSize = uispinner(controlPanel, 'Position', [120, 290, 150, 22], ...
                          'Value', 3, 'Limits', [3, 15], 'Step', 2);

    % Q parameter for Contraharmonic
    uilabel(controlPanel, 'Position', [10, 260, 150, 22], 'Text', 'Q (Contraharmonic):');
    qParam = uispinner(controlPanel, 'Position', [170, 260, 100, 22], ...
                      'Value', 1.5, 'Limits', [-5, 5], 'Step', 0.5);

    % D parameter for Alpha-trimmed
    uilabel(controlPanel, 'Position', [10, 230, 150, 22], 'Text', 'D (Alpha-trimmed):');
    dParam = uispinner(controlPanel, 'Position', [170, 230, 100, 22], ...
                      'Value', 2, 'Limits', [0, 10], 'Step', 1);

    % Apply Filter Button
    uibutton(controlPanel, 'Position', [10, 190, 260, 30], ...
             'Text', 'Apply Filter', ...
             'ButtonPushedFcn', @(btn,event) applyFilterTask5(parent, filterType, filterSize, qParam, dParam));

    % Clear Button
    uibutton(controlPanel, 'Position', [10, 150, 260, 30], ...
             'Text', 'Clear All', ...
             'ButtonPushedFcn', @(btn,event) clearAllTask5(parent));

    % Display Panel
    displayPanel = uipanel(parent, 'Title', 'Image Display', ...
                          'Position', [300, 10, 860, 650]);

    % Image axes
    ax1 = uiaxes(displayPanel, 'Position', [10, 280, 270, 230]);
    title(ax1, 'Original Image');
    ax1.Tag = 'OriginalAxes';

    ax2 = uiaxes(displayPanel, 'Position', [295, 280, 270, 230]);
    title(ax2, 'Noisy Image');
    ax2.Tag = 'NoisyAxes';

    ax3 = uiaxes(displayPanel, 'Position', [580, 280, 270, 230]);
    title(ax3, 'Filtered Image');
    ax3.Tag = 'FilteredAxes';

    % Info text
    infoText = uitextarea(displayPanel, 'Position', [10, 10, 840, 260], ...
                         'Value', 'Load an image to start...', ...
                         'Editable', 'off');
    infoText.Tag = 'InfoText';
end

%% Task 6: Periodic Noise Removal
function createTask6Tab(parent)
    % Task 6: Penghilangan Derau Periodik

    % Store data
    data = struct();
    data.originalImage = [];
    data.cleanedImage = [];
    parent.UserData = data;

    % Control Panel
    controlPanel = uipanel(parent, 'Title', 'Controls', ...
                          'Position', [10, 10, 280, 650]);

    % Load Image
    uibutton(controlPanel, 'Position', [10, 480, 125, 30], ...
             'Text', 'Load Image', ...
             'ButtonPushedFcn', @(btn,event) loadImageTask6(parent));

    % Load Test Image Button
    uibutton(controlPanel, 'Position', [145, 480, 115, 30], ...
             'Text', 'Load Test', ...
             'ButtonPushedFcn', @(btn,event) loadTestImageTask6(parent));

    % Parameters
    uilabel(controlPanel, 'Position', [10, 210, 150, 22], 'Text', 'Parameters:', ...
            'FontWeight', 'bold');

    uilabel(controlPanel, 'Position', [10, 190, 150, 22], 'Text', 'Filter Type:');
    filterType = uidropdown(controlPanel, 'Position', [170, 190, 100, 22], ...
                            'Items', {'Auto', 'Band Reject', 'Band Pass', 'Notch'}, ...
                            'Value', 'Auto');
    filterType.Tag = 'FilterTypeDropdown';

    uilabel(controlPanel, 'Position', [10, 160, 150, 22], 'Text', 'Median Kernel Size:');
    medianKernel = uispinner(controlPanel, 'Position', [170, 160, 100, 22], ...
                            'Value', 31, 'Limits', [5, 101], 'Step', 2);

    uilabel(controlPanel, 'Position', [10, 130, 150, 22], 'Text', 'Notch Radius:');
    notchRadius = uispinner(controlPanel, 'Position', [170, 130, 100, 22], ...
                           'Value', 10, 'Limits', [1, 50], 'Step', 1);

    uilabel(controlPanel, 'Position', [10, 100, 150, 22], 'Text', 'Center Radius:');
    centerRadius = uispinner(controlPanel, 'Position', [170, 100, 100, 22], ...
                            'Value', 10, 'Limits', [5, 50], 'Step', 1);

    % Remove Noise
    uibutton(controlPanel, 'Position', [10, 60, 260, 30], ...
             'Text', 'Remove Periodic Noise', ...
             'ButtonPushedFcn', @(btn,event) removePeriodicNoiseTask6(parent, medianKernel, notchRadius, centerRadius, filterType));

    % Clear
    uibutton(controlPanel, 'Position', [10, 10, 260, 30], ...
             'Text', 'Clear All', ...
             'ButtonPushedFcn', @(btn,event) clearAllTask6(parent));

    % Display Panel
    displayPanel = uipanel(parent, 'Title', 'Image Display', ...
                          'Position', [300, 10, 860, 650]);

    % Image axes
    ax1 = uiaxes(displayPanel, 'Position', [10, 280, 270, 230]);
    title(ax1, 'Original Image');
    ax1.Tag = 'OriginalAxes';

    ax2 = uiaxes(displayPanel, 'Position', [295, 280, 270, 230]);
    title(ax2, 'Filtered Image');
    ax2.Tag = 'FilteredAxes';

    ax3 = uiaxes(displayPanel, 'Position', [580, 280, 270, 230]);
    title(ax3, 'Difference');
    ax3.Tag = 'DifferenceAxes';

    % Spectrum display
    ax4 = uiaxes(displayPanel, 'Position', [10, 10, 270, 230]);
    title(ax4, 'FFT Spectrum');
    ax4.Tag = 'SpectrumAxes';

    ax5 = uiaxes(displayPanel, 'Position', [295, 10, 270, 230]);
    title(ax5, 'Filter Response');
    ax5.Tag = 'FilterAxes';

    % Info text
    infoText = uitextarea(displayPanel, 'Position', [580, 10, 270, 230], ...
                         'Value', 'Load an image to start...', ...
                         'Editable', 'off');
    infoText.Tag = 'InfoText';
end

%% Task 7: Motion Blur and Deblur
function createTask7Tab(parent)
    % Task 7: Motion Blurring dan Dekonvolusi (Wiener Filter)

    % Store data
    data = struct();
    data.originalImage = [];
    data.blurredImage = [];
    data.restoredImage = [];
    parent.UserData = data;

    % Control Panel
    controlPanel = uipanel(parent, 'Title', 'Controls', ...
                          'Position', [10, 10, 280, 650]);

    % Load Image
    uibutton(controlPanel, 'Position', [10, 480, 125, 30], ...
             'Text', 'Load Image', ...
             'ButtonPushedFcn', @(btn,event) loadImageTask7(parent));

    % Load Test Image Button
    uibutton(controlPanel, 'Position', [145, 480, 115, 30], ...
             'Text', 'Load Test', ...
             'ButtonPushedFcn', @(btn,event) loadTestImageTask7(parent));

    % Motion Blur Parameters
    blurLenLabel = uilabel(controlPanel, 'Position', [10, 450, 150, 22], 'Text', 'Blur Length:');
    blurLenLabel.Tag = 'BlurControl';
    blurLen = uispinner(controlPanel, 'Position', [170, 450, 100, 22], ...
                       'Value', 20, 'Limits', [1, 100], 'Step', 1);
    blurLen.Tag = 'BlurControl';

    blurAngleLabel = uilabel(controlPanel, 'Position', [10, 420, 150, 22], 'Text', 'Blur Angle (deg):');
    blurAngleLabel.Tag = 'BlurControl';
    blurAngle = uispinner(controlPanel, 'Position', [170, 420, 100, 22], ...
                         'Value', 0, 'Limits', [0, 360], 'Step', 15);
    blurAngle.Tag = 'BlurControl';

    % Skip Blur Checkbox
    skipBlurCheckbox = uicheckbox(controlPanel, 'Position', [10, 385, 200, 22], ...
                                  'Text', 'Image is already blurred', ...
                                  'Value', false, ...
                                  'ValueChangedFcn', @(cb, event) toggleBlurControls(parent, cb));

    % Apply Motion Blur
    applyBlurButton = uibutton(controlPanel, 'Position', [10, 350, 260, 30], ...
             'Text', 'Apply Motion Blur', ...
             'ButtonPushedFcn', @(btn,event) applyMotionBlurTask7(parent, blurLen, blurAngle));
    applyBlurButton.Tag = 'ApplyBlurButton';

    % Wiener Filter Parameters
    uilabel(controlPanel, 'Position', [10, 310, 150, 22], 'Text', 'NSR (Noise-to-Signal):');
    nsr = uispinner(controlPanel, 'Position', [170, 310, 100, 22], ...
                   'Value', 0.001, 'Limits', [0, 1], 'Step', 0.001, ...
                   'ValueDisplayFormat', '%.4f');

    % Apply Wiener Filter
    uibutton(controlPanel, 'Position', [10, 270, 260, 30], ...
             'Text', 'Apply Wiener Filter', ...
             'ButtonPushedFcn', @(btn,event) applyWienerFilterTask7(parent, blurLen, blurAngle, nsr, skipBlurCheckbox));

    % Clear
    uibutton(controlPanel, 'Position', [10, 230, 260, 30], ...
             'Text', 'Clear All', ...
             'ButtonPushedFcn', @(btn,event) clearAllTask7(parent));

    % Display Panel
    displayPanel = uipanel(parent, 'Title', 'Image Display', ...
                          'Position', [300, 10, 860, 650]);

    % Image axes
    ax1 = uiaxes(displayPanel, 'Position', [10, 280, 270, 230]);
    title(ax1, 'Original Image');
    ax1.Tag = 'OriginalAxes';

    ax2 = uiaxes(displayPanel, 'Position', [295, 280, 270, 230]);
    title(ax2, 'Motion Blurred');
    ax2.Tag = 'BlurredAxes';

    ax3 = uiaxes(displayPanel, 'Position', [580, 280, 270, 230]);
    title(ax3, 'Wiener Restored');
    ax3.Tag = 'RestoredAxes';

    % Info text
    infoText = uitextarea(displayPanel, 'Position', [10, 10, 840, 260], ...
                         'Value', 'Load an image to start...', ...
                         'Editable', 'off');
    infoText.Tag = 'InfoText';
end

%% Helper Functions for Task 5

function loadImageTask5(parent)
    [file, path] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp;*.tif', 'Image Files'});
    if isequal(file, 0)
        return;
    end

    img = imread(fullfile(path, file));

    % Store in parent data
    parent.UserData.originalImage = img;
    parent.UserData.noisyImage = [];
    parent.UserData.filteredImage = [];

    % Display
    ax = findobj(parent, 'Tag', 'OriginalAxes');
    imshow(img, 'Parent', ax);
    title(ax, 'Original Image');

    % Clear other axes
    ax2 = findobj(parent, 'Tag', 'NoisyAxes');
    cla(ax2);
    title(ax2, 'Noisy Image');

    ax3 = findobj(parent, 'Tag', 'FilteredAxes');
    cla(ax3);
    title(ax3, 'Filtered Image');

    % Update info
    infoText = findobj(parent, 'Tag', 'InfoText');
    infoText.Value = {sprintf('Image loaded: %s', file), ...
                     sprintf('Size: %d x %d', size(img, 1), size(img, 2))};
end

function addNoiseTask5(parent, noiseType, noiseParam)
    if isempty(parent.UserData.originalImage)
        uialert(ancestor(parent, 'figure'), 'Please load an image first!', 'Error');
        return;
    end

    img = parent.UserData.originalImage;

    % Add path to task5 folder
    task5Path = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'task5');
    addpath(task5Path);

    try
        if strcmp(noiseType.Value, 'Salt & Pepper')
            noisyImg = add_salt_pepper_noise(img, noiseParam.Value);
        else % Gaussian
            noisyImg = add_gaussian_noise(img, 0, noiseParam.Value);
        end

        parent.UserData.noisyImage = noisyImg;

        % Display
        ax = findobj(parent, 'Tag', 'NoisyAxes');
        imshow(noisyImg, 'Parent', ax);
        title(ax, sprintf('Noisy Image (%s)', noiseType.Value));

        % Update info
        infoText = findobj(parent, 'Tag', 'InfoText');
        infoText.Value = {sprintf('Noise Type: %s', noiseType.Value), ...
                         sprintf('Parameter: %.3f', noiseParam.Value), ...
                         'Ready to apply filter...'};
    catch ME
        uialert(ancestor(parent, 'figure'), ME.message, 'Error');
    end
end

function applyFilterTask5(parent, filterType, filterSize, qParam, dParam)
    if isempty(parent.UserData.noisyImage)
        uialert(ancestor(parent, 'figure'), 'Please add noise first!', 'Error');
        return;
    end

    img = parent.UserData.noisyImage;
    n = filterSize.Value;

    % Add path to task5 folder
    task5Path = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'task5');
    addpath(task5Path);

    % Create progress dialog
    dlg = uiprogressdlg(ancestor(parent, 'figure'), 'Title', 'Processing Noise Filter...', ...
                        'Message', 'Applying noise removal filter...', ...
                        'Indeterminate', 'on');

    % Disable controls during processing
    controlPanel = findobj(parent, 'Type', 'uipanel', 'Title', 'Controls');
    set(findobj(controlPanel, 'Type', 'uibutton'), 'Enable', 'off');
    set(findobj(controlPanel, 'Type', 'uidropdown'), 'Enable', 'off');
    set(findobj(controlPanel, 'Type', 'uispinner'), 'Enable', 'off');

    try
        tic;
        switch filterType.Value
            case 'Min Filter'
                filtered = min_filter(img, n);
            case 'Max Filter'
                filtered = max_filter(img, n);
            case 'Median Filter'
                filtered = median_filter(img, n);
            case 'Arithmetic Mean'
                filtered = arithmetic_mean_filter(img, n);
            case 'Geometric Mean'
                filtered = geometric_mean_filter(img, n);
            case 'Harmonic Mean'
                filtered = harmonic_mean_filter(img, n);
            case 'Contraharmonic Mean'
                filtered = contraharmonic_mean_filter(img, n, qParam.Value);
            case 'Midpoint'
                filtered = midpoint_filter(img, n);
            case 'Alpha-trimmed Mean'
                filtered = alpha_trimmed_mean_filter(img, n, dParam.Value);
        end
        elapsedTime = toc;

        parent.UserData.filteredImage = filtered;

        % Display
        ax = findobj(parent, 'Tag', 'FilteredAxes');
        imshow(filtered, 'Parent', ax);
        title(ax, sprintf('Filtered (%s)', filterType.Value));

        % Calculate metrics
        if ~isempty(parent.UserData.originalImage)
            mseVal = mean((parent.UserData.originalImage(:) - filtered(:)).^2);
            psnrVal = 10 * log10(1 / mseVal);

            infoText = findobj(parent, 'Tag', 'InfoText');
            infoText.Value = {sprintf('Filter: %s', filterType.Value), ...
                             sprintf('Filter Size: %d x %d', n, n), ...
                             sprintf('Processing Time: %.3f seconds', elapsedTime), ...
                             sprintf('MSE: %.6f', mseVal), ...
                             sprintf('PSNR: %.2f dB', psnrVal)};
        end

        % Close progress dialog and re-enable controls
        close(dlg);
        set(findobj(controlPanel, 'Type', 'uibutton'), 'Enable', 'on');
        set(findobj(controlPanel, 'Type', 'uidropdown'), 'Enable', 'on');
        set(findobj(controlPanel, 'Type', 'uispinner'), 'Enable', 'on');

    catch ME
        % Close progress dialog and re-enable controls on error
        close(dlg);
        set(findobj(controlPanel, 'Type', 'uibutton'), 'Enable', 'on');
        set(findobj(controlPanel, 'Type', 'uidropdown'), 'Enable', 'on');
        set(findobj(controlPanel, 'Type', 'uispinner'), 'Enable', 'on');
        uialert(ancestor(parent, 'figure'), ME.message, 'Error');
    end
end

function loadTestImageTask5(parent)
    % Load test images from task5 folder
    task5Path = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'task5', 'test_images');

    % Get list of test images
    imageFiles = dir(fullfile(task5Path, '*.jpg'));
    if isempty(imageFiles)
        imageFiles = dir(fullfile(task5Path, '*.jpeg'));
    end
    if isempty(imageFiles)
        imageFiles = dir(fullfile(task5Path, '*.png'));
    end

    if isempty(imageFiles)
        uialert(ancestor(parent, 'figure'), 'No test images found in task5/test_images folder!', 'Error');
        return;
    end

    % Create selection dialog
    imageNames = {imageFiles.name};
    [idx, tf] = listdlg('ListString', imageNames, 'SelectionMode', 'single', ...
                       'Name', 'Select Test Image', 'PromptString', 'Choose a test image:');

    if tf
        selectedFile = imageNames{idx};
        img = imread(fullfile(task5Path, selectedFile));

        % Store in parent data
        parent.UserData.originalImage = img;
        parent.UserData.noisyImage = [];
        parent.UserData.filteredImage = [];

        % Display
        ax = findobj(parent, 'Tag', 'OriginalAxes');
        imshow(img, 'Parent', ax);
        title(ax, 'Original Image');

        % Clear other axes
        ax2 = findobj(parent, 'Tag', 'NoisyAxes');
        cla(ax2);
        title(ax2, 'Noisy Image');

        ax3 = findobj(parent, 'Tag', 'FilteredAxes');
        cla(ax3);
        title(ax3, 'Filtered Image');

        % Update info
        infoText = findobj(parent, 'Tag', 'InfoText');
        infoText.Value = {sprintf('Test image loaded: %s', selectedFile), ...
                         sprintf('Size: %d x %d', size(img, 1), size(img, 2))};
    end
end

function clearAllTask5(parent)
    parent.UserData.originalImage = [];
    parent.UserData.noisyImage = [];
    parent.UserData.filteredImage = [];

    % Clear all axes
    ax1 = findobj(parent, 'Tag', 'OriginalAxes');
    cla(ax1);
    title(ax1, 'Original Image');

    ax2 = findobj(parent, 'Tag', 'NoisyAxes');
    cla(ax2);
    title(ax2, 'Noisy Image');

    ax3 = findobj(parent, 'Tag', 'FilteredAxes');
    cla(ax3);
    title(ax3, 'Filtered Image');

    % Clear info
    infoText = findobj(parent, 'Tag', 'InfoText');
    infoText.Value = 'Cleared. Load an image to start...';
end

%% Helper Functions for Task 6

function loadImageTask6(parent)
    [file, path] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp;*.tif', 'Image Files'});
    if isequal(file, 0)
        return;
    end

    img = imread(fullfile(path, file));

    parent.UserData.originalImage = img;
    parent.UserData.cleanedImage = [];

    ax = findobj(parent, 'Tag', 'OriginalAxes');
    imshow(img, 'Parent', ax);
    title(ax, 'Original Image');

    % Clear other axes
    ax2 = findobj(parent, 'Tag', 'FilteredAxes');
    cla(ax2);
    title(ax2, 'Filtered Image');

    ax3 = findobj(parent, 'Tag', 'DifferenceAxes');
    cla(ax3);
    title(ax3, 'Difference');

    ax4 = findobj(parent, 'Tag', 'SpectrumAxes');
    cla(ax4);
    title(ax4, 'FFT Spectrum');

    ax5 = findobj(parent, 'Tag', 'FilterAxes');
    cla(ax5);
    title(ax5, 'Filter Response');

    infoText = findobj(parent, 'Tag', 'InfoText');
    infoText.Value = {sprintf('Image loaded: %s', file), ...
                     sprintf('Size: %d x %d', size(img, 1), size(img, 2)), ...
                     'Ready to apply periodic noise removal.'};
end

function removePeriodicNoiseTask6(parent, medianKernel, notchRadius, centerRadius, filterTypeDropdown)
    if isempty(parent.UserData.originalImage)
        uialert(ancestor(parent, 'figure'), 'Please load an image first!', 'Error');
        return;
    end

    img = parent.UserData.originalImage;
    selectedFilter = lower(strrep(filterTypeDropdown.Value, ' ', ''));
    validFilters = {'auto', 'bandreject', 'bandpass', 'notch'};
    if ~ismember(selectedFilter, validFilters)
        selectedFilter = 'auto';
    end

    task6Path = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'task6');
    addpath(task6Path);

    % Create progress dialog
    dlg = uiprogressdlg(ancestor(parent, 'figure'), 'Title', 'Processing Periodic Noise Removal...', ...
                        'Message', 'Analyzing spectrum and applying filters...', ...
                        'Indeterminate', 'on');

    % Disable controls during processing
    controlPanel = findobj(parent, 'Type', 'uipanel', 'Title', 'Controls');
    set(findobj(controlPanel, 'Type', 'uibutton'), 'Enable', 'off');
    set(findobj(controlPanel, 'Type', 'uidropdown'), 'Enable', 'off');
    set(findobj(controlPanel, 'Type', 'uispinner'), 'Enable', 'off');

    try
        tic;
        [filteredImg, info] = removePeriodicNoise(img, 'MedianKernelSize', medianKernel.Value, ...
                                                 'NotchRadius', notchRadius.Value, ...
                                                 'CenterRadius', centerRadius.Value, ...
                                                 'FilterType', selectedFilter);
        elapsedTime = toc;

        parent.UserData.cleanedImage = filteredImg;

        % Display filtered image
        ax2 = findobj(parent, 'Tag', 'FilteredAxes');
        imshow(filteredImg, 'Parent', ax2);
        title(ax2, 'Filtered Image');

        % Display difference (ensure both are in double format and same dimensions)
        % If original is RGB but filtered is grayscale, convert original to grayscale
        if size(img, 3) == 3 && size(filteredImg, 3) == 1
            imgForDiff = rgb2gray(img);
        else
            imgForDiff = img;
        end
        
        imgDouble = im2double(imgForDiff);
        filteredDouble = im2double(filteredImg);
        
        diffImg = abs(filteredDouble - imgDouble);

        ax3 = findobj(parent, 'Tag', 'DifferenceAxes');
        % Amplify difference for better visibility
        imshow(diffImg * 10, 'Parent', ax3);
        title(ax3, 'Difference (10x)');

        % Display spectrum
        ax4 = findobj(parent, 'Tag', 'SpectrumAxes');
        imshow(info.spectrum, [], 'Parent', ax4);
        title(ax4, 'FFT Spectrum');
        colormap(ax4, 'jet');

        % Display filter
        ax5 = findobj(parent, 'Tag', 'FilterAxes');
        imshow(info.filter, [], 'Parent', ax5);
        title(ax5, 'Applied Filter');
        colormap(ax5, 'jet');

        % Calculate metrics (use double format to avoid type mismatch)
        mseVal = mean((imgDouble(:) - filteredDouble(:)).^2);
        if mseVal > 0
            psnrVal = 10 * log10(1 / mseVal);
        else
            psnrVal = Inf;
        end

        switch info.filterType
            case 'bandreject'
                filterLabel = 'Band Reject';
            case 'bandpass'
                filterLabel = 'Band Pass';
            case 'notch'
                filterLabel = 'Notch';
            case 'auto'
                filterLabel = 'Auto';
            otherwise
                filterLabel = 'Identity';
        end

        infoText = findobj(parent, 'Tag', 'InfoText');
        infoText.Value = {sprintf('Periodic noise removal completed'), ...
                         sprintf('Filter applied: %s', filterLabel), ...
                         sprintf('Peaks detected: %d', size(info.peaks, 1)), ...
                         sprintf('Symmetric pairs: %d', size(info.pairs, 1)), ...
                         sprintf('Processing Time: %.3f seconds', elapsedTime), ...
                         sprintf('MSE: %.6f', mseVal), ...
                         sprintf('PSNR: %.2f dB', psnrVal)};

        % Close progress dialog and re-enable controls
        close(dlg);
        set(findobj(controlPanel, 'Type', 'uibutton'), 'Enable', 'on');
        set(findobj(controlPanel, 'Type', 'uidropdown'), 'Enable', 'on');
        set(findobj(controlPanel, 'Type', 'uispinner'), 'Enable', 'on');

    catch ME
        % Close progress dialog and re-enable controls on error
        close(dlg);
        set(findobj(controlPanel, 'Type', 'uibutton'), 'Enable', 'on');
        set(findobj(controlPanel, 'Type', 'uidropdown'), 'Enable', 'on');
        set(findobj(controlPanel, 'Type', 'uispinner'), 'Enable', 'on');
        uialert(ancestor(parent, 'figure'), ME.message, 'Error');
    end
end

function loadTestImageTask6(parent)
    % Load test images from task6 folder
    task6Path = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'task6', 'test_images');

    % Get list of test images
    imageFiles = dir(fullfile(task6Path, '*.png'));
    if isempty(imageFiles)
        imageFiles = dir(fullfile(task6Path, '*.jpg'));
    end
    if isempty(imageFiles)
        imageFiles = dir(fullfile(task6Path, '*.jpeg'));
    end

    if isempty(imageFiles)
        uialert(ancestor(parent, 'figure'), 'No test images found in task6/test_images folder!', 'Error');
        return;
    end

    % Create selection dialog
    imageNames = {imageFiles.name};
    [idx, tf] = listdlg('ListString', imageNames, 'SelectionMode', 'single', ...
                       'Name', 'Select Test Image', 'PromptString', 'Choose a test image:');

    if tf
        selectedFile = imageNames{idx};
        img = imread(fullfile(task6Path, selectedFile));

        parent.UserData.originalImage = img;
        parent.UserData.cleanedImage = [];

        ax = findobj(parent, 'Tag', 'OriginalAxes');
        imshow(img, 'Parent', ax);
        title(ax, 'Original Image');

        % Clear other axes
        ax2 = findobj(parent, 'Tag', 'FilteredAxes');
        cla(ax2);
        title(ax2, 'Filtered Image');

        ax3 = findobj(parent, 'Tag', 'DifferenceAxes');
        cla(ax3);
        title(ax3, 'Difference');

        ax4 = findobj(parent, 'Tag', 'SpectrumAxes');
        cla(ax4);
        title(ax4, 'FFT Spectrum');

        ax5 = findobj(parent, 'Tag', 'FilterAxes');
        cla(ax5);
        title(ax5, 'Filter Response');

        infoText = findobj(parent, 'Tag', 'InfoText');
        infoText.Value = {sprintf('Test image loaded: %s', selectedFile), ...
                         sprintf('Size: %d x %d', size(img, 1), size(img, 2)), ...
                         'Ready to apply periodic noise removal.'};
    end
end

function clearAllTask6(parent)
    parent.UserData.originalImage = [];
    parent.UserData.cleanedImage = [];

    ax1 = findobj(parent, 'Tag', 'OriginalAxes');
    cla(ax1);
    title(ax1, 'Original Image');

    ax2 = findobj(parent, 'Tag', 'FilteredAxes');
    cla(ax2);
    title(ax2, 'Filtered Image');

    ax3 = findobj(parent, 'Tag', 'DifferenceAxes');
    cla(ax3);
    title(ax3, 'Difference');

    ax4 = findobj(parent, 'Tag', 'SpectrumAxes');
    cla(ax4);
    title(ax4, 'FFT Spectrum');

    ax5 = findobj(parent, 'Tag', 'FilterAxes');
    cla(ax5);
    title(ax5, 'Filter Response');

    infoText = findobj(parent, 'Tag', 'InfoText');
    infoText.Value = 'Cleared. Load an image to start...';
end

%% Helper Functions for Task 7

function loadImageTask7(parent)
    [file, path] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp;*.tif', 'Image Files'});
    if isequal(file, 0)
        return;
    end

    img = imread(fullfile(path, file));

    parent.UserData.originalImage = img;
    parent.UserData.blurredImage = [];
    parent.UserData.restoredImage = [];

    ax = findobj(parent, 'Tag', 'OriginalAxes');
    imshow(img, 'Parent', ax);
    title(ax, 'Original Image');

    % Update display based on skip blur checkbox state
    skipBlurCheckbox = findobj(parent, 'Type', 'uicheckbox', 'Text', 'Image is already blurred');
    if ~isempty(skipBlurCheckbox)
        toggleBlurControls(parent, skipBlurCheckbox);
    end

    ax3 = findobj(parent, 'Tag', 'RestoredAxes');
    cla(ax3);

    infoText = findobj(parent, 'Tag', 'InfoText');
    infoText.Value = {sprintf('Image loaded: %s', file), ...
                     sprintf('Size: %d x %d', size(img, 1), size(img, 2))};
end

function applyMotionBlurTask7(parent, blurLen, blurAngle)
    if isempty(parent.UserData.originalImage)
        uialert(ancestor(parent, 'figure'), 'Please load an image first!', 'Error');
        return;
    end

    img = parent.UserData.originalImage;

    task7Path = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'task7');
    addpath(task7Path);

    try
        tic;
        blurredImg = motion_blur(img, blurLen.Value, blurAngle.Value);
        elapsedTime = toc;

        parent.UserData.blurredImage = blurredImg;

        ax = findobj(parent, 'Tag', 'BlurredAxes');
        imshow(blurredImg, 'Parent', ax);
        title(ax, sprintf('Motion Blurred (L=%d, θ=%d°)', blurLen.Value, blurAngle.Value));

        infoText = findobj(parent, 'Tag', 'InfoText');
        infoText.Value = {sprintf('Motion blur applied'), ...
                         sprintf('Length: %d pixels', blurLen.Value), ...
                         sprintf('Angle: %d degrees', blurAngle.Value), ...
                         sprintf('Processing Time: %.3f seconds', elapsedTime)};
    catch ME
        uialert(ancestor(parent, 'figure'), ME.message, 'Error');
    end
end

function applyWienerFilterTask7(parent, blurLen, blurAngle, nsr, skipBlurCheckbox)
    % Check if image is already blurred
    if skipBlurCheckbox.Value
        % Image is already blurred, use original image directly
        if isempty(parent.UserData.originalImage)
            uialert(ancestor(parent, 'figure'), 'Please load an image first!', 'Error');
            return;
        end
        img = parent.UserData.originalImage;
        imgType = 'pre-blurred';
    else
        % Image needs to be blurred first
        if isempty(parent.UserData.blurredImage)
            uialert(ancestor(parent, 'figure'), 'Please apply motion blur first!', 'Error');
            return;
        end
        img = parent.UserData.blurredImage;
        imgType = 'motion-blurred';
    end

    task7Path = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'task7');
    addpath(task7Path);

    % Create progress dialog
    dlg = uiprogressdlg(ancestor(parent, 'figure'), 'Title', 'Processing Wiener Filter...', ...
                        'Message', 'Applying motion deblur filter...', ...
                        'Indeterminate', 'on');

    % Disable controls during processing
    controlPanel = findobj(parent, 'Type', 'uipanel', 'Title', 'Controls');
    set(findobj(controlPanel, 'Type', 'uibutton'), 'Enable', 'off');
    set(findobj(controlPanel, 'Type', 'uidropdown'), 'Enable', 'off');
    set(findobj(controlPanel, 'Type', 'uispinner'), 'Enable', 'off');

    try
        tic;
        % Create PSF from blur parameters
        psf = fspecial('motion', blurLen.Value, blurAngle.Value);
        restoredImg = wiener_filter(img, psf, nsr.Value);
        elapsedTime = toc;

        parent.UserData.restoredImage = restoredImg;

        ax = findobj(parent, 'Tag', 'RestoredAxes');
        imshow(restoredImg, 'Parent', ax);
        title(ax, sprintf('Wiener Restored (NSR=%.4f)', nsr.Value));

        if ~isempty(parent.UserData.originalImage)
            mseVal = mean((parent.UserData.originalImage(:) - restoredImg(:)).^2);
            psnrVal = 10 * log10(1 / mseVal);

            infoText = findobj(parent, 'Tag', 'InfoText');
            infoText.Value = {sprintf('Wiener filter applied to %s image', imgType), ...
                             sprintf('NSR: %.4f', nsr.Value), ...
                             sprintf('Processing Time: %.3f seconds', elapsedTime), ...
                             sprintf('MSE: %.6f', mseVal), ...
                             sprintf('PSNR: %.2f dB', psnrVal), ...
                             '', ...
                             'Custom Wiener filter implementation (no built-in function used)'};
        end

        % Close progress dialog and re-enable controls
        close(dlg);
        set(findobj(controlPanel, 'Type', 'uibutton'), 'Enable', 'on');
        set(findobj(controlPanel, 'Type', 'uidropdown'), 'Enable', 'on');
        set(findobj(controlPanel, 'Type', 'uispinner'), 'Enable', 'on');

    catch ME
        % Close progress dialog and re-enable controls on error
        close(dlg);
        set(findobj(controlPanel, 'Type', 'uibutton'), 'Enable', 'on');
        set(findobj(controlPanel, 'Type', 'uidropdown'), 'Enable', 'on');
        set(findobj(controlPanel, 'Type', 'uispinner'), 'Enable', 'on');
        uialert(ancestor(parent, 'figure'), ME.message, 'Error');
    end
end

function loadTestImageTask7(parent)
    % Load test images from task7 folder
    task7Path = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'task7', 'test_images');

    % Get list of test images
    imageFiles = dir(fullfile(task7Path, '*.png'));
    if isempty(imageFiles)
        imageFiles = dir(fullfile(task7Path, '*.jpg'));
    end
    if isempty(imageFiles)
        imageFiles = dir(fullfile(task7Path, '*.jpeg'));
    end

    if isempty(imageFiles)
        uialert(ancestor(parent, 'figure'), 'No test images found in task7/test_images folder!', 'Error');
        return;
    end

    % Create selection dialog
    imageNames = {imageFiles.name};
    [idx, tf] = listdlg('ListString', imageNames, 'SelectionMode', 'single', ...
                       'Name', 'Select Test Image', 'PromptString', 'Choose a test image:');

    if tf
        selectedFile = imageNames{idx};
        img = imread(fullfile(task7Path, selectedFile));

        parent.UserData.originalImage = img;
        parent.UserData.blurredImage = [];
        parent.UserData.restoredImage = [];

        ax = findobj(parent, 'Tag', 'OriginalAxes');
        imshow(img, 'Parent', ax);
        title(ax, 'Original Image');

        % Update display based on skip blur checkbox state
        skipBlurCheckbox = findobj(parent, 'Type', 'uicheckbox', 'Text', 'Image is already blurred');
        if ~isempty(skipBlurCheckbox)
            toggleBlurControls(parent, skipBlurCheckbox);
        end

        ax3 = findobj(parent, 'Tag', 'RestoredAxes');
        cla(ax3);

        infoText = findobj(parent, 'Tag', 'InfoText');
        infoText.Value = {sprintf('Test image loaded: %s', selectedFile), ...
                         sprintf('Size: %d x %d', size(img, 1), size(img, 2))};
    end
end

function toggleBlurControls(parent, checkbox)
    % Toggle visibility of blur controls and update display when skip blur checkbox changes
    controlPanel = findobj(parent, 'Type', 'uipanel', 'Title', 'Controls');
    blurControls = findobj(controlPanel, 'Tag', 'BlurControl');

    if checkbox.Value
        % Hide only the "Apply Motion Blur" button when image is already blurred
        applyBlurButton = findobj(controlPanel, 'Tag', 'ApplyBlurButton');
        set(applyBlurButton, 'Visible', 'off');

        % Show original image as "already blurred" if loaded
        ax2 = findobj(parent, 'Tag', 'BlurredAxes');
        if ~isempty(parent.UserData.originalImage)
            imshow(parent.UserData.originalImage, 'Parent', ax2);
            title(ax2, 'Already Blurred Image');
        end
    else
        % Show all blur controls when applying motion blur
        set(blurControls, 'Visible', 'on');

        % Clear the blurred image display
        ax2 = findobj(parent, 'Tag', 'BlurredAxes');
        cla(ax2);
        title(ax2, 'Motion Blurred');
    end
end

function clearAllTask7(parent)
    parent.UserData.originalImage = [];
    parent.UserData.blurredImage = [];
    parent.UserData.restoredImage = [];

    % Reset checkbox and show all controls
    skipBlurCheckbox = findobj(parent, 'Type', 'uicheckbox', 'Text', 'Image is already blurred');
    if ~isempty(skipBlurCheckbox)
        skipBlurCheckbox.Value = false;
        toggleBlurControls(parent, skipBlurCheckbox);
    end

    ax1 = findobj(parent, 'Tag', 'OriginalAxes');
    cla(ax1);
    title(ax1, 'Original Image');

    ax2 = findobj(parent, 'Tag', 'BlurredAxes');
    cla(ax2);
    title(ax2, 'Motion Blurred');

    ax3 = findobj(parent, 'Tag', 'RestoredAxes');
    cla(ax3);
    title(ax3, 'Wiener Restored');

    infoText = findobj(parent, 'Tag', 'InfoText');
    infoText.Value = 'Cleared. Load an image to start...';
end
