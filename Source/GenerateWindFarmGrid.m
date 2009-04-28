function [turbine_locations_x turbine_locations_y] = GenerateWindFarmGrid(num_rows, ...
                                                                          num_columns, ...
                                                                          distance_between_rows, ...
                                                                          distance_between_columns)
                                                                          


%Generate a grid formation of wind turbines
turbine_locations_x = zeros(num_rows,num_columns);
turbine_locations_y = zeros(num_rows,num_columns);
for y_idx = 1:num_rows
    for x_idx = 1:num_columns
        turbine_locations_x(y_idx,x_idx) = x_idx * distance_between_columns;
        turbine_locations_y(y_idx,x_idx) = y_idx * distance_between_rows;
    end
end
middle_x = mean(turbine_locations_x(:));
middle_y = mean(turbine_locations_y(:));
turbine_locations_x = turbine_locations_x(:) - middle_x;
turbine_locations_y = turbine_locations_y(:) - middle_y;
