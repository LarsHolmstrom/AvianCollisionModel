
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determine Auahi map boundary coordinates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The center of the map, determined from google maps & the provided map of the tower configuration
center_of_map_lon = -156.3217515;
center_of_map_lat = 20.5958626;

% Manual determination of values that would approximate a 3km square centered at the point defined above
longitude_one_and_half_km = 0.014421;
latitude_one_and_half_km = 0.013500;

% The coordinates of the upper left corner and bottom right corner.
map_bound_top_left_lon = center_of_map_lon - longitude_one_and_half_km;
map_bound_top_left_lat = center_of_map_lat + latitude_one_and_half_km;
map_bound_bottom_right_lon = center_of_map_lon + longitude_one_and_half_km;
map_bound_bottom_right_lat = center_of_map_lat - latitude_one_and_half_km;

% These two values should be pretty close
LatitudeLongitudeDistance(map_bound_top_left_lat,map_bound_top_left_lon,map_bound_bottom_right_lat,map_bound_bottom_right_lon);
sqrt(3000^2 + 3000^2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create a Google Earth KML file with the bounding box in it
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
google_earth_box = ge_box(map_bound_top_left_lon,...
                          map_bound_bottom_right_lon,...
                          map_bound_top_left_lat,...
                          map_bound_bottom_right_lat,...
                          'lineWidth',5.0, ...
                          'lineColor','FFFF0000', ...
                          'polyColor','00FF0000');
kmlTargetDir = pwd;
kmlFileName = 'auwahi_ge_box.kml';

ge_output([kmlTargetDir '/' kmlFileName],google_earth_box,'name',kmlFileName);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load image generated in Google Earth using the above KML file and convert to .mat format
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[img,map] = imread('Map_Cropped.jpg');
for i = 1:3
    img(:,:,i) = flipud(img(:,:,i));
end
save Map_Cropped img

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determine the coordinates of the turbines, in meters, relative to the bottom left (0,0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GE_X = [778679 778664 778699 778707 778725 778767 778795 778857 779464 779481 779535 779560 779565 779574 779634 779463];
% GE_Y = [2280554 2280357 2280102 2279888 2279694 2279492 2279275 2279065 2280315 2280106 2279907 2279700 2279490 2279283 2279065 2280558];
% Siemens_X = [778767 778795 778857 779464 779481 779535 779560 779565 779574 779634 779463];
% Siemens_Y = [2279492 2279275 2279065 2280315 2280106 2279907 2279700 2279490 2279283 2279065 2280558];
GE_X = [778664 778699 778707 778725 778767 778795 778857 779463 779464 779481 779535 779560 779565 779574 779634];
GE_Y = [2280357 2280102 2279888 2279694 2279492 2279275 2279065 2280558 2280315 2280106 2279907 2279700 2279490 2279283 2279065];
Siemens23_X = [778795 778857 779463 779464 779481 779535 779560 779565 779574 779634];
Siemens23_Y = [2279275 2279065 2280558 2280315 2280106 2279907 2279700 2279490 2279283 2279065];
Siemens30_X = [779463 779464 779481 779535 779560 779565 779574 779634];
Siemens30_Y = [2280558 2280315 2280106 2279907 2279700 2279490 2279283 2279065];
UTM_Zone_GE = ['04 N'; '04 N'; '04 N'; '04 N'; '04 N'; '04 N'; '04 N'; '04 N'; '04 N'; '04 N'; '04 N'; '04 N'; '04 N'; '04 N'; '04 N'];
UTM_Zone_Siemens23 = ['04 N'; '04 N'; '04 N'; '04 N'; '04 N'; '04 N'; '04 N'; '04 N'; '04 N'; '04 N'];
UTM_Zone_Siemens30 = ['04 N'; '04 N'; '04 N'; '04 N'; '04 N'; '04 N'; '04 N'; '04 N'];

[GE_lat, GE_lon] = utm2deg(GE_X, GE_Y, UTM_Zone_GE);
[Siemens23_lat, Siemens23_lon] = utm2deg(Siemens23_X, Siemens23_Y, UTM_Zone_Siemens23);
[Siemens30_lat, Siemens30_lon] = utm2deg(Siemens30_X, Siemens30_Y, UTM_Zone_Siemens30);

for i=1:15
    GE_tower(i).lon = GE_lon(i);
    GE_tower(i).lat = GE_lat(i);
end

for i=1:10
    Siemens23_tower(i+5).lon = Siemens23_lon(i);
    Siemens23_tower(i+5).lat = Siemens23_lat(i);
end

for i=1:8
    Siemens30_tower(i+5).lon = Siemens30_lon(i);
    Siemens30_tower(i+5).lat = Siemens30_lat(i);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up the specification structures needed to drive the simulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Specify the tubine model. This also affects the wind farm layout
switch turbineType
    case 'ge' % GE 1.5 SE
        towers = GE_tower;
%         tower_layout = 1:15;
%         % GE 1.5 SE
%         % Static turbine specification
%         turbine_specification.tower_height = 64.7; % meters
%         turbine_specification.turbine_radius = 35.25; % meters
%         turbine_specification.hub_radius = 2; % meters
%         turbine_specification.tower_base_diameter = 3.5; % meters
%         turbine_specification.tower_top_diameter = 3.5; % meters
%         turbine_specification.n_blades = 3;
%         turbine_specification.maximum_blade_chord_length = 1.5; % meters
%         turbine_specification.blade_chord_length_at_hub = 0.8;
%         turbine_specification.axial_induction = 0.25; % meters
%         turbine_specification.cut_in_wind_speed = 4; %m/s
%         turbine_specification.cut_out_wind_speed = 25; %m/s
%         turbine_specification.min_rpm = 11.1; %rpms
%         turbine_specification.max_rpm = 22.2; %rpms
        
        % GE 1.5 xleWE
        % Static turbine specification
        turbine_specification.tower_height = 80; % meters
        turbine_specification.turbine_radius = 41.25; % meters
        turbine_specification.hub_radius = 1.8; % meters
        turbine_specification.tower_base_diameter = 4.3; % meters
        turbine_specification.tower_top_diameter = 4.3; % meters
        turbine_specification.n_blades = 3;
        turbine_specification.maximum_blade_chord_length = 3.2; % meters
        turbine_specification.blade_chord_length_at_hub = 1.9;
        turbine_specification.axial_induction = 0.25; % meters
        turbine_specification.cut_in_wind_speed = 3.5; %m/s
        turbine_specification.cut_out_wind_speed = 25; %m/s
        turbine_specification.min_rpm = 9; %rpms
        turbine_specification.max_rpm = 20; %rpms
    case 'siemans23' % Siemens SWT 2.3-101
        towers = Siemens23_tower;
%         tower_layout = 6:15;
        % Static turbine specification
        turbine_specification.tower_height = 80; % meters
        turbine_specification.turbine_radius = 50.5; % meters
        turbine_specification.hub_radius = 1.9; % meters
        turbine_specification.tower_base_diameter = 4.2; % meters
        turbine_specification.tower_top_diameter = 4.2; % meters
        turbine_specification.n_blades = 3;
        turbine_specification.maximum_blade_chord_length = 3.5; % meters
        turbine_specification.blade_chord_length_at_hub = 2.4;
        turbine_specification.axial_induction = 0.25; % meters
        turbine_specification.cut_in_wind_speed = 4; %m/s
        turbine_specification.cut_out_wind_speed = 25; %m/s
        turbine_specification.min_rpm = 6; %rpms
        turbine_specification.max_rpm = 16; %rpms
    case 'siemans30' % Siemens SWT 2.3-101
        towers = Siemens30_tower;
%         tower_layout = 6:15;
        % Static turbine specification
        turbine_specification.tower_height = 80; % meters
        turbine_specification.turbine_radius = 50.5; % meters
        turbine_specification.hub_radius = 1.9; % meters
        turbine_specification.tower_base_diameter = 4.2; % meters
        turbine_specification.tower_top_diameter = 4.2; % meters
        turbine_specification.n_blades = 3;
        turbine_specification.maximum_blade_chord_length = 3.5; % meters
        turbine_specification.blade_chord_length_at_hub = 2.4;
        turbine_specification.axial_induction = 0.25; % meters
        turbine_specification.cut_in_wind_speed = 4; %m/s
        turbine_specification.cut_out_wind_speed = 25; %m/s
        turbine_specification.min_rpm = 6; %rpms
        turbine_specification.max_rpm = 16; %rpms
    case 'vestas' % Vestas V90
        towers = Vestas_tower;
%         tower_layout = 8:15;
        % Static turbine specification
        turbine_specification.tower_height = 80; % meters
        turbine_specification.turbine_radius = 45; % meters
        turbine_specification.hub_radius = 2.02; % meters
        turbine_specification.tower_base_diameter = 3.65; % meters
        turbine_specification.tower_top_diameter = 3.65; % meters
        turbine_specification.n_blades = 3;
        turbine_specification.maximum_blade_chord_length = 3.512; % meters
        turbine_specification.blade_chord_length_at_hub = 1.88;
        turbine_specification.axial_induction = 0.25; % meters
        turbine_specification.cut_in_wind_speed = 4; %m/s
        turbine_specification.cut_out_wind_speed = 25; %m/s
        turbine_specification.min_rpm = 8.6; %rpms
        turbine_specification.max_rpm = 18.4; %rpms
    otherwise
        error('Bad turbine specification');
end

if use_ge_configuration_only % This is the same as the GE 1.5 SE configuration below
    tower_layout = 1:15;
end

% Add the 
% jTower = 0;
for iTower = 1:length(towers)
%     jTower = jTower + 1;
    windfarm_specification.tower_locations(iTower).y = LatitudeLongitudeDistance(map_bound_top_left_lon,map_bound_bottom_right_lat,map_bound_top_left_lon,towers(iTower).lat);
    windfarm_specification.tower_locations(iTower).x = LatitudeLongitudeDistance(map_bound_top_left_lon,map_bound_bottom_right_lat,towers(iTower).lon,map_bound_bottom_right_lat);
end

% Specify the boundaries for possible flight path intersects
if use_ge_configuration_only % This is the same as the GE 1.5 SE configuration below
        bounding_polygon_x = [[windfarm_specification.tower_locations(1:8).x] - turbine_specification.turbine_radius ...
                              [windfarm_specification.tower_locations(fliplr(9:15)).x] + turbine_specification.turbine_radius ...
                              [windfarm_specification.tower_locations(1).x] - turbine_specification.turbine_radius];
        bounding_polygon_y = [[windfarm_specification.tower_locations(1).y] + turbine_specification.turbine_radius ...
                              [windfarm_specification.tower_locations(2:7).y] ...
                              [windfarm_specification.tower_locations([8 15]).y] - turbine_specification.turbine_radius ...
                              [windfarm_specification.tower_locations(fliplr(10:14)).y] ...
                              [windfarm_specification.tower_locations([9 1]).y] + turbine_specification.turbine_radius];
else switch turbineType
    case 'ge' % GE 1.5 SE
        bounding_polygon_x = [[windfarm_specification.tower_locations(1:7).x] - 1.5*turbine_specification.turbine_radius ...
                              [windfarm_specification.tower_locations(fliplr(8:15)).x] + 1.5*turbine_specification.turbine_radius ...
                              [windfarm_specification.tower_locations(1).x] - 1.5*turbine_specification.turbine_radius];
        bounding_polygon_y = [[windfarm_specification.tower_locations(1).y] + 1.5*turbine_specification.turbine_radius ...
                              [windfarm_specification.tower_locations(2:6).y] ...
                              [windfarm_specification.tower_locations([7 15]).y] - 1.5*turbine_specification.turbine_radius ...
                              [windfarm_specification.tower_locations(fliplr(9:14)).y] ...
                              [windfarm_specification.tower_locations([8 1]).y] + 1.5*turbine_specification.turbine_radius];    
    case 'siemans23' % Siemens SWT 2.3-101
        bounding_polygon_x = [[windfarm_specification.tower_locations(1:3).x] - 1.5*turbine_specification.turbine_radius ...
                              [windfarm_specification.tower_locations(10).x] ...
                              [windfarm_specification.tower_locations(fliplr(4:10)).x] + 1.5*turbine_specification.turbine_radius ...
                              [windfarm_specification.tower_locations(4).x] ...
                              [windfarm_specification.tower_locations(1).x] - 1.5*turbine_specification.turbine_radius];
        bounding_polygon_y = [[windfarm_specification.tower_locations(1).y] + 1.5*turbine_specification.turbine_radius ...
                              [windfarm_specification.tower_locations(2).y] ...
                              [windfarm_specification.tower_locations([3 10 10]).y] - 1.5*turbine_specification.turbine_radius ...
                              [windfarm_specification.tower_locations(fliplr(5:9)).y] ...
                              [windfarm_specification.tower_locations([4 4 1]).y] + 1.5*turbine_specification.turbine_radius];
                      
    case 'siemans30' % Siemens SWT 2.3-101
        bounding_polygon_x = [[windfarm_specification.tower_locations(1:3).x] - 1.5*turbine_specification.turbine_radius ...
                              [windfarm_specification.tower_locations(10).x] ...
                              [windfarm_specification.tower_locations(fliplr(4:10)).x] + 1.5*turbine_specification.turbine_radius ...
                              [windfarm_specification.tower_locations(4).x] ...
                              [windfarm_specification.tower_locations(1).x] - 1.5*turbine_specification.turbine_radius];
        bounding_polygon_y = [[windfarm_specification.tower_locations(1).y] + 1.5*turbine_specification.turbine_radius ...
                              [windfarm_specification.tower_locations(2).y] ...
                              [windfarm_specification.tower_locations([3 10 10]).y] - 1.5*turbine_specification.turbine_radius ...
                              [windfarm_specification.tower_locations(fliplr(5:9)).y] ...
                              [windfarm_specification.tower_locations([4 4 1]).y] + 1.5*turbine_specification.turbine_radius];
    case 'vestas' % Vestas V90
        bounding_polygon_x = [[windfarm_specification.tower_locations(1).x] - turbine_specification.turbine_radius ...
                              [windfarm_specification.tower_locations(8).x] ...
                              [windfarm_specification.tower_locations(fliplr(2:8)).x] + turbine_specification.turbine_radius ...
                              [windfarm_specification.tower_locations(2).x]...
                              [windfarm_specification.tower_locations(1).x] - turbine_specification.turbine_radius];
        bounding_polygon_y = [[windfarm_specification.tower_locations(1).y] - turbine_specification.turbine_radius ...
                              [windfarm_specification.tower_locations([8 8]).y] - turbine_specification.turbine_radius ...
                              [windfarm_specification.tower_locations(fliplr(3:7)).y] ...
                              [windfarm_specification.tower_locations([2 2 1]).y] + turbine_specification.turbine_radius];
    otherwise error('Bad turbine specification');
    end
end

% Static bird parameters
% bird_specification.wingspan = 1;
% bird_specification.length = 2;

survey_radius = 1500; % meters

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulation parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % Simulate normal distribution of bird paths
% bird_path_direction_degrees_mean = 200;
% bird_path_direction_degrees_stdev = 20;
% 
% % Simulate normal distribution of bird heights
% bird_path_height_mean = 60;
% bird_path_height_stdev = 15;
% 
% % Simulate normal distribution of bird heights
% bird_speed_mean = 25;
% bird_speed_stdev = 2;
% 
% % Simulate normal distribution of bird paths
% % wind_direction_degrees_mean = 150;
% % wind_direction_degrees_stdev = 20;
% wind_direction_degrees_mean = 90;
% wind_direction_degrees_stdev = 0.1;
% 
% % Simulate normal distribution of bird heights
% wind_speed_mean = 10;
% wind_speed_stdev = 2;



% Need
% Distribution of flight directions
% Distribution of flight heights
% Tower specifications
%










