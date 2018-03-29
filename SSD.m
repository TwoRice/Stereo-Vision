function [ssd] = SSD(left, right)
    diff = left - right;
    ssd = sum(diff(:).^2);
end