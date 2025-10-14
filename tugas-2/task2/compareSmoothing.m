function results = compareSmoothing(image, noisyImage, filterSize, cutoffFreq)
    if nargin < 3, filterSize = 5; end
    if nargin < 4, cutoffFreq = 30; end
    
    fprintf('\n=== PERBANDINGAN METODE SMOOTHING ===\n');
    methods = {
        'Spatial - Mean Filter'
        'Spatial - Gaussian Filter'
        'Spatial - Median Filter'
        'Frequency - ILPF'
        'Frequency - GLPF'
        'Frequency - BLPF'
    };
    
    numMethods = length(methods);
    results = struct();
    
    for i = 1:numMethods
        fprintf('\nProcessing: %s...\n', methods{i});
        tic;
        
        switch i
            case 1 % Mean Filter
                smoothed = spatialSmoothing(noisyImage, 'mean', filterSize);
                
            case 2 % Gaussian Filter
                smoothed = spatialSmoothing(noisyImage, 'gaussian', filterSize);
                
            case 3 % Median Filter
                smoothed = spatialSmoothing(noisyImage, 'median', filterSize);
                
            case 4 % ILPF
                smoothed = frequencySmoothing(noisyImage, 'ILPF', cutoffFreq);
                
            case 5 % GLPF
                smoothed = frequencySmoothing(noisyImage, 'GLPF', cutoffFreq);
                
            case 6 % BLPF
                smoothed = frequencySmoothing(noisyImage, 'BLPF', cutoffFreq, 2);
        end
        
        processingTime = toc;
        metrics = evaluateQuality(image, smoothed, noisyImage);
        
        results(i).method = methods{i};
        results(i).smoothed = smoothed;
        results(i).time = processingTime;
        results(i).metrics = metrics;
        
        fprintf('  Time: %.4f s\n', processingTime);
        fprintf('  PSNR: %.2f dB\n', metrics.PSNR);
        fprintf('  SSIM: %.4f\n', metrics.SSIM);
        fprintf('  Noise Reduction: %.2f%%\n', metrics.NoiseReduction);
    end
    
    fprintf('\n=== SELESAI ===\n');
end