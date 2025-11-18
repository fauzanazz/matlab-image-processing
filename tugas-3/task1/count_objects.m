function [num_objects, labeled_img] = count_objects(segmented_img)
% COUNT_OBJECTS - Menghitung jumlah objek dalam citra tersegmentasi
%
% Syntax: [num_objects, labeled_img] = count_objects(segmented_img)
%
% Input:
%   segmented_img - Citra hasil segmentasi
%
% Output:
%   num_objects  - Jumlah objek yang terdeteksi
%   labeled_img  - Citra dengan label untuk setiap objek
%
% Deskripsi:
%   Fungsi ini menghitung jumlah objek terpisah dalam citra tersegmentasi

    if size(segmented_img, 3) == 3
        gray_img = rgb2gray(segmented_img);
    else
        gray_img = segmented_img;
    end
    binary_mask = gray_img < 200; 
    binary_mask = bwareaopen(binary_mask, 50);
    labeled_img = bwlabel(binary_mask, 8);
    num_objects = max(labeled_img(:));
    
end