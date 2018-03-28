function [ ssd ] = normalised_ssd( img1, img2 )
%     norm1 = (img1 - mean2(img1)) / std2(img1);
%     norm2 = (img2 - mean2(img2)) / std2(img2);
%     diff = norm1 - norm2;
%     ssd = sum(diff(:).^2);

    diff = img1 - img2;
    ssd = sum(diff(:).^2);
end

