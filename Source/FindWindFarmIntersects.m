function [turbine_intercepts, ...
          tower_intercepts] = FindWindFarmIntersects(windfarm_specification, ...
                                                     turbine_specification, ...
                                                     bird_path_specifications, ...
                                                     wind_direction_degrees, ...
                                                     wind_speed)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do necessary conversions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axial_induction = 0.25;
[angle_of_orientation_degrees ...
 bird_downwind_relative_direction_radians ...
 Vbx ...
 Vby ...
 Vx] = BirdOrientation(bird_path_specifications.direction, ...
                       bird_path_specifications.speed, ...
                       wind_direction_degrees, ...
                       wind_speed, ...
                       axial_induction);
                   
wind_direction_radians = (90 - mod(wind_direction_degrees,360)) / 360 * (2*pi); % Radians counterclockwise from 3:00
bird_path_directions_radians = (90 - mod(bird_path_specifications.direction,360)) / 360 * (2*pi); % Radians counterclockwise from 3:00
angle_of_orientation_radians = (90 - mod(angle_of_orientation_degrees,360)) / 360 * (2*pi); % Radians counterclockwise from 3:00

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determine the path of the bird
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
path_slope = tan(bird_path_directions_radians);
bird_y_intercept = bird_path_specifications.intercept.y - path_slope*bird_path_specifications.intercept.x;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determine the plot ranges for the wind farm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

turbine_radius = max([turbine_specification.turbine_radius ...
                      turbine_specification.tower_base_diameter/2 ...
                      turbine_specification.tower_top_diameter/2]);
                 
left_rotor_tip_x = -turbine_radius * sin(wind_direction_radians);
left_rotor_tip_y = turbine_radius * cos(wind_direction_radians);
right_rotor_tip_x = -left_rotor_tip_x;
right_rotor_tip_y = -left_rotor_tip_y;

turbine_locations_x = [windfarm_specification.tower_locations.x];
turbine_locations_y = [windfarm_specification.tower_locations.y];

num_towers = length(turbine_locations_x);

left_rotor_tips_x = turbine_locations_x + left_rotor_tip_x;
left_rotor_tips_y = turbine_locations_y + left_rotor_tip_y;
right_rotor_tips_x = turbine_locations_x + right_rotor_tip_x;
right_rotor_tips_y = turbine_locations_y + right_rotor_tip_y;

minx = min([left_rotor_tips_x  right_rotor_tips_x]);
maxx = max([left_rotor_tips_x  right_rotor_tips_x]);
miny = min([left_rotor_tips_y  right_rotor_tips_y]);
maxy = max([left_rotor_tips_y  right_rotor_tips_y]);
x_plot_boundary = (maxx-minx)*0.1;
y_plot_boundary = (maxy-miny)*0.1;

x_min_boundary = minx-x_plot_boundary;
x_max_boundary = maxx+x_plot_boundary;
y_min_boundary = miny-y_plot_boundary;
y_max_boundary = maxy+y_plot_boundary*5; %Leave room for the compass

x_range = x_max_boundary-x_min_boundary;
y_range = y_max_boundary-y_min_boundary;

if x_range > y_range
    mid_y = mean([y_max_boundary y_min_boundary]);
    y_max_boundary = mid_y + x_range/2;
    y_min_boundary = mid_y - x_range/2;
elseif y_range > x_range
    mid_x = mean([x_max_boundary x_min_boundary]);
    x_max_boundary = mid_x + y_range/2;
    x_min_boundary = mid_x - y_range/2;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find where the bird path intercepts the plane of
% each turbine to check for possible collisions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rotor_plane_slope = tan(wind_direction_radians + pi/2);
rotor_width_at_bird_height = 0;
bird_height = bird_path_specifications.height;
tower_height = turbine_specification.tower_height;
turbine_radius = turbine_specification.turbine_radius;

path_vertical_distance_from_hub = bird_height - tower_height; % This is positive if the bird is above the turbine

