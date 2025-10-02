I = imread('test_images/color1.jpg');   % load RGB image

figure;
subplot(3,1,1);
imhist(I(:,:,1)); title('Red Channel');

subplot(3,1,2);
imhist(I(:,:,2)); title('Green Channel');

subplot(3,1,3);
imhist(I(:,:,3)); title('Blue Channel');