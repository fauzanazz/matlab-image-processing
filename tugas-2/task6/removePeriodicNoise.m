function [g, info] = removePeriodicNoise(img, varargin)
% REMOVEPERIODICNOISE Remove periodic noise from an image using frequency domain filtering
%
% Syntax:
%   [g, info] = removePeriodicNoise(img)
%   [g, info] = removePeriodicNoise(filename)
%   [g, info] = removePeriodicNoise(__, Name, Value)
%
% Description:
%   This function automatically detects and removes periodic noise from images
%   by analyzing the frequency spectrum, identifying symmetric peak pairs that
%   represent periodic interference, and applying adaptive frequency domain filters.
%
% Input:
%   img       - Input image (grayscale) or filename string
%
% Optional Name-Value Pairs:
%   'MedianKernelSize'  - Kernel size for median blur (default: 31)
%   'CenterRadius'      - Radius to exclude center region (default: 10)
%   'RadiusThreshold'   - Threshold for radius spread (default: 5)
%   'NotchRadius'       - Radius for notch filters (default: 10)
%   'Visualize'         - Show visualization (default: false)
%
% Output:
%   g     - Filtered output image (normalized to [0,1])
%   info  - Structure containing processing information:
%           .spectrum     - Log magnitude spectrum
%           .peaks        - Detected peak coordinates
%           .pairs        - Matched symmetric pairs
%           .filter       - Applied frequency filter
%           .originalImg  - Original input image
%
% Example:
%   % Remove periodic noise from an image
%   img = imread('noisy_image.png');
%   [cleaned, info] = removePeriodicNoise(img, 'Visualize', true);
%
% See also: fft2, fftshift, graythresh, bwconncomp

    % Parse input arguments
    p = inputParser;
    addRequired(p, 'img');
    addParameter(p, 'MedianKernelSize', 31, @(x) isnumeric(x) && x > 0 && mod(x,2)==1);
    addParameter(p, 'CenterRadius', 10, @(x) isnumeric(x) && x > 0);
    addParameter(p, 'RadiusThreshold', 5, @(x) isnumeric(x) && x > 0);
    addParameter(p, 'NotchRadius', 10, @(x) isnumeric(x) && x > 0);
    validFilterTypes = {'auto', 'bandreject', 'bandpass', 'notch'};
    addParameter(p, 'Visualize', false, @islogical);
    addParameter(p, 'FilterType', 'auto', @(x) any(strcmpi(x, validFilterTypes)));
    parse(p, img, varargin{:});

    params = p.Results;
    params.FilterType = lower(params.FilterType);

    % Step 1: Read and normalize grayscale image
    img = readGrayNormalized(params.img);
    [M, N] = size(img);

    % Step 2: Compute FFT and shift to center
    F = fft2(img);
    Fsh = fftshift(F);

    % Step 3: Create log magnitude spectrum
    S = log(1 + abs(Fsh));

    % Step 4: Background subtraction using median blur
    Sbg = medianBlur(S, params.MedianKernelSize);
    Spk = S - Sbg;
    
    % Normalize the peak spectrum for better thresholding
    Spk = Spk - min(Spk(:));
    peakRange = max(Spk(:));
    if peakRange > eps
        Spk = Spk / peakRange;
    else
        Spk = zeros(size(Spk));
    end

    % Step 5: Adaptive threshold using Otsu's method with stricter filtering
    otsuThreshold = graythresh(Spk);
    threshold = min(0.95, max(0, otsuThreshold) * 1.2);  % Cap threshold to keep detections alive
    mask_pk = Spk > threshold;

    % Additional morphological filtering to reduce noise peaks
    mask_pk = bwareaopen(mask_pk, 5);  % Remove small isolated regions

    % Step 6: Remove center region (DC component)
    mask_pk = removeCenter(mask_pk, params.CenterRadius);

    % Step 7: Find connected components (blobs)
    CC = bwconncomp(mask_pk);
    stats = regionprops(CC, 'Centroid', 'Area', 'BoundingBox');

    % Step 8: Extract peaks from blobs
    center_u = ceil(M / 2);
    center_v = ceil(N / 2);
    peaks = [];

    for i = 1:length(stats)
        u = round(stats(i).Centroid(2));
        v = round(stats(i).Centroid(1));

        % Check if outside center region
        dist = sqrt((u - center_u)^2 + (v - center_v)^2);
        if dist > params.CenterRadius
            width = max(stats(i).BoundingBox(3:4));
            peaks = [peaks; u, v, width, stats(i).Area];
        end
    end

    % Step 9: Match symmetric pairs
    if params.Visualize
        fprintf('Matching symmetric pairs from %d peaks...\n', size(peaks, 1));
    end
    pairs = matchSymmetricPairs(peaks, [center_u, center_v]);

    % Step 10: Create appropriate filter
    appliedFilterType = 'identity';
    if ~isempty(pairs)
        % Calculate spread of radii
        radii = sqrt((pairs(:,1) - center_u).^2 + (pairs(:,2) - center_v).^2);
        radius_spread = std(radii);

        filterChoice = params.FilterType;
        if strcmp(filterChoice, 'auto')
            if size(pairs, 1) >= 4 && radius_spread < params.RadiusThreshold
                filterChoice = 'bandreject';
            else
                filterChoice = 'notch';
            end
        end

        switch filterChoice
            case 'bandreject'
                H = makeBandRejectFilter([M, N], [center_u, center_v], mean(radii), params.NotchRadius);
                appliedFilterType = 'bandreject';
            case 'bandpass'
                H = makeBandPassFilter([M, N], [center_u, center_v], mean(radii), params.NotchRadius);
                appliedFilterType = 'bandpass';
            case 'notch'
                H = makeNotchRejectFilter([M, N], pairs, params.NotchRadius);
                appliedFilterType = 'notch';
            otherwise
                H = ones(M, N);
                appliedFilterType = 'identity';
        end
    else
        % No peaks detected, use identity filter
        H = ones(M, N);
        appliedFilterType = 'identity';
    end

    % Step 11: Apply filter
    Gsh = Fsh .* H;

    % Step 12: Inverse FFT
    g = real(ifft2(ifftshift(Gsh)));

    % Step 13: Normalize output
    g = normalizeImage(g);

    % Store information
    if nargout > 1
        info.spectrum = S;
        info.peaks = peaks;
        info.pairs = pairs;
        info.filter = H;
        info.originalImg = img;
        info.backgroundSpectrum = Sbg;
        info.peakMask = mask_pk;
        info.filterType = appliedFilterType;
    end

    % Visualization
    if params.Visualize
        visualizeResults(img, g, S, mask_pk, peaks, pairs, H);
    end
