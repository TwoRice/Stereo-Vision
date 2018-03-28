function [ ssd ] = ssd( img1, img2 )
    diff = img1 - img2;
    ssd = sum(diff(:).^2);
end

