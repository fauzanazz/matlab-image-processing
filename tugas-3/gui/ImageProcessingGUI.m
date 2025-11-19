function ImageProcessingGUI()
    % Add path to task1 functions
    if exist('../task1', 'dir')
        addpath('../task1');
    elseif exist('tugas-3/task1', 'dir')
        addpath('tugas-3/task1');
    end

    fig = uifigure('Name', 'Image Processing GUI - Tugas 3 (Edge Detection & Segmentation)', ...
                   'Position', [100 100 1450 820], ...
                   'Color', [0.15 0.17 0.21]);
    
    % State variables
    currentImage = [];
    edgeImage = [];
    segmentedImage = [];
    
    % Menus
    mFile = uimenu(fig, 'Text', 'File');
    uimenu(mFile, 'Text', 'Load Image', 'MenuSelectedFcn', @loadImage);
    uimenu(mFile, 'Text', 'Exit', 'MenuSelectedFcn', @(~,~)close(fig), 'Separator', 'on');
    
    mEdge = uimenu(fig, 'Text', 'Edge Detection');
    uimenu(mEdge, 'Text', 'Sobel', 'MenuSelectedFcn', @promptSobel);
    uimenu(mEdge, 'Text', 'Prewitt', 'MenuSelectedFcn', @promptPrewitt);
    uimenu(mEdge, 'Text', 'Roberts', 'MenuSelectedFcn', @promptRoberts);
    uimenu(mEdge, 'Text', 'Canny', 'MenuSelectedFcn', @promptCanny);
    uimenu(mEdge, 'Text', 'Laplace', 'MenuSelectedFcn', @promptLaplace);
    uimenu(mEdge, 'Text', 'LoG (Laplacian of Gaussian)', 'MenuSelectedFcn', @promptLoG);
    
    mSeg = uimenu(fig, 'Text', 'Segmentation');
    uimenu(mSeg, 'Text', 'Segment from Edges', 'MenuSelectedFcn', @applySegmentation);
    uimenu(mSeg, 'Text', 'Count Objects', 'MenuSelectedFcn', @performCounting);
    
    % Layout Colors
    panelBg = [0.95 0.95 0.97];
    panelFg = [0.2 0.24 0.3];
    accentColor = [0.26 0.52 0.96];
    
    % Panels
    % Input Panel (Left)
    inputPanel = uipanel(fig, 'Title', 'Input Image', ...
                        'Position', [20 230 450 550], ...
                        'BackgroundColor', panelBg, ...
                        'ForegroundColor', panelFg, ...
                        'FontSize', 12, 'FontWeight', 'bold', ...
                        'BorderType', 'line', 'HighlightColor', accentColor);
    inputAxes = uiaxes(inputPanel, 'Position', [10 10 430 510]);
    setupAxes(inputAxes, 'No Image');
    
    % Edge Panel (Center)
    edgePanel = uipanel(fig, 'Title', 'Edge Detection Result', ...
                        'Position', [490 230 450 550], ...
                        'BackgroundColor', panelBg, ...
                        'ForegroundColor', panelFg, ...
                        'FontSize', 12, 'FontWeight', 'bold', ...
                        'BorderType', 'line', 'HighlightColor', accentColor);
    edgeAxes = uiaxes(edgePanel, 'Position', [10 10 430 510]);
    setupAxes(edgeAxes, 'No Edge Result');
    
    % Segmentation Panel (Right)
    segPanel = uipanel(fig, 'Title', 'Segmentation Result', ...
                        'Position', [960 230 450 550], ...
                        'BackgroundColor', panelBg, ...
                        'ForegroundColor', panelFg, ...
                        'FontSize', 12, 'FontWeight', 'bold', ...
                        'BorderType', 'line', 'HighlightColor', accentColor);
    segAxes = uiaxes(segPanel, 'Position', [10 10 430 510]);
    setupAxes(segAxes, 'No Segmentation Result');

    % Info Panel (Bottom)
    infoPanel = uipanel(fig, 'Title', 'Information', ...
                        'Position', [20 20 1390 190], ...
                        'BackgroundColor', panelBg, ...
                        'ForegroundColor', panelFg, ...
                        'FontSize', 12, 'FontWeight', 'bold', ...
                        'BorderType', 'line', 'HighlightColor', accentColor);
    infoLabel = uilabel(infoPanel, 'Position', [20 20 1350 140], ...
                        'Text', 'Load an image to start processing.', ...
                        'VerticalAlignment', 'top', ...
                        'FontSize', 14, 'FontColor', panelFg);

    % --- Helper Functions ---
    
    function setupAxes(ax, placeholderText)
        ax.XTick = [];
        ax.YTick = [];
        ax.XColor = 'none';
        ax.YColor = 'none';
        cla(ax);
        text(ax, 0.5, 0.5, placeholderText, 'HorizontalAlignment', 'center', ...
             'FontSize', 14, 'FontWeight', 'bold', 'Color', [0.5 0.5 0.5], ...
             'Units', 'normalized');
    end
    
    function displayImage(ax, img)
        imshow(img, 'Parent', ax);
        ax.XTick = [];
        ax.YTick = [];
    end
    
    function imgGray = getGrayImage()
        if size(currentImage, 3) == 3
            imgGray = double(rgb2gray(currentImage));
        else
            imgGray = double(currentImage);
        end
    end

    function updateInfo(msg)
        infoLabel.Text = msg;
    end

    % --- Callbacks ---

    function loadImage(~, ~)
        [filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp;*.tif', 'Image Files'}, 'Select an image');
        if filename ~= 0
            currentImage = imread(fullfile(pathname, filename));
            
            displayImage(inputAxes, currentImage);
            
            % Reset outputs
            setupAxes(edgeAxes, 'No Edge Result');
            setupAxes(segAxes, 'No Segmentation Result');
            edgeImage = [];
            segmentedImage = [];
            
            updateInfo(sprintf('Image loaded: %s\nDimensions: %d x %d', filename, size(currentImage, 1), size(currentImage, 2)));
            
            % Bring figure to front to avoid dialog focus issues on some platforms
            figure(fig);
        end
    end
    
    % Generic Prompt for Threshold
    function promptForThreshold(title, defaultVal, callback)
        if isempty(currentImage), uialert(fig, 'Please load an image first!', 'Error'); return; end
        
        d = uifigure('Name', title, 'Position', [500 500 300 150], 'Color', [0.95 0.95 0.97]);
        uilabel(d, 'Position', [30 80 100 22], 'Text', 'Threshold Factor:', 'FontColor', [0.2 0.24 0.3]);
        ef = uieditfield(d, 'numeric', 'Position', [140 80 100 30], 'Value', defaultVal);
        
        uibutton(d, 'Position', [100 20 100 30], 'Text', 'Apply', ...
            'BackgroundColor', [0.26 0.52 0.96], 'FontColor', 'white', ...
            'ButtonPushedFcn', @(~,~) runCallback(d, ef.Value, callback));
    end

    function runCallback(d, val, callback)
        close(d);
        
        % Show loading indicator
        set(fig, 'Pointer', 'watch');
        drawnow;
        
        try
            callback(val);
        catch ME
            uialert(fig, ME.message, 'Execution Error');
        end
        
        % Reset pointer
        set(fig, 'Pointer', 'arrow');
    end

    % Sobel
    function promptSobel(~,~)
        promptForThreshold('Sobel Parameters', 0.15, @runSobel);
    end
    function runSobel(thresh)
        try
            edgeImage = sobel_edge_detection(getGrayImage(), thresh);
            displayImage(edgeAxes, edgeImage);
            
            % Clear previous segmentation
            segmentedImage = [];
            setupAxes(segAxes, 'No Segmentation Result');
            
            updateInfo(sprintf('Sobel Edge Detection applied.\nThreshold: %.2f', thresh));
        catch ME
            rethrow(ME); % Re-throw to be caught by runCallback
        end
    end

    % Prewitt
    function promptPrewitt(~,~)
        promptForThreshold('Prewitt Parameters', 0.15, @runPrewitt);
    end
    function runPrewitt(thresh)
        try
            edgeImage = prewitt_edge_detection(getGrayImage(), thresh);
            displayImage(edgeAxes, edgeImage);
            
            % Clear previous segmentation
            segmentedImage = [];
            setupAxes(segAxes, 'No Segmentation Result');
            
            updateInfo(sprintf('Prewitt Edge Detection applied.\nThreshold: %.2f', thresh));
        catch ME
            rethrow(ME);
        end
    end

    % Roberts
    function promptRoberts(~,~)
        promptForThreshold('Roberts Parameters', 0.12, @runRoberts);
    end
    function runRoberts(thresh)
        try
            edgeImage = roberts_edge_detection(getGrayImage(), thresh);
            displayImage(edgeAxes, edgeImage);
            
            % Clear previous segmentation
            segmentedImage = [];
            setupAxes(segAxes, 'No Segmentation Result');
            
            updateInfo(sprintf('Roberts Edge Detection applied.\nThreshold: %.2f', thresh));
        catch ME
            rethrow(ME);
        end
    end

    % Canny
    function promptCanny(~,~)
        % Canny typically uses two thresholds (low, high) or a default.
        % For simplicity in this GUI, we'll let MATLAB choose the default or ask for a sensitivity.
        % Here we'll use a single parameter for "Sensitivity" which maps to the threshold.
        % Default behavior is often best for Canny.
        
        if isempty(currentImage), uialert(fig, 'Please load an image first!', 'Error'); return; end
        
        d = uifigure('Name', 'Canny Parameters', 'Position', [500 500 300 150], 'Color', [0.95 0.95 0.97]);
        uilabel(d, 'Position', [30 80 100 22], 'Text', 'Use Default?', 'FontColor', [0.2 0.24 0.3]);
        
        % Checkbox for default
        cb = uicheckbox(d, 'Position', [140 80 100 22], 'Text', 'Yes', 'Value', true, 'FontColor', [0.2 0.24 0.3]);
        
        uibutton(d, 'Position', [100 20 100 30], 'Text', 'Apply', ...
            'BackgroundColor', [0.26 0.52 0.96], 'FontColor', 'white', ...
            'ButtonPushedFcn', @(~,~) runCannyCallback(d, cb.Value));
    end
    
    function runCannyCallback(d, useDefault)
        close(d);
        
        % Show loading indicator
        set(fig, 'Pointer', 'watch');
        drawnow;
        
        try
            img = getGrayImage();
            % Normalize to [0,1] as Canny prefers this or uint8. 
            % edge() function handles it, but consistent with other scripts:
            imgNorm = mat2gray(img); 
            
            if useDefault
                edgeImage = edge(imgNorm, 'Canny');
                updateInfo('Canny Edge Detection applied (Default Parameters).');
            else
                % Could add more complex params here if needed
                edgeImage = edge(imgNorm, 'Canny'); 
                updateInfo('Canny Edge Detection applied.');
            end
            
            displayImage(edgeAxes, edgeImage);
            
            % Clear previous segmentation
            segmentedImage = [];
            setupAxes(segAxes, 'No Segmentation Result');
            
        catch ME
            uialert(fig, ME.message, 'Execution Error');
        end
        
        % Reset pointer
        set(fig, 'Pointer', 'arrow');
    end
    
    % Laplace
    function promptLaplace(~,~)
        promptForThreshold('Laplace Parameters', 0.1, @runLaplace);
    end
    function runLaplace(thresh)
        try
            edgeImage = laplace_edge_detection(getGrayImage(), thresh);
            displayImage(edgeAxes, edgeImage);
            
            % Clear previous segmentation
            segmentedImage = [];
            setupAxes(segAxes, 'No Segmentation Result');
            
            updateInfo(sprintf('Laplace Edge Detection applied.\nThreshold: %.2f', thresh));
        catch ME
            rethrow(ME);
        end
    end

    % LoG
    function promptLoG(~,~)
        if isempty(currentImage), uialert(fig, 'Please load an image first!', 'Error'); return; end
        
        d = uifigure('Name', 'LoG Parameters', 'Position', [500 500 300 200], 'Color', [0.95 0.95 0.97]);
        
        uilabel(d, 'Position', [30 120 100 22], 'Text', 'Sigma:', 'FontColor', [0.2 0.24 0.3]);
        efSigma = uieditfield(d, 'numeric', 'Position', [140 120 100 30], 'Value', 2.0);
        
        uilabel(d, 'Position', [30 70 100 22], 'Text', 'Threshold:', 'FontColor', [0.2 0.24 0.3]);
        efThresh = uieditfield(d, 'numeric', 'Position', [140 70 100 30], 'Value', 0.08);
        
        uibutton(d, 'Position', [100 20 100 30], 'Text', 'Apply', ...
            'BackgroundColor', [0.26 0.52 0.96], 'FontColor', 'white', ...
            'ButtonPushedFcn', @(~,~) runLoGCallback(d, efSigma.Value, efThresh.Value));
    end

    function runLoGCallback(d, sigma, thresh)
        close(d);
        
        % Show loading indicator
        set(fig, 'Pointer', 'watch');
        drawnow;
        
        try
            edgeImage = log_edge_detection(getGrayImage(), sigma, thresh);
            displayImage(edgeAxes, edgeImage);
            
            % Clear previous segmentation
            segmentedImage = [];
            setupAxes(segAxes, 'No Segmentation Result');
            
            updateInfo(sprintf('LoG Edge Detection applied.\nSigma: %.2f, Threshold: %.2f', sigma, thresh));
        catch ME
            uialert(fig, ME.message, 'Execution Error');
        end
        
        % Reset pointer
        set(fig, 'Pointer', 'arrow');
    end

    % Segmentation
    function applySegmentation(~,~)
        if isempty(edgeImage)
            uialert(fig, 'Please perform edge detection first!', 'Error'); 
            return; 
        end
        
        % Show loading indicator
        set(fig, 'Pointer', 'watch');
        drawnow;
        
        try
            segmentedImage = segment_from_edges(edgeImage, currentImage);
            displayImage(segAxes, segmentedImage);
            updateInfo('Segmentation applied based on current edge detection.');
        catch ME
            uialert(fig, ME.message, 'Execution Error');
        end
        
        % Reset pointer
        set(fig, 'Pointer', 'arrow');
    end
    
    % Counting
    function performCounting(~,~)
        if isempty(segmentedImage)
            uialert(fig, 'Please perform segmentation first!', 'Error'); 
            return; 
        end
        
        % Show loading indicator
        set(fig, 'Pointer', 'watch');
        drawnow;
        
        try
            [num, labeled] = count_objects(segmentedImage);
            
            % Display labeled image to visualize different objects
            labeledRGB = label2rgb(labeled, 'jet', 'k', 'shuffle');
            displayImage(segAxes, labeledRGB);
            
            updateInfo(sprintf('Object Counting Complete.\nNumber of objects detected: %d', num));
        catch ME
            uialert(fig, ME.message, 'Execution Error');
        end
        
        % Reset pointer
        set(fig, 'Pointer', 'arrow');
    end

end

