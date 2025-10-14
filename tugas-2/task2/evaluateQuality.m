function metrics = evaluateQuality(original, processed, noisy)
    original = im2double(original);
    processed = im2double(processed);
    if nargin > 2
        noisy = im2double(noisy);
    end
    
    metrics = struct();
    
    % 1. MSE (Mean Squared Error)
    mse = mean((original(:) - processed(:)).^2);
    metrics.MSE = mse;
    
    % 2. RMSE (Root Mean Squared Error)
    metrics.RMSE = sqrt(mse);
    
    % 3. PSNR (Peak Signal-to-Noise Ratio)
    if mse > 0
        metrics.PSNR = 10 * log10(1 / mse);
    else
        metrics.PSNR = Inf;
    end
    
    % 4. SSIM (Structural Similarity Index)
    if size(original, 3) == 1
        metrics.SSIM = ssim(processed, original);
    else
        ssimVals = zeros(1, 3);
        for c = 1:3
            ssimVals(c) = ssim(processed(:,:,c), original(:,:,c));
        end
        metrics.SSIM = mean(ssimVals);
    end
    
    % 5. SNR (Signal-to-Noise Ratio)
    signalPower = sum(original(:).^2) / numel(original);
    noisePower = sum((original(:) - processed(:)).^2) / numel(original);
    if noisePower > 0
        metrics.SNR = 10 * log10(signalPower / noisePower);
    else
        metrics.SNR = Inf;
    end
    
    % 6. MAE (Mean Absolute Error)
    metrics.MAE = mean(abs(original(:) - processed(:)));
    
    % 7. Correlation Coefficient
    metrics.Correlation = corr(original(:), processed(:));
    
    % 8. Improvement jika ada noisy image
    if nargin > 2
        mseBefore = mean((original(:) - noisy(:)).^2);
        psnrBefore = 10 * log10(1 / mseBefore);
        metrics.PSNR_Improvement = metrics.PSNR - psnrBefore;
        
        noiseBefore = mean((original(:) - noisy(:)).^2);
        noiseAfter = mse;
        metrics.NoiseReduction = ((noiseBefore - noiseAfter) / noiseBefore) * 100;
    end
    
end