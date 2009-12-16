
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load the auwahi constants
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
auwahi_constants


n_simulations = 10000;

figure_handle = nan;

tic
all_collision_probabilities = nan(1,n_simulations);
for i_sim = 1:n_simulations
    % Simulation specific wind parameters
    wind_specification.direction_degrees = norminv(rand(1,1),wind_direction_degrees_mean,wind_direction_degrees_stdev); % degrees clockwise from north
    wind_specification.speed = norminv(rand(1,1),wind_speed_mean,wind_speed_stdev); %m/s

    % Bird path parameters
    bird_path_specification.direction_degrees = norminv(rand(1,1),bird_path_direction_degrees_mean,bird_path_direction_degrees_stdev); % degrees clockwise from north
    bird_path_specification.height = norminv(rand(1,1),bird_path_height_mean,bird_path_height_stdev); % meters
    bird_path_specification.speed = norminv(rand(1,1),bird_speed_mean,bird_speed_stdev); % m/s
    
    bird_path_radius_intercept = rand(1)*survey_radius;
    bird_path_angle_intercepts = rand(1)*2*pi;
    bird_path_specification.intercept.x = survey_radius + cos(bird_path_angle_intercepts) * bird_path_radius_intercept;
    bird_path_specification.intercept.y = survey_radius + sin(bird_path_angle_intercepts) * bird_path_radius_intercept;

    % FIXME. This should be determined from the wind speed.
    turbine_angular_velocity = 2; % RPM

    [turbine_intercepts, ...
     tower_intercepts, ...
     figure_handle] = FindWindFarmIntersects(windfarm_specification, ...
                                             turbine_specification, ...
                                             bird_path_specification, ...
                                             bird_specification, ...
                                             wind_specification, ...
                                             'image_file','Map_Cropped.mat', ...
                                             'x_min', 0, ...
                                             'y_min', 0, ...
                                             'x_max', 3000, ...
                                             'y_max', 3000, ...
                                             'figure_handle',figure_handle, ...
                                             'plot_stuff',false);

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
    
    collision_probabilities = collision_probabilities(~isnan(collision_probabilities));
    
    if ~isempty(collision_probabilities)
        cumulative_collision_probability = 0;
        for iCollisionProbability = 1:length(collision_probabilities)
            cumulative_collision_probability = cumulative_collision_probability + (1 - cumulative_collision_probability) .* collision_probabilities(iCollisionProbability);
        end
        all_collision_probabilities(i_sim) = cumulative_collision_probability;
    end
        
end
toc
nanmean(all_collision_probabilities)
bad_configurations = sum(isnan(all_collision_probabilities))