end

%% ======================== HELPER FUNCTIONS ========================

function img = readGrayNormalized(input)
% READGRAYNORMALIZED Read and normalize a grayscale image
%
% Input can be:
%   - Already loaded grayscale image matrix
%   - Filename string
%   - RGB image (will be converted to grayscale)

    if ischar(input) || isstring(input)
        % Read from file
        img = imread(input);
    else
        % Already an image matrix
        img = input;
    end

    % Convert to grayscale if needed
    if size(img, 3) == 3
        img = rgb2gray(img);
    end

    % Convert to double and normalize to [0, 1]
    img = im2double(img);
end

function result = medianBlur(img, kernelSize)
% MEDIANBLUR Apply median filtering for background estimation
%
% This removes high-frequency details while preserving the overall
% structure, useful for background estimation in the spectrum.

    result = medfilt2(img, [kernelSize, kernelSize], 'symmetric');
end

function mask = removeCenter(mask, radius)
% REMOVECENTER Remove circular region from center of mask
%
% This prevents the DC component from being treated as a noise peak

    [M, N] = size(mask);
    center_u = ceil(M / 2);
    center_v = ceil(N / 2);

    [V, U] = meshgrid(1:N, 1:M);
    centerMask = sqrt((U - center_u).^2 + (V - center_v).^2) <= radius;

    mask(centerMask) = false;
end

function img_norm = normalizeImage(img)
% NORMALIZEIMAGE Normalize image to [0, 1] range

    img_norm = img - min(img(:));
    img_norm = img_norm / max(img_norm(:));
end

