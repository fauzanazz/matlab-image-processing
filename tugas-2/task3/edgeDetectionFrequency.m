function [edges, magnitude, direction] = edgeDetectionFrequency(image, method, cutoffFreq, varargin)
    if nargin < 4
        threshold = 0.1;
    else
        threshold = varargin{1};
    end
    
    if size(image, 3) == 3
        image = rgb2gray(image);
    end
    
    [filtered, ~, spectrum] = frequencyHighPass(image, method, cutoffFreq);
    
    magnitude = double(filtered);
    magnitude = magnitude / max(magnitude(:));
    
    edges = magnitude > threshold;
    
    direction = spectrum.phase;
    
    edges = bwareaopen(edges, 10);
end