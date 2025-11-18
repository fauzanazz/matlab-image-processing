function edge_img = laplace_edge_detection(img, threshold_factor)
% LAPLACE_EDGE_DETECTION - Deteksi tepi menggunakan operator Laplace
%
% Syntax: edge_img = laplace_edge_detection(img, threshold_factor)
%
% Input:
%   img              - Citra input (grayscale, double)
%   threshold_factor - Faktor threshold (default: 0.1)
%
% Output:
%   edge_img - Citra biner hasil deteksi tepi
%
% Deskripsi:
%   Operator Laplace adalah turunan kedua yang mendeteksi perubahan
%   intensitas dengan mencari zero-crossing. Kernel yang digunakan:
%   [ 0 -1  0]
%   [-1  4 -1]
%   [ 0 -1  0]

    if nargin < 2
        threshold_factor = 0.1;
    end
    
    % Kernel Laplace (4-connected)
    laplace_kernel = [0 -1  0;
                     -1  4 -1;
                      0 -1  0];
    
    % Alternatif: 8-connected Laplace kernel
    % laplace_kernel = [-1 -1 -1;
    %                   -1  8 -1;
    %                   -1 -1 -1];
    
    laplace_response = conv2(img, laplace_kernel, 'same');
    threshold = threshold_factor * max(abs(laplace_response(:)));
    edge_img = abs(laplace_response) > threshold;
    edge_img = bwareaopen(edge_img, 10); 
    edge_img = imclose(edge_img, strel('disk', 1)); 
    
end