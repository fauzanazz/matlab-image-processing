function results = compareFilters(image, cutoffFreqs, displayResults)
    if nargin < 2
        cutoffFreqs = [20, 40, 60];
    end
    if nargin < 3
        displayResults = true;
    end
    
    fprintf('\n=== PERBANDINGAN HIGH-PASS FILTERS ===\n');
    
    if size(image, 3) == 3
        imgGray = rgb2gray(image);
    else
        imgGray = image;
    end
    
    methods = {'IHPF', 'GHPF', 'BHPF'};
    numMethods = length(methods);
    numFreqs = length(cutoffFreqs);
    
    results = struct();
    idx = 1;
    
    for i = 1:numMethods
        for j = 1:numFreqs
            method = methods{i};
            D0 = cutoffFreqs(j);
            
            fprintf('Processing: %s, D0=%d...\n', method, D0);
            
            tic;
            [filtered, filterUsed, spectrum] = frequencyHighPass(imgGray, method, D0);
            processingTime = toc;
            
            results(idx).method = method;
            results(idx).cutoffFreq = D0;
            results(idx).filtered = filtered;
            results(idx).filter = filterUsed;
            results(idx).spectrum = spectrum;
            results(idx).time = processingTime;
            
            edges = edge(filtered, 'canny');
            results(idx).edgePixels = sum(edges(:));
            results(idx).edgeRatio = sum(edges(:)) / numel(edges);
            
            highFreqEnergy = sum(abs(spectrum.filtered(:)).^2);
            results(idx).highFreqEnergy = highFreqEnergy;
            
            results(idx).contrast = std(double(filtered(:)));
            results(idx).mean = mean(double(filtered(:)));
            
            fprintf('  Time: %.4f s, Edge Ratio: %.4f, Contrast: %.2f\n', ...
                processingTime, results(idx).edgeRatio, results(idx).contrast);
            
            idx = idx + 1;
        end
    end
    
    if displayResults
        figure('Name', 'High-Pass Filters Comparison', 'Position', [50 50 1400 900]);
        
        subplot(numFreqs + 1, numMethods + 1, 1);
        imshow(imgGray); title('Original');
        
        for i = 1:length(results)
            row = floor((i-1) / numMethods) + 2;
            col = mod(i-1, numMethods) + 2;
            
            subplot(numFreqs + 1, numMethods + 1, (row-1)*(numMethods+1) + col);
            imshow(results(i).filtered);
            title(sprintf('%s D0=%d\nEdges: %.2f%%', ...
                results(i).method, results(i).cutoffFreq, ...
                results(i).edgeRatio * 100));
        end
        
        for i = 1:numMethods
            subplot(numFreqs + 1, numMethods + 1, i + 1);
            idx = (i-1) * numFreqs + 1;
            imshow(results(idx).filter, []); 
            title(sprintf('%s Filter', results(idx).method));
            colorbar;
        end
        
        figure('Name', 'Performance Metrics', 'Position', [50 50 1200 600]);
        
        subplot(2, 3, 1);
        edgeRatios = reshape([results.edgeRatio], numFreqs, numMethods)';
        bar(edgeRatios);
        legend(arrayfun(@(x) sprintf('D0=%d', x), cutoffFreqs, 'UniformOutput', false));
        set(gca, 'XTickLabel', methods);
        ylabel('Edge Ratio');
        title('Edge Detection Performance');
        grid on;
        
        subplot(2, 3, 2);
        contrasts = reshape([results.contrast], numFreqs, numMethods)';
        bar(contrasts);
        legend(arrayfun(@(x) sprintf('D0=%d', x), cutoffFreqs, 'UniformOutput', false));
        set(gca, 'XTickLabel', methods);
        ylabel('Contrast (Std Dev)');
        title('Output Contrast');
        grid on;
        
        subplot(2, 3, 3);
        times = reshape([results.time], numFreqs, numMethods)';
        bar(times);
        legend(arrayfun(@(x) sprintf('D0=%d', x), cutoffFreqs, 'UniformOutput', false));
        set(gca, 'XTickLabel', methods);
        ylabel('Time (s)');
        title('Processing Time');
        grid on;
        
        subplot(2, 3, 4);
        energies = reshape([results.highFreqEnergy], numFreqs, numMethods)';
        bar(log10(energies));
        legend(arrayfun(@(x) sprintf('D0=%d', x), cutoffFreqs, 'UniformOutput', false));
        set(gca, 'XTickLabel', methods);
        ylabel('Log10(Energy)');
        title('High Frequency Energy');
        grid on;
        
        subplot(2, 3, 5);
        hold on;
        colors = {'b', 'r', 'g'};
        for i = 1:numMethods
            idx = (i-1) * numFreqs + 2; 
            filter = results(idx).filter;
            centerRow = round(size(filter, 1) / 2);
            profile = filter(centerRow, :);
            plot(profile, colors{i}, 'LineWidth', 2);
        end
        legend(methods);
        xlabel('Frequency');
        ylabel('H(u,v)');
        title(sprintf('Filter Profiles (D0=%d)', cutoffFreqs(2)));
        grid on;

        subplot(2, 3, 6);
        axis off;
        text(0.1, 0.9, 'SUMMARY', 'FontWeight', 'bold', 'FontSize', 12);
        yPos = 0.8;
        for i = 1:length(results)
            text(0.1, yPos, sprintf('%s D0=%d: %.2f%% edges', ...
                results(i).method, results(i).cutoffFreq, ...
                results(i).edgeRatio * 100), 'FontSize', 8);
            yPos = yPos - 0.08;
            if yPos < 0.1, break; end
        end
    end
    
    fprintf('=== SELESAI ===\n\n');
end