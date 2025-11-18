function edge_img = sobel_edge_detection(img, threshold_factor)
% SOBEL_EDGE_DETECTION - Deteksi tepi menggunakan operator Sobel
%
% Syntax: edge_img = sobel_edge_detection(img, threshold_factor)
%
% Input:
%   img              - Citra input (grayscale, double)
%   threshold_factor - Faktor threshold (default: 0.15)
%
% Output:
%   edge_img - Citra biner hasil deteksi tepi
%
% Deskripsi:
%   Operator Sobel mendeteksi tepi dengan menghitung gradien menggunakan
%   kernel 3x3 yang memberikan bobot lebih pada piksel pusat.
%   Gx (horizontal):    Gy (vertical):
%   [-1  0  1]          [-1 -2 -1]
%   [-2  0  2]          [ 0  0  0]
%   [-1  0  1]          [ 1  2  1]

    if nargin < 2
        threshold_factor = 0.15;
    end
    
    % Kernel Sobel untuk deteksi tepi horizontal (Gx)
    sobel_x = [-1  0  1;
               -2  0  2;
               -1  0  1];
    
    % Kernel Sobel untuk deteksi tepi vertikal (Gy)
    sobel_y = [-1 -2 -1;
                0  0  0;
                1  2  1];
    
    Gx = conv2(img, sobel_x, 'same');
    Gy = conv2(img, sobel_y, 'same');
    gradient_magnitude = sqrt(Gx.^2 + Gy.^2);
    gradient_magnitude = gradient_magnitude / max(gradient_magnitude(:));
    threshold = threshold_factor * max(gradient_magnitude(:));
    edge_img = gradient_magnitude > threshold;
    gradient_direction = atan2(Gy, Gx);
    edge_img = non_maximum_suppression(gradient_magnitude, gradient_direction, threshold);
    edge_img = bwareaopen(edge_img, 10);
    edge_img = imclose(edge_img, strel('disk', 1));
    
end

function nms_img = non_maximum_suppression(magnitude, direction, threshold)
    [rows, cols] = size(magnitude);
    nms_img = false(rows, cols);
    direction = direction * 180 / pi;
    direction(direction < 0) = direction(direction < 0) + 180;
    
    for i = 2:rows-1
        for j = 2:cols-1
            if magnitude(i, j) < threshold
                continue;
            end
            
            angle = direction(i, j);
            
            if (angle >= 0 && angle < 22.5) || (angle >= 157.5 && angle <= 180)
                % Horizontal (0°)
                neighbors = [magnitude(i, j-1), magnitude(i, j+1)];
            elseif (angle >= 22.5 && angle < 67.5)
                % Diagonal 45°
                neighbors = [magnitude(i-1, j+1), magnitude(i+1, j-1)];
            elseif (angle >= 67.5 && angle < 112.5)
                % Vertical (90°)
                neighbors = [magnitude(i-1, j), magnitude(i+1, j)];
            else % (angle >= 112.5 && angle < 157.5)
                % Diagonal 135°
                neighbors = [magnitude(i-1, j-1), magnitude(i+1, j+1)];
            end
            
            if magnitude(i, j) >= max(neighbors)
                nms_img(i, j) = true;
            end
        end
    end
end