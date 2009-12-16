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
turbine_specification.maximum_blade_chord_length = 0; % meters
turbine_specification.axial_induction = 0.25; % meters

% Static bird parameters
bird_specification.wingspan = 1;
bird_specification.length = 2;

% Simulation specific wind parameters
wind_specification.direction_degrees = 45; % degrees clockwise from north
wind_specification.speed = 10; %m/s

% Bird path parameters
bird_path_specification.direction_degrees = 90; % degrees clockwise from north
bird_path_specification.height = 43; % meters
bird_path_specification.speed = 15; % m/s
bird_path_specification.intercept.x = -90;
bird_path_specification.intercept.y = -80;

% FIXME. This should be determined from the wind speed.
turbine_angular_velocity = 2; % RPM


[turbine_intercepts, ...
  tower_intercepts] = FindWindFarmIntersects(windfarm_specification, ...
                                             turbine_specification, ...
                                             bird_path_specification, ...
                                             bird_specification, ...
                                             wind_specification);

plot_type = 2;
model_type = 0;
resolution = 3;
collision_probabilities = nan(1,length(turbine_intercepts));
for iIntercept = 1:length(turbine_intercepts)
    y_dim = turbine_intercepts(iIntercept).y;
    z_dim = turbine_intercepts(iIntercept).z;
    [collision_probability ...
     angle_of_orientation_degrees ...
     mean_probability ...
     mean_aperture_probability] = TurbineCollision(bird_specification.wingspan, ... %Meters
                                                   bird_specification.length, ... %Meters
                                                   turbine_specification.n_blades, ...
                                                   turbine_specification.turbine_radius, ... %Meters
                                                   turbine_specification.hub_radius, ... %Meters
                                                   turbine_angular_velocity, ... %RPMs
                                                   turbine_specification.maximum_blade_chord_length, ... %Meters
                                                   turbine_specification.axial_induction, ...
                                                   wind_specification.speed, ... %Meters/Second
                                                   wind_specification.direction_degrees, ... %Degrees clockwise from 12:00
                                                   bird_path_specification.speed, ... %Meters/Second, relative to ground
                                                   bird_path_specification.direction_degrees, ... %Degrees clockwise from 12:00 of the flightpath
                                                   plot_type, ... %0:no_plot, 1:turbine, 2:bird
                                                   resolution, ... %Pixels/Meter
                                                   model_type, ...
                                                   y_dim, ... %Meters
                                                   z_dim); %Meters

    assert(length(collision_probability) == 1);
    collision_probabilities(iIntercept) = collision_probability;

end

cumulative_collision_probability = 0;
for iCollisionProbability = 1:length(collision_probabilities)
    cumulative_collision_probability = cumulative_collision_probability + (1 - cumulative_collision_probability) .* collision_probabilities(iCollisionProbability);
end
cumulative_collision_probability