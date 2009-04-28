function p = TuckerCollisionProbability(B, ... %Number of blades
                                        hub_radius, ...
                                        bird_length, ...
                                        bird_wingspan, ...
                                        omega, ...
                                        maximum_blade_chord_length, ... %Meters
                                        R, ...
                                        Vbx, ...%Bird's velocity in the x-direction
                                        y, ...
                                        z)

%Distance from the center of the hub
r = sqrt(y^2 + z^2);

%Rotational angle
psi = atan(z/y);

A = bird_wingspan/bird_length; %Aspect ratio of the bird

p = B*bird_wingspan/(2*pi)*(omega/(A*Vbx) + sin(abs(psi))/r);

[chord_length,chord_angle] = ChordCharacteristics(R,maximum_blade_chord_length,r);
assert(chord_angle <= 90 && chord_angle >=0);
%Convert to radians
chord_angle = chord_angle/360*2*pi;

pc = B*chord_length/2/pi*(cos(chord_angle)/r - omega*sin(chord_angle)/Vbx);

p = p + pc;










