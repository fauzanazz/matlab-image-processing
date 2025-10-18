function [noisyImage, noiseParams] = addNoise(img, noiseType, varargin)
% ADDNOISE - Menambahkan noise ke citra
%
% Syntax:
%   [noisyImage, noiseParams] = addNoise(img, noiseType, params...)
%
% Input:
%   img       - Citra input (grayscale atau RGB)
%   noiseType - Jenis noise: 'gaussian', 'salt_pepper', 'speckle'
%   varargin  - Parameter untuk noise:
%               Gaussian: mean (default: 0), variance (default: 0.01)
%               Salt & Pepper: density (default: 0.05)
%               Speckle: variance (default: 0.04)
%
% Output:
%   noisyImage   - Citra dengan noise
%   noiseParams  - Parameter noise yang digunakan

    img = im2double(img);

    switch lower(noiseType)
        case 'gaussian'
            % Gaussian noise
            if nargin >= 3
                mean_val = varargin{1};
            else
                mean_val = 0;
            end

            if nargin >= 4
                variance = varargin{2};
            else
                variance = 0.01;
            end

            noisyImage = imnoise(img, 'gaussian', mean_val, variance);
            noiseParams.type = 'gaussian';
            noiseParams.mean = mean_val;
            noiseParams.variance = variance;

        case 'salt_pepper'
            % Salt and Pepper noise
            if nargin >= 3
                density = varargin{1};
            else
                density = 0.05;
            end

            noisyImage = imnoise(img, 'salt & pepper', density);
            noiseParams.type = 'salt_pepper';
            noiseParams.density = density;

        case 'speckle'
            % Speckle noise
            if nargin >= 3
                variance = varargin{1};
            else
                variance = 0.04;
            end

            noisyImage = imnoise(img, 'speckle', variance);
            noiseParams.type = 'speckle';
            noiseParams.variance = variance;

        otherwise
            error('Noise type tidak valid. Gunakan: gaussian, salt_pepper, atau speckle');
    end
end
