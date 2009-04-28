B = 3;
bird_length = 0.32;
bird_wingspan = 0.82;
omega = 1.4347;
maximum_blade_chord_length = 3.36;
theta = 0;
R = 40;
% Vbx = 17.14;
Vbx = 28.28;
y = R/2;
z = 0;
hub_radius = 1.8;
% hub_radius = 0;
% distance_between_rows = 209;
% distance_between_columns = 789;
distance_between_rows = 780;
distance_between_columns = 214;
num_rows = 7;
num_columns = 2;

p = PodolskiCollisionProbability(B, ... %Number of blades
                                 hub_radius, ...
                                 bird_length, ...
                                 bird_wingspan, ...
                                 omega, ...
                                 maximum_blade_chord_length, ... %Meters
                                 theta, ... %Naive angle of attack
                                 R, ...
                                 Vbx, ...%Bird's velocity in the x-direction
                                 y, ...
                                 z)
                             
% p = (1-avoidance_rate)*p;
% p = 0.065;
                             
C = R*2-hub_radius*2-bird_wingspan;
%Probability of a collision per column
Pc = (hub_radius*2 + bird_wingspan + C*p)/distance_between_rows
%Probability of a collision per row
Pr = (hub_radius*2 + bird_wingspan + C*p)/distance_between_columns

crossing_columns_collision_probability = 1 - (1 - Pc)^num_columns
crossing_rows_collision_probability = 1 - (1 - Pr)^num_rows

% radar_survey_range = 750;
% radar_survey_range = 3000;
% passage_rate = 2123.636;
% passage_rate_below_tower_height = passage_rate * 0.2;
% passage_rate_below_tower_height = 376.7144;
% passage_rate_below_tower_height = 43.39;
passage_rate_below_tower_height = 33.2;
%Per bird collision probability
collision_probability_per_tower_crossing_columns = crossing_columns_collision_probability
collision_probability_per_tower_crossing_rows = crossing_rows_collision_probability

avoidance_rate = 0.9925;
collisions_crossing_columns = collision_probability_per_tower_crossing_columns * passage_rate_below_tower_height * (1-avoidance_rate)
collisions_crossing_rows = collision_probability_per_tower_crossing_rows * passage_rate_below_tower_height * (1-avoidance_rate)

mean_collisions_across_rows_and_columns = (collisions_crossing_columns + collisions_crossing_rows) / 2