function ImageProcessingGUI()
    addpath('../task1');
    addpath('../task2');
    addpath('../task3');
    addpath('../task4');

    fig = uifigure('Name', 'Image Processing GUI - IF4073', ...
                   'Position', [100 100 1450 820], ...
                   'Color', [0.15 0.17 0.21]);

    currentImage = [];
    referenceImage = [];
    processedImage = [];

    mFile = uimenu(fig, 'Text', 'File');
    uimenu(mFile, 'Text', 'Load Image', 'MenuSelectedFcn', @loadImage);
    uimenu(mFile, 'Text', 'Load Reference Image', 'MenuSelectedFcn', @loadReferenceImage);
    uimenu(mFile, 'Text', 'Save Processed Image', 'MenuSelectedFcn', @saveImage);
    uimenu(mFile, 'Text', 'Exit', 'MenuSelectedFcn', @(~,~)close(fig), 'Separator', 'on');

    mTask1 = uimenu(fig, 'Text', 'Task 1 - Histogram');
    uimenu(mTask1, 'Text', 'Calculate Histogram', 'MenuSelectedFcn', @calculateHistogram);

    mTask2 = uimenu(fig, 'Text', 'Task 2 - Enhancement');
    uimenu(mTask2, 'Text', 'Image Brightening', 'MenuSelectedFcn', @applyBrightening);
    uimenu(mTask2, 'Text', 'Image Negative', 'MenuSelectedFcn', @applyNegative);
    uimenu(mTask2, 'Text', 'Log Transformation', 'MenuSelectedFcn', @applyLogTransform);
    uimenu(mTask2, 'Text', 'Power Transformation', 'MenuSelectedFcn', @applyPowerTransform);
    uimenu(mTask2, 'Text', 'Contrast Stretching', 'MenuSelectedFcn', @applyContrastStretching);

    mTask3 = uimenu(fig, 'Text', 'Task 3 - Equalization');
    uimenu(mTask3, 'Text', 'Histogram Equalization', 'MenuSelectedFcn', @applyEqualization);

    mTask4 = uimenu(fig, 'Text', 'Task 4 - Specification');
    uimenu(mTask4, 'Text', 'Histogram Matching', 'MenuSelectedFcn', @applyMatching);

    panelBg = [0.95 0.95 0.97];
    panelFg = [0.2 0.24 0.3];
    accentColor = [0.26 0.52 0.96];

    inputPanel = uipanel(fig, 'Title', 'Input Image', ...
                        'Position', [15 430 430 370], ...
                        'BackgroundColor', panelBg, ...
                        'ForegroundColor', panelFg, ...
                        'FontSize', 12, 'FontWeight', 'bold', ...
                        'BorderType', 'line', 'HighlightColor', accentColor);

    inputHistPanel = uipanel(fig, 'Title', 'Input Histogram', ...
                            'Position', [15 15 430 400], ...
                            'BackgroundColor', panelBg, ...
                            'ForegroundColor', panelFg, ...
                            'FontSize', 12, 'FontWeight', 'bold', ...
                            'BorderType', 'line', 'HighlightColor', accentColor);

    referencePanel = uipanel(fig, 'Title', 'Reference Image (Task 4)', ...
                            'Position', [460 430 530 370], ...
                            'BackgroundColor', panelBg, ...
                            'ForegroundColor', panelFg, ...
                            'FontSize', 11, 'FontWeight', 'bold', ...
                            'BorderType', 'line', 'HighlightColor', [0.8 0.6 0.2]);

    referenceHistPanel = uipanel(fig, 'Title', 'Reference Histogram', ...
                                'Position', [460 15 530 400], ...
                                'BackgroundColor', panelBg, ...
                                'ForegroundColor', panelFg, ...
                                'FontSize', 11, 'FontWeight', 'bold', ...
                                'BorderType', 'line', 'HighlightColor', [0.8 0.6 0.2]);

    outputPanel = uipanel(fig, 'Title', 'Output Image', ...
                         'Position', [1005 430 430 370], ...
                         'BackgroundColor', panelBg, ...
                         'ForegroundColor', panelFg, ...
                         'FontSize', 12, 'FontWeight', 'bold', ...
                         'BorderType', 'line', 'HighlightColor', accentColor);

    outputHistPanel = uipanel(fig, 'Title', 'Output Histogram', ...
                             'Position', [1005 15 430 400], ...
                             'BackgroundColor', panelBg, ...
                             'ForegroundColor', panelFg, ...
                             'FontSize', 12, 'FontWeight', 'bold', ...
                             'BorderType', 'line', 'HighlightColor', accentColor);

    inputAxes = uiaxes(inputPanel, 'Position', [10 10 410 340]);
    text(inputAxes, 0.5, 0.5, 'No image', 'HorizontalAlignment', 'center', ...
         'FontSize', 14, 'FontWeight', 'bold', 'Color', [0.5 0.5 0.5], ...
         'Units', 'normalized');
    inputAxes.XTick = [];
    inputAxes.YTick = [];
    inputAxes.XColor = 'none';
    inputAxes.YColor = 'none';

    referenceAxes = uiaxes(referencePanel, 'Position', [10 10 510 340]);
    text(referenceAxes, 0.5, 0.5, 'No image', 'HorizontalAlignment', 'center', ...
         'FontSize', 14, 'FontWeight', 'bold', 'Color', [0.5 0.5 0.5], ...
         'Units', 'normalized');
    referenceAxes.XTick = [];
    referenceAxes.YTick = [];
    referenceAxes.XColor = 'none';
    referenceAxes.YColor = 'none';

    outputAxes = uiaxes(outputPanel, 'Position', [10 10 410 340]);
    text(outputAxes, 0.5, 0.5, 'No image', 'HorizontalAlignment', 'center', ...
         'FontSize', 14, 'FontWeight', 'bold', 'Color', [0.5 0.5 0.5], ...
         'Units', 'normalized');
    outputAxes.XTick = [];
    outputAxes.YTick = [];
    outputAxes.XColor = 'none';
    outputAxes.YColor = 'none';

    inputHistAxes = uiaxes(inputHistPanel, 'Position', [10 10 410 370]);
    text(inputHistAxes, 0.5, 0.5, 'No histogram', 'HorizontalAlignment', 'center', ...
         'FontSize', 14, 'FontWeight', 'bold', 'Color', [0.5 0.5 0.5], ...
         'Units', 'normalized');
    inputHistAxes.XColor = [0 0 0];
    inputHistAxes.YColor = [0 0 0];
    inputHistAxes.XTick = [];
    inputHistAxes.YTick = [];

    referenceHistAxes = uiaxes(referenceHistPanel, 'Position', [10 10 510 370]);
    text(referenceHistAxes, 0.5, 0.5, 'No histogram', 'HorizontalAlignment', 'center', ...
         'FontSize', 14, 'FontWeight', 'bold', 'Color', [0.5 0.5 0.5], ...
         'Units', 'normalized');
    referenceHistAxes.XColor = [0 0 0];
    referenceHistAxes.YColor = [0 0 0];
    referenceHistAxes.XTick = [];
    referenceHistAxes.YTick = [];

    outputHistAxes = uiaxes(outputHistPanel, 'Position', [10 10 410 370]);
    text(outputHistAxes, 0.5, 0.5, 'No histogram', 'HorizontalAlignment', 'center', ...
         'FontSize', 14, 'FontWeight', 'bold', 'Color', [0.5 0.5 0.5], ...
         'Units', 'normalized');
    outputHistAxes.XColor = [0 0 0];
    outputHistAxes.YColor = [0 0 0];
    outputHistAxes.XTick = [];
    outputHistAxes.YTick = [];

    function loadImage(~, ~)
        [filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp;*.tif', 'Image Files'}, ...
                                        'Select an image');
        if filename ~= 0
            currentImage = imread(fullfile(pathname, filename));
            displayImage(inputAxes, currentImage);
            displayHistogram(inputHistAxes, currentImage);
            cla(outputAxes);
            cla(outputHistAxes);
            % Bring figure to front to avoid dialog focus issues on some platforms
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
            % Bring figure to front to avoid dialog focus issues on some platforms
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
            % Bring figure to front to avoid dialog focus issues on some platforms
            figure(fig);
        end
    end

    function calculateHistogram(~, ~)
        if isempty(currentImage)
            uialert(fig, 'Please load an image first!', 'Error');
            return;
        end

        displayHistogram(outputHistAxes, currentImage);
    end

    function applyBrightening(~, ~)
        if isempty(currentImage)
            uialert(fig, 'Please load an image first!', 'Error');
            return;
        end

        dlg = uifigure('Name', 'Brightening Parameters', ...
                      'Position', [500 500 340 200], ...
                      'Color', [0.95 0.95 0.97]);

        uilabel(dlg, 'Position', [20 145 300 25], ...
               'Text', 'Formula: s = a × r + b', ...
               'FontSize', 13, 'FontWeight', 'bold', ...
               'HorizontalAlignment', 'center', ...
               'FontColor', [0.2 0.2 0.2]);

        uilabel(dlg, 'Position', [30 100 120 22], 'Text', 'Multiplier (a):', ...
               'FontSize', 11, 'FontColor', [0.2 0.2 0.2]);
        aField = uieditfield(dlg, 'numeric', 'Position', [160 100 150 30], ...
                            'Value', 1.0, 'FontSize', 11);

        uilabel(dlg, 'Position', [30 60 120 22], 'Text', 'Offset (b):', ...
               'FontSize', 11, 'FontColor', [0.2 0.2 0.2]);
        bField = uieditfield(dlg, 'numeric', 'Position', [160 60 150 30], ...
                            'Value', 50, 'FontSize', 11);

        uibutton(dlg, 'Position', [120 15 100 35], 'Text', 'Apply', ...
                'FontSize', 11, 'FontWeight', 'bold', ...
                'BackgroundColor', [0.26 0.52 0.96], ...
                'FontColor', 'white', ...
                'ButtonPushedFcn', @(~,~)applyBrighteningCallback(aField.Value, bField.Value, dlg));
    end

    function applyBrighteningCallback(a, b, dlg)
        close(dlg);
        processedImage = image_brightening(currentImage, a, b);
        displayImage(outputAxes, processedImage);
        displayHistogram(outputHistAxes, processedImage);
    end

    function applyNegative(~, ~)
        if isempty(currentImage)
            uialert(fig, 'Please load an image first!', 'Error');
            return;
        end

        processedImage = image_negative(currentImage);
        displayImage(outputAxes, processedImage);
        displayHistogram(outputHistAxes, processedImage);
    end

    function applyLogTransform(~, ~)
        if isempty(currentImage)
            uialert(fig, 'Please load an image first!', 'Error');
            return;
        end

        dlg = uifigure('Name', 'Log Transform', ...
                      'Position', [500 500 340 160], ...
                      'Color', [0.95 0.95 0.97]);

        uilabel(dlg, 'Position', [20 110 300 25], ...
               'Text', 'Formula: s = c × log(1 + r)', ...
               'FontSize', 13, 'FontWeight', 'bold', ...
               'HorizontalAlignment', 'center', ...
               'FontColor', [0.2 0.2 0.2]);

        uilabel(dlg, 'Position', [30 65 120 22], 'Text', 'Constant (c):', ...
               'FontSize', 11, 'FontColor', [0.2 0.2 0.2]);
        cField = uieditfield(dlg, 'numeric', 'Position', [160 65 150 30], ...
                            'Value', 1.0, 'FontSize', 11);

        uibutton(dlg, 'Position', [120 15 100 35], 'Text', 'Apply', ...
                'FontSize', 11, 'FontWeight', 'bold', ...
                'BackgroundColor', [0.26 0.52 0.96], ...
                'FontColor', 'white', ...
                'ButtonPushedFcn', @(~,~)applyLogCallback(cField.Value, dlg));
    end

    function applyLogCallback(c, dlg)
        close(dlg);
        processedImage = log_transformation(currentImage, c);
        displayImage(outputAxes, processedImage);
        displayHistogram(outputHistAxes, processedImage);
    end

    function applyPowerTransform(~, ~)
        if isempty(currentImage)
            uialert(fig, 'Please load an image first!', 'Error');
            return;
        end

        dlg = uifigure('Name', 'Power Transform (Gamma)', ...
                      'Position', [500 500 340 200], ...
                      'Color', [0.95 0.95 0.97]);

        uilabel(dlg, 'Position', [20 145 300 25], ...
               'Text', 'Formula: s = c × r^γ', ...
               'FontSize', 13, 'FontWeight', 'bold', ...
               'HorizontalAlignment', 'center', ...
               'FontColor', [0.2 0.2 0.2]);

        uilabel(dlg, 'Position', [30 100 120 22], 'Text', 'Constant (c):', ...
               'FontSize', 11, 'FontColor', [0.2 0.2 0.2]);
        cField = uieditfield(dlg, 'numeric', 'Position', [160 100 150 30], ...
                            'Value', 1.0, 'FontSize', 11);

        uilabel(dlg, 'Position', [30 60 120 22], 'Text', 'Gamma (γ):', ...
               'FontSize', 11, 'FontColor', [0.2 0.2 0.2]);
        gammaField = uieditfield(dlg, 'numeric', 'Position', [160 60 150 30], ...
                                'Value', 2.0, 'FontSize', 11);

        uibutton(dlg, 'Position', [120 15 100 35], 'Text', 'Apply', ...
                'FontSize', 11, 'FontWeight', 'bold', ...
                'BackgroundColor', [0.26 0.52 0.96], ...
                'FontColor', 'white', ...
                'ButtonPushedFcn', @(~,~)applyPowerCallback(cField.Value, gammaField.Value, dlg));
    end

    function applyPowerCallback(c, gamma, dlg)
        close(dlg);
        processedImage = power_transformation(currentImage, c, gamma);
        displayImage(outputAxes, processedImage);
        displayHistogram(outputHistAxes, processedImage);
    end

    function applyContrastStretching(~, ~)
        if isempty(currentImage)
            uialert(fig, 'Please load an image first!', 'Error');
            return;
        end

        processedImage = contrast_stretching(currentImage);
        displayImage(outputAxes, processedImage);
        displayHistogram(outputHistAxes, processedImage);
    end

    function applyEqualization(~, ~)
        if isempty(currentImage)
            uialert(fig, 'Please load an image first!', 'Error');
            return;
        end

        processedImage = histogram_equalization(currentImage);
        displayImage(outputAxes, processedImage);
        displayHistogram(outputHistAxes, processedImage);
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

        % Check if dimensions match
        if ~isequal(size(currentImage), size(referenceImage))
            % Check if cropping is possible
            [inputH, inputW, ~] = size(currentImage);
            [refH, refW, ~] = size(referenceImage);

            if refH >= inputH && refW >= inputW
                % Reference image is larger or equal, can crop
                selection = uiconfirm(fig, ...
                    sprintf('Reference image (%dx%d) is larger than input image (%dx%d).\nWould you like to crop the reference image to match?', ...
                    refW, refH, inputW, inputH), ...
                    'Image Size Mismatch', ...
                    'Options', {'Crop Reference', 'Cancel'}, ...
                    'DefaultOption', 1, 'CancelOption', 2);

                if strcmp(selection, 'Crop Reference')
                    % Crop reference image from center
                    startRow = round((refH - inputH) / 2) + 1;
                    startCol = round((refW - inputW) / 2) + 1;
                    referenceImage = referenceImage(startRow:startRow+inputH-1, ...
                                                   startCol:startCol+inputW-1, :);

                    % Update reference display
                    displayImage(referenceAxes, referenceImage);
                    displayHistogram(referenceHistAxes, referenceImage);
                else
                    return;
                end
            else
                uialert(fig, ...
                    sprintf('Input and reference images must have the same dimensions!\nInput: %dx%d, Reference: %dx%d\n\nReference image is too small to crop.', ...
                    inputW, inputH, refW, refH), ...
                    'Error');
                return;
            end
        end

        processedImage = histogram_matching(currentImage, referenceImage);
        displayImage(outputAxes, processedImage);
        displayHistogram(outputHistAxes, processedImage);
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
            % Color image - display RGB histograms with improved styling
            colors = {[0.9 0.2 0.2], [0.2 0.8 0.2], [0.2 0.2 0.9]};
            hold(ax, 'on');
            for ch = 1:3
                hist_vals = calculate_histogram(img(:,:,ch));
                plot(ax, 0:255, hist_vals, 'Color', colors{ch}, ...
                     'LineWidth', 2.5, 'LineStyle', '-');
            end
            hold(ax, 'off');
            lgd = legend(ax, {'Red Channel', 'Green Channel', 'Blue Channel'}, ...
                  'Location', 'northeast', 'FontSize', 9);
            lgd.TextColor = [1 1 1];  % White text for better contrast
            lgd.Color = [0.2 0.2 0.2];  % Dark background
            lgd.EdgeColor = [0.4 0.4 0.4];
        else
            % Grayscale image with gradient effect
            hist_vals = calculate_histogram(img);
            b = bar(ax, 0:255, hist_vals, 'FaceColor', [0.26 0.52 0.96], ...
                   'EdgeColor', 'none', 'FaceAlpha', 0.8);
        end

        ax.XLabel.String = 'Intensity Level';
        ax.YLabel.String = 'Pixel Count';
        ax.FontSize = 9;
        ax.XLim = [0 255];
        ax.Box = 'on';
        ax.GridColor = [0.85 0.85 0.85];
        ax.GridAlpha = 0.3;
        ax.XColor = [0 0 0];
        ax.YColor = [0 0 0];
        ax.XLabel.Color = [0 0 0];
        ax.YLabel.Color = [0 0 0];
        grid(ax, 'on');
    end
end
