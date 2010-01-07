function p = PodolskiCollisionProbability(B, ... %Number of blades
                                          hub_radius, ...
                                          bird_length, ...
                                          bird_wingspan, ...
                                          omega, ...
                                          maximum_blade_chord_length, ... %Meters
                                          blade_chord_length_at_hub, ... %Meters
                                          theta, ... %Naive angle of attack
                                          R, ...
                                          Vbx, ...%Bird's velocity in the x-direction
                                          y, ...
                                          z)

%Distance from the center of the hub
r = sqrt(y^2 + z^2);

% %Rotational angle
% psi = atan(z/y);

[chord_length,chord_angle] = ChordCharacteristics(R,maximum_blade_chord_length,blade_chord_length_at_hub,r);
assert(chord_angle <= 90 && chord_angle >=0);
%Convert to radians
chord_angle = chord_angle/360*2*pi;
blade_width = chord_length*cos(chord_angle);
blade_depth = chord_length*sin(chord_angle);

omega_rpm = omega/2/pi*60;

%Keep everything in radians
L = bird_length;
W = bird_wingspan;
S = Vbx;
HA = theta;
LD = abs(0.3*(sin(HA)));
DT = (L + LD)/S;
AS = omega_rpm/60*2*pi;
BD = blade_depth;
BW = blade_width; %maximum_width_of_blade;
BSA = DT*AS; %Angle swept
AoD = BSA*r; %Arc length at radius r
TAoD = (AoD+W+BW);
p = (B*TAoD)/(2*pi*r);



