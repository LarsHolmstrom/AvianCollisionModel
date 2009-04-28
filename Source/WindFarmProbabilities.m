function [windFarmProbabilities ...
          x_ticks ...
          y_ticks] = WindFarmProbabilities(wingspan, ...
                                           bird_length, ...
                                           n_rotors, ...
                                           turbine_radius, ...
                                           hub_radius, ...
                                           angular_velocity, ...
                                           maximum_blade_chord_length, ... %Meters
                                           induction, ...
                                           wind_speed, ...
                                           wind_direction, ... %Degrees clockwise from 12:00
                                           bird_speed, ...
                                           bird_direction, ... %Degrees clockwise from 12:00 of the flightpath
                                           turbine_locations_x, ...
                                           turbine_locations_y, ...
                                           tower_height, ...
                                           tower_base_diameter, ...
                                           tower_top_diameter, ...
                                           resolution, ...
                                           model_type, ...
                                           turbine_enabled, ...
                                           plot_flag)

if turbine_enabled
    [oblique_probabilities ...
     angle_of_orientation_degrees ] = TurbineCollision(wingspan, ...
                                                       bird_length, ...
                                                       n_rotors, ...
                                                       turbine_radius, ...
                                                       hub_radius, ...
                                                       angular_velocity, ...
                                                       maximum_blade_chord_length, ... %Meters.
                                                       induction, ...
                                                       wind_speed, ...
                                                       wind_direction, ...
                                                       bird_speed, ...
                                                       bird_direction, ...
                                                       1, ...
                                                       resolution, ...
                                                       model_type);
else
    angle_of_orientation_degrees = BirdOrientation(bird_direction, ...
                                                   bird_speed, ...
                                                   wind_direction, ...
                                                   wind_speed, ...
                                                   0);
    turbine_radius = 0;
end
                                            

tower_probabilities = TowerCollision(wingspan, ...
                                     tower_height, ...
                                     tower_base_diameter, ...
                                     tower_top_diameter, ...
                                     resolution);


view_direction = bird_direction; %Degrees clockwise from 12 o'clocks
%Convert to degrees counterclockwise from 3:00 (trigonometric orientation)
bird_orientation = (90 - angle_of_orientation_degrees) / 360 * (2*pi); % Radians counterclockwise from 3:00
wind_direction = (90 - wind_direction) / 360 * (2*pi); % Radians counterclockwise from 3:00
view_direction = (90 - view_direction) / 360 * (2*pi); % Radians counterclockwise from 3:00
num_towers = length(turbine_locations_x);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
turbine_radius = max([turbine_radius ...
                     tower_base_diameter/2 ...
                     tower_top_diameter/2]);
left_rotor_tip_x = -turbine_radius * sin(wind_direction);
left_rotor_tip_y = turbine_radius * cos(wind_direction);
right_rotor_tip_x = -left_rotor_tip_x;
right_rotor_tip_y = -left_rotor_tip_y;

% left_tower_x = -tower_widest_diameter - wingspan/2;
% left_tower_y = tower_height;
% right_tower_x = -left_tower_x;
% right_tower_y = tower_height;

left_rotor_tips_x = turbine_locations_x + left_rotor_tip_x;
left_rotor_tips_y = turbine_locations_y + left_rotor_tip_y;
right_rotor_tips_x = turbine_locations_x + right_rotor_tip_x;
right_rotor_tips_y = turbine_locations_y + right_rotor_tip_y;

minx = min([left_rotor_tips_x ; right_rotor_tips_x]);
maxx = max([left_rotor_tips_x ; right_rotor_tips_x]);
miny = min([left_rotor_tips_y ; right_rotor_tips_y]);
maxy = max([left_rotor_tips_y ; right_rotor_tips_y]);
x_plot_boundary = (maxx-minx)*0.1;
y_plot_boundary = (maxy-miny)*0.1;
% xlim([minx-x_plot_boundary maxx+x_plot_boundary]);
% ylim([miny-y_plot_boundary maxy+y_plot_boundary]);
x_min_boundary = minx-x_plot_boundary;
x_max_boundary = maxx+x_plot_boundary;
y_min_boundary = miny-y_plot_boundary;
y_max_boundary = maxy+y_plot_boundary;

    % Plot out the windfarm overlayed over a ground image.
    figure
    % Load saved image of the ground.
    load('ground_image.mat');
    image(linspace(x_min_boundary,x_max_boundary,100), ...
          linspace(y_min_boundary,y_max_boundary,100), ...
          img);
    set(gca,'YDir','normal');
    hold on
    if turbine_enabled
        for tower_num = 1:num_towers
            h = plot([left_rotor_tips_x(tower_num) right_rotor_tips_x(tower_num)],[left_rotor_tips_y(tower_num) right_rotor_tips_y(tower_num)],'b');
            set(h,'lineWidth',2);
        end
    end
    h = plot(turbine_locations_x,turbine_locations_y,'r.');
    set(h,'MarkerSize',20);
    axis equal
    title('Windfarm Layout and Dimensions');
    xlim([x_min_boundary x_max_boundary]);
    ylim([y_min_boundary y_max_boundary]);
    xlabel('Meters');
    ylabel('Meters');

    % Plot out The compass asnd directions.
    % x_size = x_max_boundary - x_min_boundary;
    % y_size = y_max_boundary - y_min_boundary;
    figure;
    circumference = linspace(0,2*pi,200);
    R = 1;
    hold on;
    h = plot([0 cos(wind_direction)],[0 sin(wind_direction)],'b');
    h = plot([0 cos(view_direction)],[0 sin(view_direction)],'r');
    h = plot([0 cos(bird_orientation)],[0 sin(bird_orientation)],'g');
    h = plot(R*cos(circumference),R*sin(circumference),'k');
    legend('Wind Direction','Flight Path','Bird Orientation');
    xlim([-1.5 1.5]);
    ylim([-1.5 1.5]);
    axis equal
    text(0,1.1, ...
        'N',...
        'VerticalAlignment','middle',...
        'HorizontalAlignment','center',...
        'FontSize',14);
    text(1.1,0, ...
        'E',...
        'VerticalAlignment','middle',...
        'HorizontalAlignment','center',...
        'FontSize',14);
    text(0,-1.1, ...
        'S',...
        'VerticalAlignment','middle',...
        'HorizontalAlignment','center',...
        'FontSize',14);
    text(-1.1,0, ...
        'W',...
        'VerticalAlignment','middle',...
        'HorizontalAlignment','center',...
        'FontSize',14);
    title('Compass');
    

