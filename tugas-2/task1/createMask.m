function mask = createMask(type, size, varargin)
    if mod(size, 2) == 0
        error('Ukuran mask harus ganjil');
    end
    
    switch lower(type)
        case 'average'
            mask = ones(size, size) / (size * size);
            
        case 'gaussian'
            if nargin < 3
                sigma = 1.0;
            else
                sigma = varargin{1};
            end
            mask = createGaussianMask(size, sigma);
            
        case 'sobel_x'
            if size ~= 3
                error('Sobel mask hanya tersedia untuk ukuran 3x3');
            end
            mask = [-1 0 1; -2 0 2; -1 0 1];
            
        case 'sobel_y'
            if size ~= 3
                error('Sobel mask hanya tersedia untuk ukuran 3x3');
            end
            mask = [-1 -2 -1; 0 0 0; 1 2 1];
            
        case 'laplacian'
            if size == 3
                mask = [0 -1 0; -1 4 -1; 0 -1 0];
            else
                mask = [-1 -1 -1; -1 17 -1; -1 -1 -1];
            end
            
        case 'sharpen'
            if size ~= 3
                error('Sharpen mask hanya tersedia untuk ukuran 3x3');
            end
            mask = [0 -1 0; -1 4 -1; 0 -1 0] / 16;
            
        case 'edge'
            if size ~= 3
                error('Edge mask hanya tersedia untuk ukuran 3x3');
            end
            mask = [-1 -1 -1; -1 8 -1; -1 -1 -1];
            
        case 'custom'
            if nargin < 3
                error('Untuk custom mask, berikan matriks mask sebagai parameter');
            end
            mask = varargin{1};
            
        otherwise
            error('Tipe mask tidak dikenali');
    end
end

function mask = createGaussianMask(size, sigma)
    center = ceil(size / 2);
    [X, Y] = meshgrid(1:size, 1:size);
    
    X = X - center;
    Y = Y - center;
    
    mask = exp(-(X.^2 + Y.^2) / (2 * sigma^2));
    mask = mask / sum(mask(:));
end