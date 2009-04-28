function collision_probabilities = TowerCollision(wingspan, ...
                                                  tower_height, ...
                                                  tower_base_diameter, ...
                                                  tower_top_diameter, ...
                                                  resolution)
               
                                   
                                   
%####################################          
% The points of the 6-sided polygon
%####################################    
top_left_x = -tower_top_diameter/2 - wingspan/2;
top_left_y = tower_height;
top_right_x = -top_left_x;
top_right_y = top_left_y;

bottom_left_x = -tower_base_diameter/2 - wingspan/2;
bottom_left_y = 0;
bottom_right_x = -bottom_left_x;
bottom_right_y = bottom_left_y;

%####################################    
% The linear equations for the sides
% %####################################    
left_side = polyfit([bottom_left_x top_left_x-0.001],[bottom_left_y top_left_y],1);
right_side = polyfit([bottom_right_x top_right_x+0.001],[bottom_right_y top_right_y],1);

% widest_point = max([tower_base_diameter tower_widest_diameter tower_top_diameter]);
widest_point = max([tower_base_diameter tower_top_diameter]);
widest_collision_zone = widest_point + wingspan;
x_pixels = round(resolution * widest_collision_zone);
y_pixels = round(resolution * tower_height);

collision_probabilities = zeros(x_pixels,y_pixels);

x_samples = linspace(-widest_collision_zone/2,widest_collision_zone/2,x_pixels);
y_samples = linspace(0,tower_height,y_pixels);

for x_idx = 1:x_pixels
    for y_idx = 1:y_pixels
        x_dim = x_samples(x_idx);
        y_dim = y_samples(y_idx);
        if x_dim >= (y_dim - left_side(2))/left_side(1) && ...
           x_dim <= (y_dim - right_side(2))/right_side(1)
       
           collision_probabilities(x_idx,y_idx) = 1;
        end
    end
end

%Put into cartesian, not (row,column), coordinate space.
collision_probabilities = collision_probabilities';

            
