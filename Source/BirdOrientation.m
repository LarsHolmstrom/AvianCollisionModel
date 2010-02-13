function [angle_of_orientation_degrees ...
          bird_downwind_relative_direction_radians ...
          Vbx ...
          Vby ...
          Vx] = BirdOrientation(bird_direction, ...
                                bird_speed, ...
                                wind_direction, ...
                                wind_speed, ...
                                axial_induction)


bird_downwind_relative_direction = bird_direction - wind_direction; %Degrees clockwise from downwind
% Velocity components (m/s) for the bird and the wind
bird_downwind_relative_direction_radians = bird_downwind_relative_direction/360*2*pi;

% Bird's wind relative velocity in the x-direction.
Vbx = bird_speed*cos(bird_downwind_relative_direction_radians) - wind_speed;
% Bird's velocity in the y-direction, perpendicular to the wind direction.
% This is equivalent to the bird's wind relative velocity in the
% y-direction because there is no wind in the y-direction.
Vby = bird_speed*sin(bird_downwind_relative_direction_radians);
% Bird's velocity in the x direction at the turbine, taking the axial induction into account
Vx = Vbx+(1-axial_induction)*wind_speed;
% The bird's angle of orientation relative to the rotor plane.
angle_of_orientation = atan(Vby/Vbx); %FIXME, the axial induction factor should be included in this
if (Vbx < 0)
    angle_of_orientation = angle_of_orientation + pi;
end
angle_of_orientation_degrees = angle_of_orientation/2/pi*360;

