function edge_img = roberts_edge_detection(img, threshold_factor)
% ROBERTS_EDGE_DETECTION - Deteksi tepi menggunakan operator Roberts
%
% Syntax: edge_img = roberts_edge_detection(img, threshold_factor)
%
% Input:
%   img              - Citra input (grayscale, double)
%   threshold_factor - Faktor threshold (default: 0.12)
%
% Output:
%   edge_img - Citra biner hasil deteksi tepi
%
% Deskripsi:
%   Operator Roberts menggunakan kernel 2x2 untuk mendeteksi tepi diagonal.
%   Ini adalah operator gradien paling sederhana.
%   Gx:           Gy:
%   [ 1  0]       [ 0  1]
%   [ 0 -1]       [-1  0]

    if nargin < 2
        threshold_factor = 0.12;
    end
    
    % Kernel Roberts untuk deteksi diagonal 1 (Gx)
    roberts_x = [ 1  0;
                  0 -1];
    
    % Kernel Roberts untuk deteksi diagonal 2 (Gy)
    roberts_y = [ 0  1;
                 -1  0];
    
    Gx = conv2(img, roberts_x, 'same');
    Gy = conv2(img, roberts_y, 'same');
    gradient_magnitude = sqrt(Gx.^2 + Gy.^2);
    gradient_magnitude = gradient_magnitude / max(gradient_magnitude(:));
    threshold = threshold_factor * max(gradient_magnitude(:));
    edge_img = gradient_magnitude > threshold;
    edge_img = bwareaopen(edge_img, 8);
    edge_img = imclose(edge_img, strel('disk', 2));
    edge_img = bwmorph(edge_img, 'thin', Inf);
    
end