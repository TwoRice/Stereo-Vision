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
    
    % For each column of pixels in the image
    for x = 1 : height
        % Set the bounds for the column selection
        x_start = max(1, x - window_padding_x);
        x_end = min(height, x + window_padding_x);
        
        disp(['Processing Column [', num2str(x), '/', num2str(height), ']'])
        % imshow(disparity_map);

        % For each row of pixels in the column
        for y = 1 : width            
            % Set the bounds for the row
            y_start = max(1, y - window_padding_y);
            y_end = min(width, y + window_padding_y);
            
            % number of pixels that can be searched in a respective direction
            % accounts for the edges of the image
            w_above = max(-search_range, 1 - y_start);
            w_below = min(search_range, width - y_end);
                        
            reference = right(x_start:x_end, y_start:y_end);
            
            total_blocks = w_below - w_above + 1;
            similarities = zeros(total_blocks, 1);
            
            % Calculate the difference between the reference and each of the blocks.
            for i = w_above : w_below
                % Select the block from the left image at the distance 'i'.
                window = left(x_start:x_end, (y_start + i):(y_end + i));
                % Compute the similarity for this window,
                index = i - w_above + 1;
                similarities(index, 1) = SSD(reference, window);
            end
            [~, min_index] = min(similarities);
            
            
            % Change the index back to an offset
            % disparity = max(0, min_index + w_above - 1);
            disparity = min_index + w_above - 1;
            
            if (subpixel == 1 && ((min_index ~= 1) && (min_index ~= total_blocks)))
                above = similarities(min_index - 1);
                pixel = similarities(min_index);
                below = similarities(min_index + 1);
                
                disparity = disparity - (0.5 * (below - above) / (above - (2*pixel) + below));
            end
            disparity_map(x,y) = disparity;
        end
    end
    
    sigmoid = arrayfun(@(x) 1./(1 + exp(-1.*(x))), disparity_map);
end