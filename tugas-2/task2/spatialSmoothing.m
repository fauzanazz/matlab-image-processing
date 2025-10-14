function [smoothed, filterUsed] = spatialSmoothing(image, method, filterSize, varargin)
% SPATIALSMOOTHING Melakukan smoothing/blurring citra dalam ranah spasial
%
% Syntax:
%   [smoothed, filterUsed] = spatialSmoothing(image, method, filterSize, ...)
%
% Input:
%   image       - Citra input (grayscale atau RGB)
%   method      - Metode: 'mean', 'average', 'gaussian', 'median', 'bilateral'
%   filterSize  - Ukuran filter (n), harus ganjil
%   varargin    - Parameter tambahan:
%                 Untuk Gaussian: sigma (default: filterSize/5)
%                 Padding method: 'zero', 'replicate', 'symmetric' (default: 'replicate')
%
% Output:
%   smoothed    - Citra hasil smoothing
%   filterUsed  - Filter/kernel yang digunakan
%
% Contoh:
%   img = imread('noisy_image.png');
%   smoothed = spatialSmoothing(img, 'gaussian', 5, 1.0);
%   smoothed = spatialSmoothing(img, 'mean', 7, 'replicate');
%
% Menggunakan fungsi konvolusi dari Part 1

    % Parse input arguments
    p = inputParser;
    addRequired(p, 'image');
    addRequired(p, 'method', @ischar);
    addRequired(p, 'filterSize', @(x) isnumeric(x) && mod(x,2)==1);
    addOptional(p, 'sigma', filterSize/5, @isnumeric);
    addOptional(p, 'paddingMethod', 'replicate', @ischar);
    parse(p, image, method, filterSize, varargin{:});
    
    sigma = p.Results.sigma;
    paddingMethod = p.Results.paddingMethod;
    
    % Validasi input
    if filterSize < 3
        error('Filter size minimal 3x3');
    end
    
    % Pilih metode smoothing
    switch lower(method)
        case {'mean', 'average'}
            % Mean/Average Filter
            filterUsed = ones(filterSize) / (filterSize^2);
            smoothed = applyConvolution(image, filterUsed, paddingMethod);
            
        case 'gaussian'
            % Gaussian Filter
            filterUsed = createGaussianFilter(filterSize, sigma);
            smoothed = applyConvolution(image, filterUsed, paddingMethod);
            
        case 'median'
            % Median Filter (non-linear, tidak menggunakan konvolusi)
            filterUsed = 'median'; % Tidak ada kernel untuk median
            smoothed = applyMedianFilter(image, filterSize, paddingMethod);
            
        case 'bilateral'
            % Bilateral Filter (edge-preserving)
            filterUsed = 'bilateral';
            smoothed = applyBilateralFilter(image, filterSize, sigma);
            
        otherwise
            error('Metode tidak dikenali. Gunakan: mean, gaussian, median, bilateral');
    end
    
end

function filter = createGaussianFilter(size, sigma)
% CREATEGAUSSIANFILTER Membuat Gaussian filter 2D
%
% Formula: G(x,y) = (1/(2*pi*sigma^2)) * exp(-(x^2+y^2)/(2*sigma^2))

    % Buat grid koordinat
    center = ceil(size / 2);
    [X, Y] = meshgrid(1:size, 1:size);
    
    % Offset dari center
    X = X - center;
    Y = Y - center;
    
    % Hitung Gaussian
    filter = exp(-(X.^2 + Y.^2) / (2 * sigma^2));
    
    % Normalisasi agar sum = 1
    filter = filter / sum(filter(:));
end

function smoothed = applyMedianFilter(image, filterSize, paddingMethod)
% APPLYMEDIANFILTER Terapkan median filter
%
% Median filter adalah non-linear filter yang bagus untuk menghilangkan
% salt & pepper noise

    [M, N, channels] = size(image);
    smoothed = zeros(size(image), class(image));
    
    % Padding
    padSize = floor(filterSize / 2);
    
    for c = 1:channels
        % Pad citra
        paddedImg = padImage(double(image(:,:,c)), padSize, paddingMethod);
        
        % Sliding window
        for i = 1:M
            for j = 1:N
                % Ekstrak window
                window = paddedImg(i:i+filterSize-1, j:j+filterSize-1);
                
                % Ambil median
                smoothed(i, j, c) = median(window(:));
            end
        end
    end
    
    smoothed = cast(smoothed, class(image));
end

function smoothed = applyBilateralFilter(image, filterSize, sigma)
% APPLYBILATERALFILTER Edge-preserving smoothing filter
%
% Bilateral filter mempertimbangkan jarak spasial DAN perbedaan intensitas

    [M, N, channels] = size(image);
    smoothed = zeros(size(image));
    
    % Parameters
    sigmaS = sigma; % Spatial sigma
    sigmaR = sigma * 10; % Range (intensity) sigma
    
    padSize = floor(filterSize / 2);
    
    for c = 1:channels
        img = double(image(:,:,c));
        paddedImg = padImage(img, padSize, 'replicate');
        
        for i = 1:M
            for j = 1:N
                % Center pixel
                iCenter = i + padSize;
                jCenter = j + padSize;
                centerVal = paddedImg(iCenter, jCenter);
                
                % Extract window
                window = paddedImg(i:i+filterSize-1, j:j+filterSize-1);
                
                % Spatial weights
                [X, Y] = meshgrid(1:filterSize, 1:filterSize);
                center = ceil(filterSize/2);
                distSq = (X-center).^2 + (Y-center).^2;
                spatialWeight = exp(-distSq / (2*sigmaS^2));
                
                % Range weights
                intensityDiff = window - centerVal;
                rangeWeight = exp(-(intensityDiff.^2) / (2*sigmaR^2));
                
                % Combined weight
                weight = spatialWeight .* rangeWeight;
                weight = weight / sum(weight(:));
                
                % Weighted sum
                smoothed(i, j, c) = sum(sum(window .* weight));
            end
        end
    end
    
    smoothed = cast(smoothed, class(image));
end

function paddedImage = padImage(image, padSize, method)
% PADIMAGE Helper function untuk padding
    [M, N] = size(image);
    
    switch lower(method)
        case 'zero'
            paddedImage = zeros(M + 2*padSize, N + 2*padSize);
            paddedImage(padSize+1:padSize+M, padSize+1:padSize+N) = image;
            
        case 'replicate'
            paddedImage = padarray(image, [padSize padSize], 'replicate');
            
        case 'symmetric'
            paddedImage = padarray(image, [padSize padSize], 'symmetric');
            
        otherwise
            error('Unknown padding method');
    end
end