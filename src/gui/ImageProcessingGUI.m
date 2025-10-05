function ImageProcessingGUI()
    % Image Processing GUI - Integrates all image processing tasks
    % Course: IF4073 Pemrosesan Citra Digital
    % Semester: 2025/2026 - Semester I
    % Institution: Program Studi Teknik Informatika, STEI - ITB

    % Add paths to task folders
    addpath('../task1');
    addpath('../task2');
    addpath('../task3');
    addpath('../task4');

    % Create main figure
    fig = uifigure('Name', 'Image Processing GUI', ...
                   'Position', [100 100 1400 800], ...
                   'Color', [0.94 0.94 0.94]);

    % Global variables
    currentImage = [];
    referenceImage = [];
    processedImage = [];

    % Create menu bar
    mFile = uimenu(fig, 'Text', 'File');
    uimenu(mFile, 'Text', 'Load Image', 'MenuSelectedFcn', @loadImage);
    uimenu(mFile, 'Text', 'Load Reference Image', 'MenuSelectedFcn', @loadReferenceImage);
    uimenu(mFile, 'Text', 'Save Processed Image', 'MenuSelectedFcn', @saveImage);
    uimenu(mFile, 'Text', 'Exit', 'MenuSelectedFcn', @(~,~)close(fig), 'Separator', 'on');

    % Task 1: Histogram
    mTask1 = uimenu(fig, 'Text', 'Task 1 - Histogram');
    uimenu(mTask1, 'Text', 'Calculate Histogram', 'MenuSelectedFcn', @calculateHistogram);

    % Task 2: Image Enhancement
    mTask2 = uimenu(fig, 'Text', 'Task 2 - Enhancement');
    uimenu(mTask2, 'Text', 'Image Brightening', 'MenuSelectedFcn', @applyBrightening);
    uimenu(mTask2, 'Text', 'Image Negative', 'MenuSelectedFcn', @applyNegative);
    uimenu(mTask2, 'Text', 'Log Transformation', 'MenuSelectedFcn', @applyLogTransform);
    uimenu(mTask2, 'Text', 'Power Transformation', 'MenuSelectedFcn', @applyPowerTransform);
    uimenu(mTask2, 'Text', 'Contrast Stretching', 'MenuSelectedFcn', @applyContrastStretching);

    % Task 3: Histogram Equalization
    mTask3 = uimenu(fig, 'Text', 'Task 3 - Equalization');
    uimenu(mTask3, 'Text', 'Histogram Equalization', 'MenuSelectedFcn', @applyEqualization);

    % Task 4: Histogram Specification
    mTask4 = uimenu(fig, 'Text', 'Task 4 - Specification');
    uimenu(mTask4, 'Text', 'Histogram Matching', 'MenuSelectedFcn', @applyMatching);

    % Create panels
    inputPanel = uipanel(fig, 'Title', 'Input Image', ...
                        'Position', [20 420 420 360], ...
                        'BackgroundColor', 'white');

    inputHistPanel = uipanel(fig, 'Title', 'Input Histogram', ...
                            'Position', [20 20 420 380], ...
                            'BackgroundColor', 'white');

    outputPanel = uipanel(fig, 'Title', 'Output Image', ...
                         'Position', [960 420 420 360], ...
                         'BackgroundColor', 'white');

    outputHistPanel = uipanel(fig, 'Title', 'Output Histogram', ...
                             'Position', [960 20 420 380], ...
                             'BackgroundColor', 'white');

    referencePanel = uipanel(fig, 'Title', 'Reference Image (Task 4)', ...
                            'Position', [460 560 480 220], ...
                            'BackgroundColor', 'white');

    referenceHistPanel = uipanel(fig, 'Title', 'Reference Histogram', ...
                                'Position', [460 320 480 220], ...
                                'BackgroundColor', 'white');

    infoPanel = uipanel(fig, 'Title', 'Information', ...
                       'Position', [460 20 480 280], ...
                       'BackgroundColor', 'white');

    % Create axes for images
    inputAxes = uiaxes(inputPanel, 'Position', [10 10 400 330]);
    outputAxes = uiaxes(outputPanel, 'Position', [10 10 400 330]);
    referenceAxes = uiaxes(referencePanel, 'Position', [10 10 460 190]);

    % Create axes for histograms
    inputHistAxes = uiaxes(inputHistPanel, 'Position', [10 10 400 350]);
    outputHistAxes = uiaxes(outputHistPanel, 'Position', [10 10 400 350]);
    referenceHistAxes = uiaxes(referenceHistPanel, 'Position', [10 10 460 190]);

    % Create text area for info
    infoText = uitextarea(infoPanel, 'Position', [10 10 460 250], ...
                         'Editable', 'off', 'FontName', 'Courier New', ...
                         'Value', {'Welcome to Image Processing GUI!', '', ...
                                   'Instructions:', ...
                                   '1. Load an image using File > Load Image', ...
                                   '2. Select processing from Task menus', ...
                                   '3. View results in Output panels', ...
                                   '4. Save results using File > Save'});

    % Callback functions

    function loadImage(~, ~)
        [filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp;*.tif', 'Image Files'}, ...
                                        'Select an image');
        if filename ~= 0
            currentImage = imread(fullfile(pathname, filename));
            displayImage(inputAxes, currentImage);
            displayHistogram(inputHistAxes, currentImage);
            updateInfo(['Image loaded: ' filename]);
            cla(outputAxes);
            cla(outputHistAxes);

            % Bring figure to front
            figure(fig);
        end
    end

    function loadReferenceImage(~, ~)
        [filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp;*.tif', 'Image Files'}, ...
                                        'Select reference image');
        if filename ~= 0
            referenceImage = imread(fullfile(pathname, filename));
            displayImage(referenceAxes, referenceImage);
            displayHistogram(referenceHistAxes, referenceImage);
            updateInfo(['Reference image loaded: ' filename]);

            % Bring figure to front
            figure(fig);
        end
    end

    function saveImage(~, ~)
        if isempty(processedImage)
            uialert(fig, 'No processed image to save!', 'Error');
            return;
        end
        [filename, pathname] = uiputfile({'*.png', 'PNG Image'; ...
                                         '*.jpg', 'JPEG Image'; ...
                                         '*.bmp', 'BMP Image'}, ...
                                         'Save processed image');
        if filename ~= 0
            imwrite(processedImage, fullfile(pathname, filename));
            updateInfo(['Image saved: ' filename]);

            % Bring figure to front
            figure(fig);
        end
    end

    function calculateHistogram(~, ~)
        if isempty(currentImage)
            uialert(fig, 'Please load an image first!', 'Error');
            return;
        end

        displayHistogram(outputHistAxes, currentImage);
        updateInfo('Histogram calculated successfully!');
    end

    function applyBrightening(~, ~)
        if isempty(currentImage)
            uialert(fig, 'Please load an image first!', 'Error');
            return;
        end

        % Create dialog for parameters
        dlg = uifigure('Name', 'Brightening Parameters', 'Position', [500 500 300 150]);
        uilabel(dlg, 'Position', [20 100 100 22], 'Text', 'Multiplier (a):');
        aField = uieditfield(dlg, 'numeric', 'Position', [130 100 150 22], 'Value', 1.0);
        uilabel(dlg, 'Position', [20 60 100 22], 'Text', 'Offset (b):');
        bField = uieditfield(dlg, 'numeric', 'Position', [130 60 150 22], 'Value', 50);

        uibutton(dlg, 'Position', [100 20 100 30], 'Text', 'Apply', ...
                'ButtonPushedFcn', @(~,~)applyBrighteningCallback(aField.Value, bField.Value, dlg));
    end

    function applyBrighteningCallback(a, b, dlg)
        close(dlg);
        processedImage = image_brightening(currentImage, a, b);
        displayImage(outputAxes, processedImage);
        displayHistogram(outputHistAxes, processedImage);
        updateInfo(sprintf('Brightening applied: s = %.2f*r + %.2f', a, b));
    end

    function applyNegative(~, ~)
        if isempty(currentImage)
            uialert(fig, 'Please load an image first!', 'Error');
            return;
        end

        processedImage = image_negative(currentImage);
        displayImage(outputAxes, processedImage);
        displayHistogram(outputHistAxes, processedImage);
        updateInfo('Image negative applied: s = 255 - r');
    end

    function applyLogTransform(~, ~)
        if isempty(currentImage)
            uialert(fig, 'Please load an image first!', 'Error');
            return;
        end

        % Create dialog for parameter
        dlg = uifigure('Name', 'Log Transform Parameter', 'Position', [500 500 300 100]);
        uilabel(dlg, 'Position', [20 50 100 22], 'Text', 'Constant (c):');
        cField = uieditfield(dlg, 'numeric', 'Position', [130 50 150 22], 'Value', 1.0);

        uibutton(dlg, 'Position', [100 10 100 30], 'Text', 'Apply', ...
                'ButtonPushedFcn', @(~,~)applyLogCallback(cField.Value, dlg));
    end

    function applyLogCallback(c, dlg)
        close(dlg);
        processedImage = log_transformation(currentImage, c);
        displayImage(outputAxes, processedImage);
        displayHistogram(outputHistAxes, processedImage);
        updateInfo(sprintf('Log transform applied: s = %.2f * log(1 + r)', c));
    end

    function applyPowerTransform(~, ~)
        if isempty(currentImage)
            uialert(fig, 'Please load an image first!', 'Error');
            return;
        end

        % Create dialog for parameters
        dlg = uifigure('Name', 'Power Transform Parameters', 'Position', [500 500 300 150]);
        uilabel(dlg, 'Position', [20 100 100 22], 'Text', 'Constant (c):');
        cField = uieditfield(dlg, 'numeric', 'Position', [130 100 150 22], 'Value', 1.0);
        uilabel(dlg, 'Position', [20 60 100 22], 'Text', 'Gamma (γ):');
        gammaField = uieditfield(dlg, 'numeric', 'Position', [130 60 150 22], 'Value', 2.0);

        uibutton(dlg, 'Position', [100 20 100 30], 'Text', 'Apply', ...
                'ButtonPushedFcn', @(~,~)applyPowerCallback(cField.Value, gammaField.Value, dlg));
    end

    function applyPowerCallback(c, gamma, dlg)
        close(dlg);
        processedImage = power_transformation(currentImage, c, gamma);
        displayImage(outputAxes, processedImage);
        displayHistogram(outputHistAxes, processedImage);
        updateInfo(sprintf('Power transform applied: s = %.2f * r^%.2f', c, gamma));
    end

    function applyContrastStretching(~, ~)
        if isempty(currentImage)
            uialert(fig, 'Please load an image first!', 'Error');
            return;
        end

        processedImage = contrast_stretching(currentImage);
        displayImage(outputAxes, processedImage);
        displayHistogram(outputHistAxes, processedImage);
        updateInfo('Contrast stretching applied (automatic r_min, r_max)');
    end

    function applyEqualization(~, ~)
        if isempty(currentImage)
            uialert(fig, 'Please load an image first!', 'Error');
            return;
        end

        processedImage = histogram_equalization(currentImage);
        displayImage(outputAxes, processedImage);
        displayHistogram(outputHistAxes, processedImage);
        updateInfo('Histogram equalization applied');
    end

    function applyMatching(~, ~)
        if isempty(currentImage)
            uialert(fig, 'Please load an image first!', 'Error');
            return;
        end

        if isempty(referenceImage)
            uialert(fig, 'Please load a reference image first!', 'Error');
            return;
        end

        if ~isequal(size(currentImage), size(referenceImage))
            uialert(fig, 'Input and reference images must have the same dimensions!', 'Error');
            return;
        end

        processedImage = histogram_matching(currentImage, referenceImage);
        displayImage(outputAxes, processedImage);
        displayHistogram(outputHistAxes, processedImage);
        updateInfo('Histogram matching applied');
    end

    % Helper functions

    function displayImage(ax, img)
        imshow(img, 'Parent', ax);
        ax.XTick = [];
        ax.YTick = [];
    end

    function displayHistogram(ax, img)
        cla(ax);

        if size(img, 3) == 3
            % Color image - display RGB histograms
            colors = {'r', 'g', 'b'};
            hold(ax, 'on');
            for ch = 1:3
                hist_vals = calculate_histogram(img(:,:,ch));
                plot(ax, 0:255, hist_vals, colors{ch}, 'LineWidth', 1.5);
            end
            hold(ax, 'off');
            legend(ax, {'Red', 'Green', 'Blue'}, 'Location', 'best');
        else
            % Grayscale image
            hist_vals = calculate_histogram(img);
            bar(ax, 0:255, hist_vals, 'FaceColor', [0.3 0.3 0.3]);
        end

        ax.XLabel.String = 'Intensity';
        ax.YLabel.String = 'Frequency';
        ax.XLim = [0 255];
        grid(ax, 'on');
    end

    function updateInfo(message)
        timestamp = datestr(now, 'HH:MM:SS');
        currentText = infoText.Value;
        newMessage = {[timestamp ' - ' message]};

        % Combine with existing messages
        if isempty(currentText)
            newText = newMessage;
        else
            newText = [newMessage; currentText];
        end

        % Keep only last 20 messages
        infoText.Value = newText(1:min(20, length(newText)));
    end
end
