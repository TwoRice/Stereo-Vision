function [ ssd ] = NORMALISED_SSD( left, right)
    norm1 = (left - mean2(left)) / std2(left);
    norm2 = (right - mean2(right)) / std2(right);
    diff = norm1 - norm2;
    ssd = sum(diff(:).^2);
end