function pairs = matchSymmetricPairs(peaks, center)
% MATCHSYMMETRICPAIRS Find symmetric pairs of peaks around center
%
% Periodic noise appears as symmetric patterns in the frequency domain.
% This function identifies peaks that are symmetrically positioned
% around the spectrum center (DC component).
%
% Input:
%   peaks  - Nx4 matrix [u, v, width, area] of detected peaks
%   center - [u0, v0] coordinates of spectrum center
%
% Output:
%   pairs  - Mx2 matrix of [u, v] coordinates for all peaks in pairs

    if isempty(peaks)
        pairs = [];
        return;
    end

    center_u = center(1);
    center_v = center(2);

    % Storage for matched pairs
    pairs = [];
    used = false(size(peaks, 1), 1);
    
    % Adaptive tolerance based on peak width and image size
    if ~isempty(peaks)
        avg_width = mean(peaks(:, 3));
        tolerance = max(10, min(30, avg_width * 1.5));  % Constrain tolerance to reasonable range
    else
        tolerance = 15;
    end

    % Early exit if too many peaks (performance optimization)
    max_peaks = 200;  % Limit to prevent excessive computation
    if size(peaks, 1) > max_peaks
        fprintf('Warning: Too many peaks detected (%d), limiting to %d most prominent\n', size(peaks, 1), max_peaks);
        % Sort by area and keep only the largest peaks
        [~, sort_idx] = sort(peaks(:, 4), 'descend');
        peaks = peaks(sort_idx(1:max_peaks), :);
    end

    % For each peak, find its symmetric counterpart
    for i = 1:size(peaks, 1)
        if used(i)
            continue;
        end

        % Progress indicator for large peak sets
        if mod(i, 50) == 0 && size(peaks, 1) > 100
            fprintf('  Processed %d/%d peaks...\n', i, size(peaks, 1));
        end

        u1 = peaks(i, 1);
        v1 = peaks(i, 2);

        % Calculate expected symmetric position
        u2_expected = 2 * center_u - u1;
        v2_expected = 2 * center_v - v1;

        % Find nearest peak to expected position
        min_dist = inf;
        match_idx = -1;

        for j = i+1:size(peaks, 1)
            if used(j)
                continue;
            end

            u2 = peaks(j, 1);
            v2 = peaks(j, 2);

            dist = sqrt((u2 - u2_expected)^2 + (v2 - v2_expected)^2);

            if dist < min_dist && dist < tolerance
                min_dist = dist;
                match_idx = j;
            end
        end

        % If a good match is found, add both peaks to pairs
        if match_idx > 0
            pairs = [pairs; u1, v1];
            pairs = [pairs; peaks(match_idx, 1), peaks(match_idx, 2)];
            used(i) = true;
            used(match_idx) = true;
        else
            % Also include single peaks (might be on axis of symmetry)
            % Check if peak is reasonably far from center
            dist_from_center = sqrt((u1 - center_u)^2 + (v1 - center_v)^2);
            if dist_from_center > 15
                pairs = [pairs; u1, v1];
                used(i) = true;
            end
        end
    end
end

