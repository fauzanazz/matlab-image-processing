function [customResult, matlabResult, difference, metrics] = compareResults(image, mask, paddingMethod)
    if nargin < 3
        paddingMethod = 'zero';
    end
    
    tic;
    customResult = applyConvolution(image, mask, paddingMethod);
    customTime = toc;
    
    tic;
    if size(image, 3) == 1
        matlabResult = imfilter(double(image), mask, paddingMethod, 'conv');
        matlabResult = uint8(matlabResult);
    else
        matlabResult = imfilter(image, mask, paddingMethod, 'conv');
    end

    matlabTime = toc;
    difference = abs(double(customResult) - double(matlabResult));

    metrics = struct();
    metrics.customTime = customTime;
    metrics.matlabTime = matlabTime;
    metrics.speedRatio = matlabTime / customTime;
    metrics.MSE = mean(difference(:).^2);
    metrics.MAE = mean(difference(:));
    metrics.maxError = max(difference(:));
    
    if metrics.MSE > 0
        metrics.PSNR = 10 * log10(255^2 / metrics.MSE);
    else
        metrics.PSNR = Inf;
    end
    
    customVec = double(customResult(:));
    matlabVec = double(matlabResult(:));
    metrics.correlation = corr(customVec, matlabVec);
    
    fprintf('\n=== PERBANDINGAN HASIL KONVOLUSI ===\n');
    fprintf('Waktu Custom      : %.4f detik\n', metrics.customTime);
    fprintf('Waktu MATLAB      : %.4f detik\n', metrics.matlabTime);
    fprintf('Rasio Kecepatan   : %.2fx %s\n', abs(metrics.speedRatio), ...
            ternary(metrics.speedRatio < 1, '(custom lebih cepat)', '(MATLAB lebih cepat)'));
    fprintf('MSE               : %.6f\n', metrics.MSE);
    fprintf('MAE               : %.6f\n', metrics.MAE);
    fprintf('Max Error         : %.6f\n', metrics.maxError);
    fprintf('PSNR              : %.2f dB\n', metrics.PSNR);
    fprintf('Correlation       : %.6f\n', metrics.correlation);
    fprintf('====================================\n\n');
end

function result = ternary(condition, trueVal, falseVal)
    if condition
        result = trueVal;
    else
        result = falseVal;
    end
end