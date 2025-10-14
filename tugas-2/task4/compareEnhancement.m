function results = compareEnhancement(image, params)
    numTests = length(params);
    results = struct('name', {}, 'enhanced', {}, 'params', {}, 'metrics', {}, 'spectrum', {});

    fprintf('Comparing %d enhancement configurations...\n', numTests);

    for i = 1:numTests
        fprintf('  [%d/%d] %s... ', i, numTests, params(i).name);

        tic;
        [enhanced, spectrum] = homomorphicFilter(image, ...
            params(i).gammaL, params(i).gammaH, params(i).c, params(i).D0);
        elapsed = toc;

        metrics = calculateMetrics(image, enhanced);
        metrics.processingTime = elapsed;

        results(i).name = params(i).name;
        results(i).enhanced = enhanced;
        results(i).params = params(i);
        results(i).metrics = metrics;
        results(i).spectrum = spectrum;

        fprintf('Done (%.3fs)\n', elapsed);
    end

    fprintf('Comparison complete!\n');
end

function metrics = calculateMetrics(original, enhanced)
    orig = double(original);
    enh = double(enhanced);

    metrics.meanBrightnessOrig = mean(orig(:));
    metrics.meanBrightnessEnh = mean(enh(:));
    metrics.brightnessIncrease = metrics.meanBrightnessEnh - metrics.meanBrightnessOrig;
    metrics.brightnessRatio = metrics.meanBrightnessEnh / metrics.meanBrightnessOrig;

    metrics.contrastOrig = std(orig(:));
    metrics.contrastEnh = std(enh(:));
    metrics.contrastIncrease = metrics.contrastEnh - metrics.contrastOrig;

    metrics.dynamicRangeOrig = double(max(original(:))) - double(min(original(:)));
    metrics.dynamicRangeEnh = double(max(enhanced(:))) - double(min(enhanced(:)));

    metrics.entropyOrig = entropy(original);
    metrics.entropyEnh = entropy(enhanced);

    if size(original, 3) == 1
        [countsOrig, ~] = imhist(original);
        [countsEnh, ~] = imhist(enhanced);
    else
        countsOrig = (imhist(original(:,:,1)) + imhist(original(:,:,2)) + imhist(original(:,:,3))) / 3;
        countsEnh = (imhist(enhanced(:,:,1)) + imhist(enhanced(:,:,2)) + imhist(enhanced(:,:,3))) / 3;
    end

    metrics.histUniformityOrig = sum((countsOrig / sum(countsOrig)).^2);
    metrics.histUniformityEnh = sum((countsEnh / sum(countsEnh)).^2);

    if size(original, 3) == 1
        grayOrig = original;
        grayEnh = enhanced;
    else
        grayOrig = rgb2gray(original);
        grayEnh = rgb2gray(enhanced);
    end

    [Gx, Gy] = gradient(double(grayOrig));
    metrics.edgeContentOrig = mean(sqrt(Gx(:).^2 + Gy(:).^2));

    [Gx, Gy] = gradient(double(grayEnh));
    metrics.edgeContentEnh = mean(sqrt(Gx(:).^2 + Gy(:).^2));
end
