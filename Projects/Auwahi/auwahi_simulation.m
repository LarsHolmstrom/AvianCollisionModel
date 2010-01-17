
% clear variables
% close all
% 
% timeOfYear = 'spring';
% turbineType = 'ge';
% timeOfDay = 'morning';
% typeOfBird = 'petrel';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulation settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot_stuff = ~true;
% n_simulations = 100000;
% figure_handle = nan;
% 
% rotor_avoidance_rates = [0.9 0.95 0.99];
% tower_avoidance_rate = 0.99;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load the auwahi constants
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
auwahi_constants

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create the variable PDFs from the survey and site data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[bird_speed_pdf ...
 bird_direction_pdf ...
 wind_pdf ...
 bird_height_pdf] = ...
 GeneratePDFs(timeOfYear, turbineType, timeOfDay);

switch typeOfBird
    case 'petrel'
        bird_specification.wingspan = 0.91;
        bird_specification.length = 0.43;
    case 'shearwater'
        bird_specification.wingspan = 0.84;
        bird_specification.length = 0.33;
    otherwise
        error('Bad bird type specified');
end
        
tic
all_collision_probabilities = nan(n_simulations,length(rotor_avoidance_rates));

wind_directions = nan(1,n_simulations);
wind_speeds = nan(1,n_simulations);
bird_directions = nan(1,n_simulations);
bird_heights = nan(1,n_simulations);
bird_speeds = nan(1,n_simulations);

for i_sim = 1:n_simulations
    if mod(i_sim,1000) == 0
        display(i_sim);
    end
    % Simulation wind parameters
    [wind_direction wind_speed] = DrawFromPDF2(wind_pdf);
    wind_specification.direction_degrees = mod(wind_direction+180,360);
    wind_specification.speed = wind_speed;
    
    turbine_angular_velocity = 0;
    if (wind_speed > turbine_specification.cut_in_wind_speed && ...
        wind_speed < turbine_specification.cut_out_wind_speed)
        fraction_of_operational_range = ...
            (wind_speed - turbine_specification.cut_in_wind_speed) / ...
            (turbine_specification.cut_out_wind_speed - turbine_specification.cut_in_wind_speed);
        turbine_angular_velocity = ...
            turbine_specification.min_rpm + ...
            (turbine_specification.max_rpm - turbine_specification.min_rpm) * ...
            fraction_of_operational_range;
    end
    % Simulation bird path parameters
    bird_path_specification.direction_degrees = mod(DrawFromPDF(bird_direction_pdf.pdf,bird_direction_pdf.intervals)+180,360);
    bird_path_specification.height = DrawFromPDF(bird_height_pdf.pdf,bird_height_pdf.intervals);
    bird_path_specification.speed = DrawFromPDF(bird_speed_pdf.pdf,bird_speed_pdf.intervals);

    % Store for validation
    wind_directions(i_sim) = wind_specification.direction_degrees;
    wind_speeds(i_sim) = wind_specification.speed;
    bird_directions(i_sim) = bird_path_specification.direction_degrees;
    bird_heights(i_sim) = bird_path_specification.height;
    bird_speeds(i_sim) = bird_path_specification.speed;
    
    % Pick bird paths that pass through the wind farm area
    intercept_found = false;
    while ~intercept_found
        intercept_x = rand(1)*(max(bounding_polygon_x) - min(bounding_polygon_x)) + min(bounding_polygon_x);
        intercept_y = rand(1)*(max(bounding_polygon_y) - min(bounding_polygon_y)) + min(bounding_polygon_y);
        [in on] = inpolygon(intercept_x, intercept_y, bounding_polygon_x, bounding_polygon_y);
        if in || on
            intercept_found = true;
        end
    end
    
    bird_path_specification.intercept.x = intercept_x;
    bird_path_specification.intercept.y = intercept_y;

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
                                             'plot_stuff',plot_stuff);

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
                                                       turbine_specification.blade_chord_length_at_hub, ... %Meters
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
        if collision_probability < 0
            foo = 1;
        end
        collision_probabilities(iIntercept) = collision_probability;

    end
    
    collision_probabilities = collision_probabilities(~isnan(collision_probabilities));
    
    if length(collision_probabilities) > 1
        foo = 1;
    end
    if length(tower_intercepts) > 1
        foo = 1;
    end
    
    cumulative_collision_probability = zeros(1,length(rotor_avoidance_rates));
    if ~isempty(collision_probabilities)
        for iCollisionProbability = 1:length(collision_probabilities)
            cumulative_collision_probability = cumulative_collision_probability + (1 - cumulative_collision_probability) * collision_probabilities(iCollisionProbability) .* (1-rotor_avoidance_rates);
        end
    end
    if ~isempty(tower_intercepts)
        for iTowerIntercept = 1:length(tower_intercepts)
            cumulative_collision_probability = cumulative_collision_probability + (1 - cumulative_collision_probability) * (1 - tower_avoidance_rate);
        end
    end
    
    all_collision_probabilities(i_sim,:) = cumulative_collision_probability;
end
toc
mean_collision_probabilities = nanmean(all_collision_probabilities)
bad_configurations = sum(isnan(all_collision_probabilities(:,1)))

non_zero_probabilities = all_collision_probabilities(find(all_collision_probabilities(:,3) > 0));

if plot_stuff
    hold on
    fh = fill(bounding_polygon_x, bounding_polygon_y, 'r');
    dockf
    set(fh(1),'EdgeAlpha',0,'FaceAlpha',0.3);
end