%--------------------------------------------------
rotation = pi/2 - view_direction;
[rotated_turbine_locations_x rotated_turbine_locations_y] = ...
 TransformCoordinates(turbine_locations_x, turbine_locations_y, rotation);
[rotated_left_rotor_tips_x rotated_left_rotor_tips_y] = ...
 TransformCoordinates(left_rotor_tips_x, left_rotor_tips_y, rotation);
[rotated_right_rotor_tips_x rotated_right_rotor_tips_y] = ...
 TransformCoordinates(right_rotor_tips_x, right_rotor_tips_y, rotation);

% figure
% plot(rotated_turbine_locations_x,rotated_turbine_locations_y,'r.')
% hold on
% for tower_num = 1:num_towers
%     plot([rotated_left_rotor_tips_x(tower_num) rotated_right_rotor_tips_x(tower_num)],[rotated_left_rotor_tips_y(tower_num) rotated_right_rotor_tips_y(tower_num)],'b');
% end
minx = min([rotated_left_rotor_tips_x ; rotated_right_rotor_tips_x]);
maxx = max([rotated_left_rotor_tips_x ; rotated_right_rotor_tips_x]);
miny = min([rotated_left_rotor_tips_y ; rotated_right_rotor_tips_y]);
maxy = max([rotated_left_rotor_tips_y ; rotated_right_rotor_tips_y]);
% x_plot_boundary = (maxx-minx)*0.1;
% y_plot_boundary = (maxy-miny)*0.1;
% xlim([minx-x_plot_boundary maxx+x_plot_boundary]);
% ylim([miny-y_plot_boundary maxy+y_plot_boundary]);

%--------------------------------------------------

minx = min(rotated_turbine_locations_x) - turbine_radius; %In meters
maxx = max(rotated_turbine_locations_x) + turbine_radius; %In meters
minz = 0; %In meters
maxz = turbine_radius + tower_height; %In meters
num_x_pixels = ceil((maxx - minx) * resolution); %In pixels
num_z_pixels = ceil((maxz - minz) * resolution); %In pixels

canvas = zeros(num_z_pixels,num_x_pixels);

for tower_num = 1:num_towers
    temp_canvas = zeros(num_z_pixels,num_x_pixels);
    %The pixel, in the x direction, of the center of the tower
    center = round((rotated_turbine_locations_x(tower_num) - minx) * resolution);
    if turbine_enabled
        turbine_x_idx = (1:size(oblique_probabilities,2)) + center - round(size(oblique_probabilities,2)/2);
        if min(turbine_x_idx) < 1
            %If pixels get rounded to be 0 or less, add one.
            turbine_x_idx = turbine_x_idx - min(turbine_x_idx) + 1;
        end
        % The canvas is flipped upside down to ease indexing
        turbine_z_idx = num_z_pixels-size(oblique_probabilities,1)+1:num_z_pixels;
        temp_canvas(turbine_z_idx,turbine_x_idx) = oblique_probabilities;
    end
    
    tower_x_idx = (1:size(tower_probabilities,2)) + center - round(size(tower_probabilities,2)/2);
    if min(tower_x_idx) < 1
        %If pixels get rounded to be 0 or less, add one.
        tower_x_idx = tower_x_idx - min(tower_x_idx) + 1;
    end
    tower_z_idx = 1:size(tower_probabilities,1);
    temp_canvas(tower_z_idx,tower_x_idx) = min(temp_canvas(tower_z_idx,tower_x_idx) + tower_probabilities,1);
    
    if size(canvas,1) < size(temp_canvas,1)
        num_z_pixels = size(temp_canvas,1);
        new_canvas = zeros(num_z_pixels,num_x_pixels);
        new_canvas(1:size(canvas,1),:) = canvas;
        canvas = new_canvas;
    end
    if size(canvas,2) < size(temp_canvas,2)
        num_x_pixels = size(temp_canvas,2);
        new_canvas = zeros(num_z_pixels,num_x_pixels);
        new_canvas(:,1:size(canvas,2)) = canvas;
        canvas = new_canvas;
    end
    correction = (1 - canvas) .* temp_canvas;
    canvas = canvas + correction;
end

windFarmProbabilities = canvas;
x_ticks = linspace(minx,maxx,size(canvas,2));
y_ticks = linspace(0,turbine_radius+tower_height,size(canvas,1));

if plot_flag
    figure;
    imagesc(x_ticks,y_ticks,canvas);
    set(gca,'YDir','normal');
    caxis([0 1]);
    colorbar
    axis image
    title('Wind Farm Collision Probabilities');
    xlabel('Meters');
    ylabel('Meters');
end


