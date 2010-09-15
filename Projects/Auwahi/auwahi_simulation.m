function all_collision_probabilities = auwahi_simulation(turbineType, ...
                                                         timeOfYear, ...
                                                         timeOfDay, ...
                                                         typeOfBird, ...
                                                         use_ge_configuration_only, ...
                                                         n_simulations, ...
                                                         rotor_avoidance_rates, ...
                                                         tower_avoidance_rate, ...
                                                         figure_handle, ...
                                                         plot_stuff)




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulation settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% timeOfYear = 'spring';
% turbineType = 'ge';
% timeOfDay = 'morning';
% typeOfBird = 'petrel';
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
load RotorWindRelationship
switch turbineType
    case 'ge'
        windRotorData = RotorWindRelationship{1};
    case 'siemans23'
        windRotorData = RotorWindRelationship{2};
    case 'siemans30'
        windRotorData = RotorWindRelationship{2};
    case 'vestas'
        windRotorData = RotorWindRelationship{3};
end
turbine_data_wind_speed = windRotorData(:,1);
turbine_data_rotor_speed = windRotorData(:,2);
turbine_data_rotor_pitch = windRotorData(:,3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create the variable PDFs from the survey and site data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[bird_speed_pdf ...
 bird_direction_pdf ...
 slow_wind_speed_pdf ...
 fast_wind_speed_pdf ...
 bird_height_pdf] = GeneratePDFs(timeOfYear, turbineType, timeOfDay);

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

bad_configurations = 0;

for i_sim = 1:n_simulations
    if mod(i_sim,1000) == 0
        display(i_sim);
    end
    % Simulation wind parameters
    [wind_speed wind_direction] = GetWindSample(slow_wind_speed_pdf, fast_wind_speed_pdf);
    wind_specification.direction_degrees = wind_direction;
    %     wind_specification.direction_degrees = mod(wind_direction+180,360);
    wind_specification.speed = wind_speed;
    
    % Do linear interpolation of the rotor speed vs wind speed curve
    if wind_speed > max(turbine_data_wind_speed)
        turbine_angular_velocity = turbine_data_rotor_speed(end);
        rotor_pitch = turbine_data_rotor_pitch(end);
    else
        turbine_angular_velocity = interp1(turbine_data_wind_speed,turbine_data_rotor_speed,wind_speed);
        rotor_pitch = interp1(turbine_data_wind_speed,turbine_data_rotor_pitch,wind_speed);
    end
    
    % Simulation bird path parameters
bird_path_specification.direction_degrees = mod(DrawFromPDF(bird_direction_pdf.pdf,bird_direction_pdf.intervals)+180,360);
%     bird_path_specification.direction_degrees = DrawFromPDF(bird_direction_pdf.pdf,bird_direction_pdf.intervals);
    bird_path_specification.height = DrawFromPDF(bird_height_pdf.pdf,bird_height_pdf.intervals);
    bird_path_specification.speed = DrawFromPDF(bird_speed_pdf.pdf,bird_speed_pdf.intervals);
    
    % Store for validation
    wind_directions(i_sim) = wind_specification.direction_degrees;
    wind_speeds(i_sim) = wind_specification.speed;
    bird_directions(i_sim) = bird_path_specification.direction_degrees;
    bird_heights(i_sim) = bird_path_specification.height;
    bird_speeds(i_sim) = bird_path_specification.speed;
    
    %         %-------------------------------------------------------------------
    %         % Check to make sure that the flight path is reasonable
    %         %-------------------------------------------------------------------
    %         [angle_of_orientation_degrees ...
    %          bird_downwind_relative_direction_radians ...
    %          Vbx ...
    %          Vby ...
    %          Vx] = BirdOrientation(bird_path_specification.direction_degrees, ...
    %                                bird_path_specification.speed, ...
    %                                wind_specification.direction_degrees, ...
    %                                wind_specification.speed, ...
    %                                0)
    %
    %         %Convert theta to radians
    %         theta = angle_of_orientation_degrees/360*2*pi;
    %
    %         upwind = false;
    %         if (Vx < 0)
    %             theta
    %             assert(abs(theta) >= pi/2); % Flying backwards
    %             Vx = abs(Vx);
    %             %     theta = mod(theta+pi,pi);
    %             theta = -(theta-pi);
    %             upwind = true;
    %         else
    %             assert(abs(theta) < pi/2);
    %         end
    %         if abs(theta) < pi/2
    %             break;
    %         else
    %             bad_configurations = bad_configurations + 1;
    %         end
    %     end
    %-------------------------------------------------------------------
    
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
    
%     testSiemensPassageRate
%     contained(i_sim) = intercept_found_test;
    
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
                                                       z_dim, ...  %Meters
                                                       rotor_pitch); %Degrees
        
        assert(length(collision_probability) == 1);
        if collision_probability < 0
            foo = 1;
        end
        collision_probabilities(iIntercept) = collision_probability;
        
    end
    
    bad_configurations = bad_configurations + sum(isnan(collision_probabilities));
    if (sum(isnan(collision_probabilities)) > 0)
        foo = 1;
    else
        
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
end
toc
mean_collision_probabilities = nanmean(all_collision_probabilities)
bad_configurations

non_zero_probabilities = all_collision_probabilities(find(all_collision_probabilities(:,3) > 0));

if plot_stuff
    hold on
    fh = fill(bounding_polygon_x, bounding_polygon_y, 'r');
    dockf
    set(fh(1),'EdgeAlpha',0,'FaceAlpha',0.3);
    PrintFigure('simulationExample','png',6.6)
end
