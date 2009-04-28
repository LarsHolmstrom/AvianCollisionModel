function time= TimeForBladeToTravelDistance(z, y_start, y_end, omega)
% For a given z-plane, calculate the time required for the rotor blade to travel the
% distance from y_start to y_end traveling at rotational velocity omega. Don't
% return a time greater than t_max.

%The time required to travel the distance from y_start to y_end
time = abs(1/omega*(atan(y_end/z)-atan(y_start/z)));

