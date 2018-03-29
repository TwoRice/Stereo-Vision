function [left, right] = PREP_IMAGES(left_path, right_path)
    left = imread(left_path);
    right = imread(right_path);
    assert(size(left, 1) == size(right, 1), 'Images not the same dimensions');
    assert(size(left, 2) == size(right, 2), 'Images not the same dimensions');
    if (size(left, 3) ~= 1)
        left = rgb2gray(left);
    end
    if (size(right, 3) ~= 1)
        right = rgb2gray(right);
    end
%     if(size(left, 1) > 350)
%         scale_factor = 350 / max(size(left));
%         left = imresize(left, scale_factor);
%         right = imresize(right, scale_factor);
%     end
end