I = imread('test_images/gray1.bmp'); 
imhist(I);                    
figure;
imhist(I);                      % show histogram
title('Grayscale Histogram');   % set title
xlabel('Intensity Value');      % x-axis label
ylabel('Frequency');            % y-axis label
