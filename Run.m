reference = 'pentagon_left.bmp';
search = 'pentagon_right.bmp';

dm = DisparityMapBuilder(reference, search);
map = dm.Build();
imshow(map);