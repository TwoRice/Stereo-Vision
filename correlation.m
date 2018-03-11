% load stereo images
left_img = imread('pentagon_left.bmp');
right_img = imread('pentagon_right.bmp');
% parameters
window_size = 8;
search_window_factor = 2.5;
show_search = 0;
pause_time = 0.0001;

search_window_size = search_window_factor * window_size * 2;
[width, height] = size(left_img);
for ref_x = 0 : window_size : width - window_size
    for ref_y = 0 : window_size : width - window_size
        ref_window_x = ref_x + 1 : ref_x + window_size;
        ref_window_y = ref_y + 1 : ref_y + window_size;
        
        ref_window = left_img(ref_window_x, ref_window_y);
        
        ref_center_x = ref_window_x(end / 2);
        start_pos_x = max(1, ((ref_center_x) - (search_window_size / 2)) + 1);
        end_pos_x = min(width, ref_center_x + (search_window_size / 2));
        search_window_x = start_pos_x : end_pos_x;
        
        ref_center_y = ref_window_y(end / 2);
        start_pos_y = max(1, ((ref_center_y) - (search_window_size / 2)) + 1);
        end_pos_y = min(height, ref_center_y + (search_window_size / 2));
        search_window_y = start_pos_y : end_pos_y;
                
        for x = search_window_x(1) : window_size : search_window_x(end)
            for y = search_window_y(1) : window_size : search_window_y(end)
                window_x = x : (x + window_size - 1);
                window_y = y : (y + window_size - 1);
                
                current_window = right_img(window_x, window_y);
                ssd = normalised_ssd(ref_window, current_window);
                
                if show_search
                    imshow(right_img);
                    hold on;
                    rectangle('Position', [start_pos_x, start_pos_y, (end_pos_x - start_pos_x + 1), (end_pos_y - start_pos_y + 1)], 'LineWidth', 2, 'EdgeColor', 'g');
                    rectangle('Position', [ref_window_x(1), ref_window_y(1), window_size, window_size], 'LineWidth', 2, 'EdgeColor', 'r');
                    rectangle('Position', [window_x(1), window_y(1), window_size, window_size], 'LineWidth', 2, 'EdgeColor', 'b');
                    pause(pause_time);
                end
            end
        end
    end
end



