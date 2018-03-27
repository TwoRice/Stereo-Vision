classdef DisparityMapBuilder
    properties
        reference;
        search;
        
        window_size = 3;
        search_window_factor = 2;
    end
    
    methods
        function obj = DisparityMapBuilder(reference, search)
            [obj.reference, obj.search] = obj.prep_images(reference, search);
        end
        
        function [disparity_map] = Build(obj)
            [width, height] = size(obj.reference);
            
            % calculate the number of full samples
            cols = width - obj.window_size * obj.search_window_factor;
            rows = height - obj.window_size * obj.search_window_factor;
            
            disparity_map = zeros(cols, rows);
            
            % foreach pixel in the reference image
            for col = 1 : cols
                disp(['Processing Column [', num2str(col), '/', num2str(cols), ']'])
                for row = 1 : rows
                    % extract the reference window around the target pixel
                    ref_window = obj.extract_window(obj.reference, col, row);
                    
                    % define the search window
                    search_window = obj.extract_search_window(obj.search, col, row);
                    
                    correspondance = [];
                    % foreach pixel in the search window
                    for x = 1 : size(search_window, 1) - obj.window_size + 1
                        for y = 1 :size(search_window, 2) - obj.window_size + 1
                            % extract a window to be sampled
                            support_window = obj.extract_window(search_window, x, y);
                            ssd = obj.normalised_ssd(ref_window, support_window);
                            correspondance(x,y) = ssd;
                        end
                    end
                    
                    [c_height, c_width] = size(correspondance);
                    ref_index = [(c_height - 2) * obj.window_size, (c_width - 2) * obj.window_size]; % CHANGE THIS
                    [~, min_index] = min(correspondance(:));
                    min_index = (min_index * obj.window_size);
                    disparity_map(col, row) = norm(ref_index - min_index);
                end
            end
            
            disparity_map = disparity_map - min(disparity_map);
            disparity_map = disparity_map ./ max(disparity_map);
        end
    end
    
    methods(Access = private)
        function [ssd] = normalised_ssd(~, img1, img2 )
            norm1 = (img1 - mean2(img1)) / std2(img1);
            norm2 = (img2 - mean2(img2)) / std2(img2);
            diff = norm1 - norm2;
            ssd = sum(diff(:).^2);
        end
        
        function [ssd] = ssd(~, left, right)
            left_int = int16(left);
            right_int = int16(right);
            ssd_matrix = (left_int-right_int);
            
            ssd = sumsqr(ssd_matrix);
            ssd = 0 - ssd;
        end
        
        function [left, right] = prep_images(~, left_path, right_path)
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
        end
        
        function [ window ] = extract_window(obj, image, col, row)
            width = obj.window_size - 1;
            window = image(row:row + width, col:col+width);
        end
        
        
        function [ window ] = extract_search_window(obj, image, col, row)
            width = (obj.search_window_factor * obj.window_size) - 1;
            window = image(row:row + width, col:col + width);
        end
    end
end
