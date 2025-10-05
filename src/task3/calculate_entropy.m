function entropy = calculate_entropy(hist_values)
    % Calculate entropy of histogram
    % H = -sum(p * log2(p)) where p is probability
    
    total_pixels = sum(hist_values);
    if total_pixels == 0
        entropy = 0;
        return;
    end
    
    probabilities = hist_values(hist_values > 0) / total_pixels;
    entropy = -sum(probabilities .* log2(probabilities));
end

function result = iff(condition, true_value, false_value)
    if condition
        result = true_value;
    else
        result = false_value;
    end
end