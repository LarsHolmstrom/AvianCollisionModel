function y_finish = DistanceBladeTravelsInTime(z, y_start, omega, time)
%Positive omega is clockwise

psi = atan(z/y_start);

%Check for boundary conditions and account for quadrant ambiguities in psi
if z > 0  %Bind psi between 0 and pi
    if y_start > 0
        %first quadrant
    else
        %second quadrant
        psi = psi + pi;
    end
    if omega > 0
        %clockwise rotation
        if time*omega > psi
            y_finish = inf;
            return;
        end
        %Account for new psi after rotation
        final_psi = psi - time*omega;
    else
        %counter clockwise rotation
        if -time*omega > pi - psi
            y_finish = -inf;
            return;
        end
        %Account for new psi after rotation
        final_psi = psi + time*omega;
    end    
%     %Account for new psi after rotation
%     final_psi = psi - time*omega;
else %Bind psi between 0 and -pi
    if y_start >= 0
        %fourth quadrant
    else
        %third quadrant
        psi = psi - pi;
    end
    if omega > 0
        %clockwise rotation
        if time*omega > pi + psi
            y_finish = -inf;
            return;
        end
        %Account for new psi after rotation
        final_psi = psi - time*omega;
    else
        %counter clockwise rotation
        if -time*omega > -psi
            y_finish = inf;
            return;
        end
        %Account for new psi after rotation
        final_psi = psi + time*omega;
    end
%     %Account for new psi after rotation
%     final_psi = psi + time*omega;
end

y_finish = z/tan(final_psi);
if isnan(y_finish)
    assert(final_psi == 0);
    y_finish = y_start;
end
% distance = y_finish - y_start;