if path_vertical_distance_from_hub < 0
    ratio_to_top_of_tower = bird_height/tower_height;
    % Bird is below tower height
    width_of_tower_at_bird_height = turbine_specification.tower_base_diameter - ...
                                    (turbine_specification.tower_base_diameter - turbine_specification.tower_top_diameter) * ...
                                    ratio_to_top_of_tower;
end

if abs(path_vertical_distance_from_hub) < turbine_radius
    % Bird is not above or below the turbine blades
    % Calculate the arc-width of the rotor plane at this height
    rotor_width_at_bird_height = sqrt(turbine_radius^2 - path_vertical_distance_from_hub^2);
end
    
rotor_bird_intercepts_for_plot_x = [];
rotor_bird_intercepts_for_plot_y = [];
tower_bird_intercepts_for_plot_x = [];
tower_bird_intercepts_for_plot_y = [];
% rotor_bird_intercepts_for_collision_calculation_z = [];
% rotor_bird_intercepts_for_collision_calculation_y = [];
nTowerIntercepts = 0;
nRotorIntercepts = 0;

turbine_intercepts = [];
tower_intercepts = [];
for iTurbine = 1:num_towers
    % Iterate through each flight path to check for an intersection
    turbine_y_intercept = turbine_locations_y(iTurbine) - rotor_plane_slope*turbine_locations_x(iTurbine);
    rotorplane_bird_intercept = [1, -path_slope ; 1, -rotor_plane_slope] \ [bird_y_intercept ; turbine_y_intercept];
    horizontal_distance_from_turbine = sqrt((rotorplane_bird_intercept(2) - turbine_locations_x(iTurbine))^2 + (rotorplane_bird_intercept(1) - turbine_locations_y(iTurbine))^2);
    
    if path_vertical_distance_from_hub < 0 && horizontal_distance_from_turbine <= width_of_tower_at_bird_height
        nTowerIntercepts = nTowerIntercepts + 1;
        tower_bird_intercepts_for_plot_x = [tower_bird_intercepts_for_plot_x rotorplane_bird_intercept(2)];
        tower_bird_intercepts_for_plot_y = [tower_bird_intercepts_for_plot_y rotorplane_bird_intercept(1)];
        
        tower_intercepts(nTowerIntercepts).x = turbine_locations_x(iTurbine);
        tower_intercepts(nTowerIntercepts).y = turbine_locations_y(iTurbine);
    elseif horizontal_distance_from_turbine <= rotor_width_at_bird_height
        nRotorIntercepts = nRotorIntercepts + 1;
        rotor_bird_intercepts_for_plot_x = [rotor_bird_intercepts_for_plot_x rotorplane_bird_intercept(2)];
        rotor_bird_intercepts_for_plot_y = [rotor_bird_intercepts_for_plot_y rotorplane_bird_intercept(1)];
        
        
        % Kind of ugly, but this code determines whether the bird intercepts
        % the rotor plane 'left' or 'right' of the tower, from the bird's perspective
        collision_location_string = '';
        if rotorplane_bird_intercept(2) < turbine_locations_x(iTurbine)
            collision_location_string = [collision_location_string 'w']; %Collision is west of tower
        end
        if rotorplane_bird_intercept(2) > turbine_locations_x(iTurbine)
            collision_location_string = [collision_location_string 'e']; %Collision is ease of tower
        end
        if rotorplane_bird_intercept(1) > turbine_locations_y(iTurbine)
            collision_location_string = [collision_location_string 'n']; %Collision is north of tower
        end
        if rotorplane_bird_intercept(1) < turbine_locations_y(iTurbine)
            collision_location_string = [collision_location_string 's']; %Collision is south of tower
        end
        
        y_coordinate_multiplier = 1;
        if bird_path_directions_radians > 0 && bird_path_directions_radians < pi
            % Bird is flying north
            if strfind(collision_location_string,'w')
                y_coordinate_multiplier = -1;
            end
        elseif bird_path_directions_radians > pi && bird_path_directions_radians < 2*pi
            % Bird is flying south
            if strfind(collision_location_string,'e')
                y_coordinate_multiplier = -1;
            end
        elseif bird_path_directions_radians > pi/2 && bird_path_directions_radians < 3/2*pi
            % Bird is flying west
            if strfind(collision_location_string,'s')
                y_coordinate_multiplier = -1;
            end
        elseif bird_path_directions_radians < pi/2 || bird_path_directions_radians > 3/2*pi
            % Bird is flying east
            if strfind(collision_location_string,'n')
                y_coordinate_multiplier = -1;
            end
        end
            
        turbine_intercepts(nRotorIntercepts).z = path_vertical_distance_from_hub;
        turbine_intercepts(nRotorIntercepts).y = y_coordinate_multiplier*horizontal_distance_from_turbine;
        
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot stuff
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot out the windfarm overlayed over a ground image.
figure
% Load saved image of the ground.
load('ground_image.mat');
image(linspace(x_min_boundary,x_max_boundary,100), ...
      linspace(y_min_boundary,y_max_boundary,100), ...
      img);