function H = makeBandRejectFilter(imgSize, center, radius, bandwidth)
% MAKEBANDREJECTFILTER Create a band-reject (band-stop) filter
%
% This filter rejects frequencies at a specific distance from the center,
% useful when periodic noise appears at a consistent radius.
%
% Input:
%   imgSize   - [M, N] size of the image
%   center    - [u0, v0] center coordinates
%   radius    - Distance from center to reject
%   bandwidth - Width of the rejection band
%
% Output:
%   H - Band-reject filter in frequency domain

    M = imgSize(1);
    N = imgSize(2);
    center_u = center(1);
    center_v = center(2);

    % Create distance matrix from center
    [V, U] = meshgrid(1:N, 1:M);
    D = sqrt((U - center_u).^2 + (V - center_v).^2);

    % Butterworth band-reject filter
    n = 2; % Order of the filter
    W = bandwidth;

    % Compute filter transfer function with improved numerical stability
    denominator = (D.^2 - radius^2);
    H = 1 ./ (1 + ((D .* W) ./ (denominator + eps)).^(2*n));
    
    % Fix any NaN or Inf values
    H(~isfinite(H)) = 0;

    % Set DC component to 1 (don't filter DC)
    H(center_u, center_v) = 1;
end

function H = makeBandPassFilter(imgSize, center, radius, bandwidth)
% MAKEBANDPASSFILTER Create a band-pass filter using Butterworth formulation
%
% The band-pass filter is computed as the complement of the corresponding
% band-reject filter, preserving a narrow ring of frequencies around the
% detected periodic components.

    Hbr = makeBandRejectFilter(imgSize, center, radius, bandwidth);
    H = 1 - Hbr;

    % Ensure filter remains bounded in [0, 1]
    H = max(0, min(1, H));
end

function H = makeNotchRejectFilter(imgSize, peaks, radius)
% MAKENOTCHREJECTFILTER Create notch reject filter for specific peaks
%
% This creates a filter that rejects frequencies at specific locations,
% useful when noise peaks are scattered at different distances from center.
%
% Input:
%   imgSize - [M, N] size of the image
%   peaks   - Nx2 matrix of [u, v] coordinates to reject
%   radius  - Radius of each notch
%
% Output:
%   H - Notch reject filter in frequency domain

    M = imgSize(1);
    N = imgSize(2);

    % Start with all-pass filter
    H = ones(M, N);

    % Create coordinate matrices
    [V, U] = meshgrid(1:N, 1:M);

    % For each peak, create a notch
    for i = 1:size(peaks, 1)
        u_peak = peaks(i, 1);
        v_peak = peaks(i, 2);

        % Distance from this peak
        D = sqrt((U - u_peak).^2 + (V - v_peak).^2);

        % Butterworth notch filter (more selective than Gaussian)
        n = 4; % Order
        notch = 1 ./ (1 + (radius ./ (D + eps)).^(2*n));

        % Multiply into filter
        H = H .* notch;
    end
end

function visualizeResults(img, g, S, mask_pk, peaks, pairs, H)
% VISUALIZERESULTS Display comprehensive visualization of the filtering process

    figure('Name', 'Periodic Noise Removal Results', 'Position', [100, 100, 1400, 900]);

    % Original image
    subplot(3, 3, 1);
    imshow(img, []);
    title('Original Image', 'FontWeight', 'bold');
    colorbar;

    % Frequency spectrum (log magnitude)
    subplot(3, 3, 2);
    imshow(S, []);
    title('Log Magnitude Spectrum', 'FontWeight', 'bold');
    colorbar;

    % Peak detection mask
    subplot(3, 3, 3);
    imshow(mask_pk);
    title('Detected Peaks Mask', 'FontWeight', 'bold');

    % Spectrum with detected peaks
    subplot(3, 3, 4);
    imshow(S, []);
    hold on;
    if ~isempty(peaks)
        plot(peaks(:, 2), peaks(:, 1), 'r+', 'MarkerSize', 10, 'LineWidth', 2);
    end
    if ~isempty(pairs)
        plot(pairs(:, 2), pairs(:, 1), 'go', 'MarkerSize', 8, 'LineWidth', 2);
    end
    hold off;
    title('Spectrum with Detected Peaks', 'FontWeight', 'bold');
    legend('All Peaks', 'Matched Pairs', 'Location', 'best');
    colorbar;

    % Filter (H)
    subplot(3, 3, 5);
    imshow(H, []);
    title('Frequency Domain Filter', 'FontWeight', 'bold');
    colorbar;

    % Filter in 3D
    subplot(3, 3, 6);
    [M, N] = size(H);
    [X, Y] = meshgrid(1:min(N,100), 1:min(M,100));
    surf(X, Y, H(1:min(M,100), 1:min(N,100)), 'EdgeColor', 'none');
    view(45, 30);
    title('Filter Surface (3D View)', 'FontWeight', 'bold');
    xlabel('Frequency v');
    ylabel('Frequency u');
    zlabel('H(u,v)');
    colorbar;

    % Filtered image
    subplot(3, 3, 7);
    imshow(g, []);
    title('Filtered Output', 'FontWeight', 'bold');
    colorbar;

    % Comparison: Original vs Filtered
    subplot(3, 3, 8);
    imshowpair(img, g, 'montage');
    title('Original (Left) vs Filtered (Right)', 'FontWeight', 'bold');

    % Difference image
    subplot(3, 3, 9);
    diff_img = abs(img - g);
    imshow(diff_img, []);
    title('Removed Noise (Difference)', 'FontWeight', 'bold');
    colorbar;

    % Add overall title
    sgtitle('Periodic Noise Removal - Complete Analysis', 'FontSize', 14, 'FontWeight', 'bold');
end
