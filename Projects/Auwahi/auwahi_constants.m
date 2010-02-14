
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
% Create a KML file with the bounding box in it
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
% Load image in and convert to .mat format
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[img,map] = imread('Map_Cropped.jpg');
for i = 1:3
    img(:,:,i) = flipud(img(:,:,i));
end
save Map_Cropped img

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determine the coordinates of the turbines, in meters, relative to the bottom left (0,0)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The latitude and longitude values were obtained from the awahi documentation
tower(1).lon = -156.326295;
tower(1).lat = 20.6034832;
tower(2).lon = -156.326785;
tower(2).lat = 20.60116;
tower(3).lon = -156.326174;
tower(3).lat = 20.5993976;
tower(4).lon = -156.326131;
tower(4).lat = 20.597464;
tower(5).lon = -156.325988;
tower(5).lat = 20.5957088;
tower(6).lon = -156.325616;
tower(6).lat = 20.5938827;
tower(7).lon = -156.325381;
tower(7).lat = 20.5919196;
tower(8).lon = -156.324825;
tower(8).lat = 20.5900133;
tower(9).lon = -156.318806;
tower(9).lat = 20.6012061;
tower(10).lon = -156.318676;
tower(10).lat = 20.599318;
tower(11).lon = -156.318187;
tower(11).lat = 20.5975101;
tower(12).lon = -156.317515;
tower(12).lat = 20.5958626;
tower(13).lon = -156.317976;
tower(13).lat = 20.593438;
tower(14).lon = -156.317919;
tower(14).lat = 20.5918711;
tower(15).lon = -156.317371;
tower(15).lat = 20.5898943;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up the specification structures needed to drive the simulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Specify the tubine model. This also affects the wind farm layout
switch turbineType
    case 'ge' % GE 1.5 SE
        tower_layout = 1:15;
        % Static turbine specification
        turbine_specification.tower_height = 64.7; % meters
        turbine_specification.turbine_radius = 35.25; % meters
        turbine_specification.hub_radius = 2; % meters
        turbine_specification.tower_base_diameter = 3.5; % meters
        turbine_specification.tower_top_diameter = 3.5; % meters
        turbine_specification.n_blades = 3;
        turbine_specification.maximum_blade_chord_length = 1.5; % meters
        turbine_specification.blade_chord_length_at_hub = 0.8;
        turbine_specification.axial_induction = 0.25; % meters
        turbine_specification.cut_in_wind_speed = 4; %m/s
        turbine_specification.cut_out_wind_speed = 25; %m/s
        turbine_specification.min_rpm = 11.1; %rpms
        turbine_specification.max_rpm = 22.2; %rpms
    case 'siemans' % Siemens SWT 2.3-101
        tower_layout = 6:15;
        % Static turbine specification
        turbine_specification.tower_height = 80; % meters
        turbine_specification.turbine_radius = 50.5; % meters
        turbine_specification.hub_radius = 1.9; % meters
        turbine_specification.tower_base_diameter = 4.2; % meters
        turbine_specification.tower_top_diameter = 4.2; % meters
        turbine_specification.n_blades = 3;
        turbine_specification.maximum_blade_chord_length = 3.4; % meters
        turbine_specification.blade_chord_length_at_hub = 2.4;
        turbine_specification.axial_induction = 0.25; % meters
        turbine_specification.cut_in_wind_speed = 4; %m/s
        turbine_specification.cut_out_wind_speed = 25; %m/s
        turbine_specification.min_rpm = 6; %rpms
        turbine_specification.max_rpm = 16; %rpms
    case 'vestas' % Vestas V90
        tower_layout = 8:15;
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

jTower = 0;
for iTower = tower_layout
    jTower = jTower + 1;
    windfarm_specification.tower_locations(jTower).y = LatitudeLongitudeDistance(map_bound_top_left_lon,map_bound_bottom_right_lat,map_bound_top_left_lon,tower(iTower).lat);
    windfarm_specification.tower_locations(jTower).x = LatitudeLongitudeDistance(map_bound_top_left_lon,map_bound_bottom_right_lat,tower(iTower).lon,map_bound_bottom_right_lat);
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
        bounding_polygon_x = [[windfarm_specification.tower_locations(1:8).x] - turbine_specification.turbine_radius ...
                              [windfarm_specification.tower_locations(fliplr(9:15)).x] + turbine_specification.turbine_radius ...
                              [windfarm_specification.tower_locations(1).x] - turbine_specification.turbine_radius];
        bounding_polygon_y = [[windfarm_specification.tower_locations(1).y] + turbine_specification.turbine_radius ...
                              [windfarm_specification.tower_locations(2:7).y] ...
                              [windfarm_specification.tower_locations([8 15]).y] - turbine_specification.turbine_radius ...
                              [windfarm_specification.tower_locations(fliplr(10:14)).y] ...
                              [windfarm_specification.tower_locations([9 1]).y] + turbine_specification.turbine_radius];
                      
    case 'siemans' % Siemens SWT 2.3-101
        bounding_polygon_x = [[windfarm_specification.tower_locations(1:3).x] - turbine_specification.turbine_radius ...
                              [windfarm_specification.tower_locations(10).x] ...
                              [windfarm_specification.tower_locations(fliplr(4:10)).x] + turbine_specification.turbine_radius ...
                              [windfarm_specification.tower_locations(4).x] ...
                              [windfarm_specification.tower_locations(1).x] - turbine_specification.turbine_radius];
        bounding_polygon_y = [[windfarm_specification.tower_locations(1).y] + turbine_specification.turbine_radius ...
                              [windfarm_specification.tower_locations(2).y] ...
                              [windfarm_specification.tower_locations([3 10 10]).y] - turbine_specification.turbine_radius ...
                              [windfarm_specification.tower_locations(fliplr(5:9)).y] ...
                              [windfarm_specification.tower_locations([4 4 1]).y] + turbine_specification.turbine_radius];
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










