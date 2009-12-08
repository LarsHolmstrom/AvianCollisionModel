close all
clear variables


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Static windfarm parameters
windfarm_specification.tower_locations(1).x = -30;
windfarm_specification.tower_locations(1).y = -30;
windfarm_specification.tower_locations(2).x = -90;
windfarm_specification.tower_locations(2).y = -90;
windfarm_specification.tower_locations(3).x = 30;
windfarm_specification.tower_locations(3).y = 30;
windfarm_specification.tower_locations(4).x = 90;
windfarm_specification.tower_locations(4).y = 90;
windfarm_specification.tower_locations(5).x = -90;
windfarm_specification.tower_locations(5).y = 90;
windfarm_specification.tower_locations(6).x = 0;
windfarm_specification.tower_locations(6).y = 90;
windfarm_specification.tower_locations(7).x = 0;
windfarm_specification.tower_locations(7).y = -90;
windfarm_specification.tower_locations(8).x = 90;
windfarm_specification.tower_locations(8).y = -90;

% Static turbine specification
turbine_specification.tower_height = 50; % meters
turbine_specification.turbine_radius = 20; % meters
turbine_specification.hub_radius = 4; % meters
turbine_specification.tower_base_diameter = 4; % meters
turbine_specification.tower_top_diameter = 3; % meters
turbine_specification.n_blades = 3;

% Dynamic simulation parameters
wind_direction_degrees = 45; % degrees clockwise from north
wind_speed = 10; %m/s


bird_path_specifications.direction = 90; % degrees clockwise from north
bird_path_specifications.height = 43; % meters
bird_path_specifications.speed = 10; % m/s
bird_path_specifications.intercept.x = -90;
bird_path_specifications.intercept.y = -90;


[turbine_intercepts, ...
  tower_intercepts] = FindWindFarmIntersects(windfarm_specification, ...
                                             turbine_specification, ...
                                             bird_path_specifications, ...
                                             wind_direction_degrees, ...
                                             wind_speed);
                                         
% function [return_probabilities ...
%           angle_of_orientation_degrees ...
%           mean_probability ...
%           mean_aperture_probability] = TurbineCollision(bird_wingspan, ... %Meters
%                                                        bird_length, ... %Meters
%                                                        n_blades, ...
%                                                        turbine_radius, ... %Meters
%                                                        hub_radius, ... %Meters
%                                                        angular_velocity, ... %RPMs
%                                                        maximum_blade_chord_length, ... %Meters
%                                                        axial_induction, ...
%                                                        wind_speed, ... %Meters/Second
%                                                        wind_direction, ... %Degrees clockwise from 12:00
%                                                        bird_speed, ... %Meters/Second, relative to ground
%                                                        bird_direction, ... %Degrees clockwise from 12:00 of the flightpath
%                                                        plot_type, ... %0:no_plot, 1:turbine, 2:bird
%                                                        resolution, ... %Pixels/Meter
%                                                        model_type, ...
%                                                        y_dim, ... %Meters
%                                                        z_dim) %Meters