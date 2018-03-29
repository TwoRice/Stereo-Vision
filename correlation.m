% load stereo images
left_img = imread('pentagon_left.bmp');
right_img = imread('pentagon_right.bmp');
% parameters
window_size = 8;
search_factor = [1, 4, 0, 0];
show_search = 0;
pause_time = 0.0001;

search_window_size = search_factor * window_size;
[width, height] = size(left_img);

range_x = width - window_size + 1;
range_y = height - window_size + 1;
disparity = zeros(range_x, range_y);

for ref_x = 1 : range_x
    disp(['Processing Window [', num2str(ref_x), '/', num2str((width - window_size) + 1), ']'])
    
    ref_window_x = ref_x  : ref_x + window_size - 1;
    
    start_pos_x = max(1, ref_x - search_window_size(1));
    end_pos_x = min(width, ref_window_x(end) + search_window_size(2));
    for ref_y = 1 : range_y
        ref_window_y = ref_y  : ref_y + window_size - 1;
        
        ref_window = left_img(ref_window_x, ref_window_y);
                    
        start_pos_y = max(1, ref_y - search_window_size(3));
        end_pos_y = min(height, ref_window_y(end) + search_window_size(4));
        
        search_window = right_img(start_pos_x:end_pos_x, start_pos_y:end_pos_y);
                
        closest_correspondance = {Inf, [-1, -1]};
        for x = 1 : size(search_window, 1) - window_size + 1
            window_x = x : (x + window_size - 1);
            for y = 1 : size(search_window, 2) - window_size + 1                
                window_y = y : (y + window_size - 1);
                                
                current_window = search_window(window_x, window_y);
                ssd = normalised_ssd(ref_window, current_window);
                if abs(ssd) < abs(closest_correspondance{1})
                    closest_correspondance = {ssd, [x + start_pos_x - 1, y + start_pos_y - 1]};
                end
                
                if show_search
                    imshow(right_img);
                    hold on;
                    rectangle('Position', [start_pos_x, start_pos_y, (end_pos_x - start_pos_x + 1), (end_pos_y - start_pos_y + 1)], 'LineWidth', 2, 'EdgeColor', 'g');
                    rectangle('Position', [ref_window_x(1), ref_window_y(1), window_size, window_size], 'LineWidth', 2, 'EdgeColor', 'r');
                    rectangle('Position', [window_x(1) + start_pos_x - 1, window_y(1) + start_pos_y - 1, window_size, window_size], 'LineWidth', 2, 'EdgeColor', 'b');
                    pause(pause_time);
                end
            end
        end
        
        ref_index = [ref_x, ref_y];
        disparity_vector = ref_index - closest_correspondance{2};
        disparity(ref_x, ref_y) = norm(ref_index - closest_correspondance{2});
    end
end

disparity = disparity - min(disparity(:));
disparity = disparity / max(disparity(:));
imshow(disparity)
figure
surf(disparity)
