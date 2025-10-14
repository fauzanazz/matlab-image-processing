function [noisyImage, noiseParams] = addNoise(image, noiseType, varargin)
    img = im2double(image);
    [M, N, channels] = size(img);
    
    noisyImage = zeros(size(img));
    noiseParams = struct();
    noiseParams.type = noiseType;
    
    switch lower(noiseType)
        case 'gaussian'
            if length(varargin) >= 2
                meanVal = varargin{1};
                variance = varargin{2};
            else
                meanVal = 0;
                variance = 0.01;
            end
            
            noiseParams.mean = meanVal;
            noiseParams.variance = variance;
            
            for c = 1:channels
                noise = meanVal + sqrt(variance) * randn(M, N);
                noisyImage(:,:,c) = img(:,:,c) + noise;
            end
            
        case {'salt_pepper', 'saltpepper', 'salt&pepper'}
            if length(varargin) >= 1
                density = varargin{1};
            else
                density = 0.05;
            end
            
            noiseParams.density = density;
            
            for c = 1:channels
                temp = img(:,:,c);
                
                numSalt = round(density * M * N / 2);
                saltCoords = randperm(M*N, numSalt);
                temp(saltCoords) = 1;
                
                numPepper = round(density * M * N / 2);
                pepperCoords = randperm(M*N, numPepper);
                temp(pepperCoords) = 0;
                
                noisyImage(:,:,c) = temp;
            end
            
        case 'speckle'
            if length(varargin) >= 1
                variance = varargin{1};
            else
                variance = 0.04;
            end
            
            noiseParams.variance = variance;
            
            for c = 1:channels
                noise = sqrt(variance) * randn(M, N);
                noisyImage(:,:,c) = img(:,:,c) + img(:,:,c) .* noise;
            end
            
        case 'poisson'
            noiseParams.info = 'Poisson noise based on image intensity';
            
            for c = 1:channels
                scaled = img(:,:,c) * 255;
                noisyImage(:,:,c) = imnoise(uint8(scaled), 'poisson');
            end
            noisyImage = im2double(noisyImage);
            
        case 'uniform'
            if length(varargin) >= 2
                a = varargin{1};
                b = varargin{2};
            else
                a = -0.1;
                b = 0.1;
            end
            
            noiseParams.a = a;
            noiseParams.b = b;
            
            for c = 1:channels
                noise = a + (b-a) * rand(M, N);
                noisyImage(:,:,c) = img(:,:,c) + noise;
            end
            
        otherwise
            error('Tipe noise tidak dikenali');
    end
    
    noisyImage = max(0, min(1, noisyImage));
    if isa(image, 'uint8')
        noisyImage = im2uint8(noisyImage);
    elseif isa(image, 'uint16')
        noisyImage = im2uint16(noisyImage);
    end
end