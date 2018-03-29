function [disparity_map, sigmoid] = DISP_MAP(left, right)
    % Load the stereo images.
    [left, right] = PREP_IMAGES(left, right);
    % [left, right] = PREP_IMAGES('images/scene_l.bmp', 'images/scene_r.bmp');
    % [left, right] = PREP_IMAGES('images/piano/im0.png', 'images/piano/im1.png');
    
    disparity_map = zeros(size(left));
    
    % Define the size of the blocks for block matching.
    window_padding_x = 10;
    window_padding_y = window_padding_x;
    % window_size = 2 * window_padding + 1 in both directions
    search_range = window_padding_x * 3;
    
    [height, width] = size(left);
    
    % For each column of pixels in the image
    for x = 1 : width
        % Set the bounds for the column selection
        x_start = max(1, x - window_padding_x);
        x_end = min(width, x + window_padding_x);
        
        if(mod(x, 10) == 0)
            disp(['Processing Column [', num2str(x), '/', num2str(width), ']'])
            imshow(disparity_map);
        end
        % For each row of pixels in the column
        for y = 1 : height
            %         imshow(left);
            %         hold on;
            %         rectangle('Position', [x_start, y_start + w_above, x_end - x_start, y_end - (y_start + w_above)], 'LineWidth', 2, 'EdgeColor', 'g');
            %         hold off;
            
            % Set the bounds for the row
            y_start = max(1, y - window_padding_y);
            y_end = min(height, y + window_padding_y);
            
            % number of pixels that can be searched in a respective direction
            % accounts for the edges of the image
            w_above = max(-search_range, 1 - y_start);
            w_below = min(search_range, height - y_end);
            
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
            disparity = max(0, min_index + w_above - 1);
            
            %         if ((min_index == 1) || (min_index == total_blocks))
            % Skip sub-pixel estimation and store the initial disparity value.
            disparity_map(x, y) = disparity;
            % 		else
            % 			% Grab the SAD values at the closest matching block (C2) and it's
            % 			% immediate neighbors (C1 and C3).
            % 			above = similarities(min_index - 1);
            % 			pixel = similarities(min_index);
            % 			below = similarities(min_index + 1);
            %
            % 			% Adjust the disparity by some fraction.
            % 			% We're estimating the subpixel location of the true best match.
            % 			disparity_map(x, y) = disparity - (0.5 * (below - above) / (above - (2*pixel) + below));
            %         end
        end
    end
    
%     ground_truth = imread('images/pentagon_dispmap.bmp');
%     ground_truth = im2double(ground_truth);
    sigmoid = arrayfun(@(x) 1./(1 + exp(-1.*(x))), disparity_map);
    
%     imshow(sigmoid);
end