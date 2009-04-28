close all
clear variables

%Generate a grid of towers
num_turbines_per_row = 5;
num_turbines_per_column = 3;
distance_between_rows = 40; %Meters
distance_between_columns = 30; %Meters
[turbine_locations_x turbine_locations_y] = GenerateWindFarmGrid(num_turbines_per_row, ...
                                                                 num_turbines_per_column, ...
                                                                 distance_between_rows, ...
                                                                 distance_between_columns);
                                                             
% wingspan = 1;
% length = 0.5;
% n_rotors = 3;
% turbine_radius = 10; %meters
% hub_radius = 0.5; %meters
% angular_velocity = 72; %rpms
% blade_width = 0; %meters
% blade_depth = 0; %meters
% induction = 0.25;
% wind_speed = 10; %meters/sec
% wind_direction = 10; %Relative to 12:00 in clockwise degreess
% bird_speed = 5; %meters/sec
% bird_direction = 0; %relative to downwind in clockwise degrees
% tower_height = 20; %meters
% tower_width = 0.5; %meters
% resolution = 10; %pixels/meter

wingspan = 1;
length = 0.5;
n_rotors = 3;
turbine_radius = 10; %meters
hub_radius = 0.5; %meters
angular_velocity = 72; %rpms
blade_width = 0; %meters
blade_depth = 0; %meters
induction = 0.25;
wind_speed = 10; %meters/sec
wind_direction = 10; %Relative to 12:00 in clockwise degreess
bird_speed = 5; %meters/sec
bird_direction = 0; %relative to downwind in clockwise degrees
tower_height = 20; %meters
tower_width = 2; %meters
resolution = 10; %pixels/meter
                                                             
                                                             
windFarmProbabilities = WindFarmProbabilities(wingspan, ...
                                              length, ...
                                              n_rotors, ...
                                              turbine_radius, ...
                                              hub_radius, ...
                                              angular_velocity, ...
                                              blade_width, ...
                                              blade_depth, ...
                                              induction, ...
                                              wind_speed, ...
                                              wind_direction, ...
                                              bird_speed, ...
                                              bird_direction, ... %relative to downwind in clockwise degrees
                                              turbine_locations_x, ...
                                              turbine_locations_y, ...
                                              tower_height, ...
                                              tower_width, ...
                                              resolution);
                                                             