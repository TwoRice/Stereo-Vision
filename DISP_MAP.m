function [disparity_map, sigmoid] = DISP_MAP(left, right, padding, search_size_factor, subpixel)
    % Load the stereo images.
    [left, right] = PREP_IMAGES(left, right);
    
    disparity_map = zeros(size(left));
    
    % Define the size of the blocks for block matching.
    window_padding_x = padding;
    window_padding_y = window_padding_x;
    % effective window_size = 2 * window_padding + 1 in both directions
    search_range = window_padding_x * search_size_factor;
    
    [height, width] = size(left);
    
    % For each row of pixels in the image
    for y = 1 : height
        % Set the bounds for the column selection
        y_start = max(1, y - window_padding_y);
        y_end = min(height, y + window_padding_y);
        
        disp(['Processing Row [', num2str(y), '/', num2str(height), ']'])

        % For each column of pixels in the row
        for x = 1 : width            
            % Set the bounds for the row
            x_start = max(1, x - window_padding_x);
            x_end = min(width, x + window_padding_x);
            
            % number of pixels that can be searched in a respective direction
            % accounts for the edges of the image
            w_left = max(-search_range, 1 - x_start);
            w_right = min(search_range, width - x_end);
            w_size = w_right - w_left + 1;
            
            similarities = zeros(w_size, 1);
            
            reference = right(y_start:y_end, x_start:x_end);
            
            % Calculate the difference between the reference and each of the blocks.
            for i = w_left : w_right
                % Select the block from the left image at the distance 'i'.
                window = left(y_start:y_end, (x_start + i):(x_end + i));
                % Compute the similarity for this window,
                index = i - w_left + 1;
                similarities(index, 1) = SSD(reference, window);
            end
            [~, min_index] = min(similarities);
            
            
            % Change the index back to an offset
            disparity = max(0, min_index + w_left - 1);
%             disparity = min_index + w_left - 1;
            
            if (subpixel == 1 && ((min_index ~= 1) && (min_index ~= w_size)))
                before = similarities(min_index - 1);
                pixel = similarities(min_index);
                after = similarities(min_index + 1);
               
                % adjust the disparity meausure of a pixel according to that of its neighbours
                % formula taken from "RB Fisher - Sub-pixel estimation"
                % disparity = disparity - ((after-before)/(2*pixel))
                disparity = disparity - (((2*pixel)-after-before)/(2*(after-before)));
            end
            disparity_map(y,x) = disparity;
        end
    end
    
%      n = std(disparity_map(:));
    
    sigmoid = arrayfun(@(x) 1./(1 + exp(-2.*(x))), disparity_map);
end