function segmented_img = segment_from_edges(edge_img, original_img)
% SEGMENT_FROM_EDGES - Segmentasi objek berdasarkan citra tepi
%
% Syntax: segmented_img = segment_from_edges(edge_img, original_img)
%
% Input:
%   edge_img     - Citra biner hasil deteksi tepi
%   original_img - Citra original (untuk visualisasi hasil)
%
% Output:
%   segmented_img - Citra hasil segmentasi objek
%
% Deskripsi:
%   Fungsi ini melakukan segmentasi objek dari citra tepi melalui:
%   1. Penutupan gap pada tepi
%   2. Filling region tertutup
%   3. Filtering berdasarkan ukuran objek
%   4. Ekstraksi objek dari citra original

    %% Step 1: Preprocessing edge image
    se_close = strel('disk', 3);
    edge_closed = imclose(edge_img, se_close);
    se_dilate = strel('disk', 2);
    edge_dilated = imdilate(edge_closed, se_dilate);
    
    %% Step 2: Fill enclosed regions
    filled = imfill(edge_dilated, 'holes');
    objects_mask = filled & ~edge_dilated;
    objects_mask = imfill(objects_mask, 'holes');
    
    %% Step 3: Object filtering
    min_area = 100; 
    objects_mask = bwareaopen(objects_mask, min_area);
    se_smooth = strel('disk', 1);
    objects_mask = imclose(objects_mask, se_smooth);
    objects_mask = imopen(objects_mask, se_smooth);
    
    %% Step 4: Extract objects from original image
    if size(original_img, 3) == 3
        segmented_img = original_img;
        
        for c = 1:3
            channel = segmented_img(:,:,c);
            channel(~objects_mask) = 255; 
            segmented_img(:,:,c) = channel;
        end
    else
        segmented_img = original_img;
        segmented_img(~objects_mask) = 255;
    end
    
    %% Outline object
    % object_boundaries = bwperim(objects_mask);
    % if size(segmented_img, 3) == 3
    %     segmented_img = insert_boundaries(segmented_img, object_boundaries, [255 0 0]);
    % end
    
end

function img_with_boundaries = insert_boundaries(img, boundaries, color)
    img_with_boundaries = img;
    for c = 1:3
        channel = img_with_boundaries(:,:,c);
        channel(boundaries) = color(c);
        img_with_boundaries(:,:,c) = channel;
    end
end