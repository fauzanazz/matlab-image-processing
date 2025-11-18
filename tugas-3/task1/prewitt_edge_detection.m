function edge_img = prewitt_edge_detection(img, threshold_factor)
% PREWITT_EDGE_DETECTION - Deteksi tepi menggunakan operator Prewitt
%
% Syntax: edge_img = prewitt_edge_detection(img, threshold_factor)
%
% Input:
%   img              - Citra input (grayscale, double)
%   threshold_factor - Faktor threshold (default: 0.15)
%
% Output:
%   edge_img - Citra biner hasil deteksi tepi
%
% Deskripsi:
%   Operator Prewitt mirip dengan Sobel tetapi memberikan bobot yang sama
%   untuk semua piksel dalam satu arah.
%   Gx (horizontal):    Gy (vertical):
%   [-1  0  1]          [-1 -1 -1]
%   [-1  0  1]          [ 0  0  0]
%   [-1  0  1]          [ 1  1  1]

    if nargin < 2
        threshold_factor = 0.15;
    end
    
    % Kernel Prewitt untuk deteksi tepi horizontal (Gx)
    prewitt_x = [-1  0  1;
                 -1  0  1;
                 -1  0  1];
    
    % Kernel Prewitt untuk deteksi tepi vertikal (Gy)
    prewitt_y = [-1 -1 -1;
                  0  0  0;
                  1  1  1];
    
    Gx = conv2(img, prewitt_x, 'same');
    Gy = conv2(img, prewitt_y, 'same');
    gradient_magnitude = sqrt(Gx.^2 + Gy.^2);
    gradient_magnitude = gradient_magnitude / max(gradient_magnitude(:));
    threshold = threshold_factor * max(gradient_magnitude(:));
    edge_img = gradient_magnitude > threshold;
    gradient_direction = atan2(Gy, Gx);
    edge_img = non_maximum_suppression_prewitt(gradient_magnitude, gradient_direction, threshold);
    edge_img = bwareaopen(edge_img, 10);
    edge_img = imclose(edge_img, strel('disk', 1));
    
end

function nms_img = non_maximum_suppression_prewitt(magnitude, direction, threshold)
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
                neighbors = [magnitude(i, j-1), magnitude(i, j+1)];
            elseif (angle >= 22.5 && angle < 67.5)
                neighbors = [magnitude(i-1, j+1), magnitude(i+1, j-1)];
            elseif (angle >= 67.5 && angle < 112.5)
                neighbors = [magnitude(i-1, j), magnitude(i+1, j)];
            else
                neighbors = [magnitude(i-1, j-1), magnitude(i+1, j+1)];
            end
            
            if magnitude(i, j) >= max(neighbors)
                nms_img(i, j) = true;
            end
        end
    end
end