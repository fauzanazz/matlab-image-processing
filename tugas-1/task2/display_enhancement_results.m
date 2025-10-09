function display_enhancement_results(input_img, output_img, method_name, parameters)
    % Display comparison of input and output images with histograms
    % Input: input_img - original image
    %        output_img - enhanced image  
    %        method_name - name of enhancement method
    %        parameters - struct with method parameters (optional)
    
    addpath('../task1');
    
    if nargin < 4
        parameters = struct();
    end
    
    fig = figure('Name', ['Enhancement Results: ' method_name], 'Position', [100 100 1200 800]);
    is_color = (size(input_img, 3) == 3);
    
    if is_color
        display_color_results(input_img, output_img, method_name, parameters);
    else
        display_grayscale_results(input_img, output_img, method_name, parameters);
    end
    
    if ~isempty(fieldnames(parameters))
        add_parameter_text(parameters, method_name);
    end
end

function display_grayscale_results(input_img, output_img, method_name, parameters)
    % input image
    subplot(2,2,1);
    imshow(input_img);
    title('Input Image', 'FontSize', 12, 'FontWeight', 'bold');
    
    % input histogram
    subplot(2,2,2);
    hist_input = calculate_histogram(input_img);
    bar(0:255, hist_input, 'FaceColor', [0.3 0.3 0.8], 'EdgeColor', 'none');
    title('Input Histogram', 'FontSize', 12, 'FontWeight', 'bold');
    xlabel('Intensity Value');
    ylabel('Frequency');
    xlim([0 255]);
    grid on;
    
    % output image
    subplot(2,2,3);
    imshow(output_img);
    title(['Output Image (' method_name ')'], 'FontSize', 12, 'FontWeight', 'bold');
    
    % output histogram
    subplot(2,2,4);
    hist_output = calculate_histogram(output_img);
    bar(0:255, hist_output, 'FaceColor', [0.8 0.3 0.3], 'EdgeColor', 'none');
    title('Output Histogram', 'FontSize', 12, 'FontWeight', 'bold');
    xlabel('Intensity Value');
    ylabel('Frequency');
    xlim([0 255]);
    grid on;
end

function display_color_results(input_img, output_img, method_name, parameters)
    % input image
    subplot(2,4,1);
    imshow(input_img);
    title('Input Image', 'FontSize', 10, 'FontWeight', 'bold');
    
    % input histograms (RGB)
    colors = {'r', 'g', 'b'};
    channel_names = {'Red', 'Green', 'Blue'};
    
    for ch = 1:3
        subplot(2,4,ch+1);
        hist_ch = calculate_histogram(input_img(:,:,ch));
        bar(0:255, hist_ch, colors{ch}, 'EdgeColor', 'none');
        title(['Input ' channel_names{ch}], 'FontSize', 9);
        xlim([0 255]);
        if ch == 1, ylabel('Frequency'); end
        grid on;
    end
    
    % output image
    subplot(2,4,5);
    imshow(output_img);
    title(['Output (' method_name ')'], 'FontSize', 10, 'FontWeight', 'bold');
    
    % output histograms (RGB)
    for ch = 1:3
        subplot(2,4,ch+5);
        hist_ch = calculate_histogram(output_img(:,:,ch));
        bar(0:255, hist_ch, colors{ch}, 'EdgeColor', 'none');
        title(['Output ' channel_names{ch}], 'FontSize', 9);
        xlim([0 255]);
        if ch == 1, ylabel('Frequency'); end
        xlabel('Intensity');
        grid on;
    end
end

function add_parameter_text(parameters, method_name)
    param_str = sprintf('Method: %s\nParameters:\n', method_name);
    
    fields = fieldnames(parameters);
    for i = 1:length(fields)
        param_str = [param_str sprintf('  %s = %.2f\n', fields{i}, parameters.(fields{i}))];
    end
    
    annotation('textbox', [0.02 0.02 0.25 0.15], 'String', param_str, ...
               'FontSize', 10, 'BackgroundColor', 'white', ...
               'EdgeColor', 'black', 'FitBoxToText', 'on');
end