set(gca,'YDir','normal');
hold on

% Plot the turbine blades
for tower_num = 1:num_towers
    h = plot([left_rotor_tips_x(tower_num) right_rotor_tips_x(tower_num)],[left_rotor_tips_y(tower_num) right_rotor_tips_y(tower_num)],'b');
    set(h,'lineWidth',2);
end
    
% Plot the turbine towers
h = plot(turbine_locations_x,turbine_locations_y,'r.');
set(h,'MarkerSize',20);

% Plot the bird path
plot([x_min_boundary x_max_boundary],[path_slope*x_min_boundary+bird_y_intercept path_slope*x_max_boundary+bird_y_intercept],'g');

% Plot the bird/rotor intercepts
h = plot(rotor_bird_intercepts_for_plot_x, rotor_bird_intercepts_for_plot_y, 'g*');
set(h,'MarkerSize',10);

% Plot the bird/tower intercepts
h = plot(tower_bird_intercepts_for_plot_x, tower_bird_intercepts_for_plot_y, 'r*');
set(h,'MarkerSize',10);

axis equal
title('Windfarm Layout and Dimensions');
xlim([x_min_boundary x_max_boundary]);
ylim([y_min_boundary y_max_boundary]);
xlabel('Meters');
ylabel('Meters');

compassPlotHandle = axes('Position',[.2 .7 .2 .2],'Visible','off');
set(compassPlotHandle,'xtick',[],'ytick',[])

% Plot the compass
circumference = linspace(0,2*pi,200);
R = 1;
hold on;
h = plot([0 cos(wind_direction_radians)],[0 sin(wind_direction_radians)],'w','lineWidth',2);
h = plot([0 cos(bird_path_directions_radians)],[0 sin(bird_path_directions_radians)],'g','lineWidth',2);
h = plot([0 cos(angle_of_orientation_radians)],[0 sin(angle_of_orientation_radians)],'k','lineWidth',2);
h = plot(R*cos(circumference),R*sin(circumference),'r','lineWidth',2);
hl = legend('Wind Direction','Flight Path','Bird Orientation','location','EastOutside');
set(hl,'FontSize',12,'FontWeight','bold');
% set(hl,'box','off');
xlim([-1.5 1.5]);
ylim([-1.5 1.5]);
axis equal
text(0,1.3, ...
    'N',...
    'VerticalAlignment','middle',...
    'HorizontalAlignment','center',...
    'FontSize',14,...
    'FontWeight','bold');
text(1.3,0, ...
    'E',...
    'VerticalAlignment','middle',...
    'HorizontalAlignment','center',...
    'FontSize',14,...
    'FontWeight','bold');
text(0,-1.4, ...
    'S',...
    'VerticalAlignment','middle',...
    'HorizontalAlignment','center',...
    'FontSize',14,...
    'FontWeight','bold');
text(-1.3,0, ...
    'W',...
    'VerticalAlignment','middle',...
    'HorizontalAlignment','center',...
    'FontSize',14,...
    'FontWeight','bold');