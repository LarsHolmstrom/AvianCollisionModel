function [time final_y]= IntegrateBladeTime(z, y_start, y_end, omega, t_max)
% For a given z-plane, calculate the time required for the rotor blade to travel the
% distance from y_start to y_end traveling at rotational velocity omega. Don't
% return a time greater than t_max.

if z >= 0
    if y_end >= y_start
        t_max = abs(t_max);
    else
        t_max = -abs(t_max);
    end
else
    if y_end >= y_start
        t_max = -abs(t_max);
    else
        t_max = abs(t_max);
    end
end

%The time required to travel the distance from y_start to y_end
time = abs(1/omega*(atan(y_end/z)-atan(y_start/z)));
%Don't return a time that is greater than the abs(t_max)
time = min(time, abs(t_max));

%The final position at which time equal to t_max has been reached
final_y = tan(atan(y_start/z)+time*omega)*z;

%Don't return a value outside of the limits of integration
if y_start < y_end
    if final_y < y_start
        final_y = y_start;
    end
    if final_y > y_end
        final_y = y_end;
    end
else
    if final_y < y_end
        final_y = y_end;
    end
    if final_y > y_start
        final_y = y_start;
    end
end

