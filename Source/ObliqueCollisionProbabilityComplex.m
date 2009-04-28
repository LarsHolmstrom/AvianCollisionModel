function collision_probability = ObliqueCollisionProbability(B, ...
                                                             hub_radius, ...
                                                             bird_length, ...
                                                             bird_wingspan, ...
                                                             omega, ...
                                                             angle_blade_width, ...
                                                             blade_depth, ...
                                                             R, ...
                                                             theta_degrees, ...
                                                             Vbx, ...%Bird's velocity in the x-direction
                                                             Vby, ...%Bird's velocity in the y-direction
                                                             y, ...
                                                             z, ...
                                                             plot_flag)

if abs(theta_degrees) >= 90
    error_string = {'Improbable input parameters. Bird would be flying backwards.',...
                    'Check Wind & Bird Speeds and Directions'};
    errordlg(error_string,'Error');
    error('Improbable input parameters. Bird would be flying backwards.');
end
          
%Convert theta to radians
theta = theta_degrees/360*2*pi;

%Distance from the center of the hub
r = sqrt(y^2 + z^2);

%The length of the bird
length = bird_length;
%The width of the bird
width = bird_wingspan;

%If the bird is travelling upwind, invert the z component to place the bird
%on the opposite side of the z axis and rectify the ground velocity of the bird.
upwind = false;
if (Vbx < 0)
    Vbx = abs(Vbx);
    theta = theta+pi;
    z = -z;
    upwind = true;
end

%Constrain theta to be -pi <= theta <= pi
theta = rem(theta,2*pi);
if theta > pi
    theta = theta - 2*pi;
elseif theta < -pi
    theta = theta + 2*pi;
end

psi = atan(z/y);
if (y < 0)
    psi = psi + pi;
end

[chord_length,chord_angle] = ChordCharacteristics(R,r);

%FIXME
chord_length = 0.2;
chord_angle = 45;
% chord_length = 0.2;
% chord_angle = 90;

assert(chord_angle <= 90 && chord_angle >=0);

chord_angle = chord_angle/360*2*pi;
blade_depth = abs(chord_length*sin(chord_angle));
blade_width = abs(chord_length*cos(chord_angle)); %Tangent to rotation
blade_width_y = abs(blade_width*sin(psi));
% Make chord angle on same rotational coordinate space as the bird
if z > 0
    chord_angle = -abs(chord_angle);
end

%Keep the maximum and minimum values on the unit circle
min_y = -sqrt(R^2-(min(abs(z),R))^2);
max_y = sqrt(R^2-(min(abs(z),R))^2);

%The blade should always travel counter clockwise, but is passed in as positive
assert(omega >= 0);
omega = -abs(omega);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Start Calculations for case wher bird is moving to the right
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if theta > 0
    %The times of itercept for the 5 points on the box
    time_nose     = width/2*sin(theta)/Vbx;
    time_corner_1 = width*sin(theta)/Vbx;
    time_corner_2 = 0;
    time_corner_3 = length*cos(theta)/Vbx;
    time_corner_4 = time_corner_1 + length*cos(theta)/Vbx;
    %The y-coordinates of the intercepts with the rotor plane for the 5 points on the box
    intercept_y_nose     = y;
    intercept_y_1 = intercept_y_nose+width/2*cos(theta)+(time_corner_1-time_nose)*Vby;
    intercept_y_2 = intercept_y_nose-width/2*cos(theta)-time_nose*Vby;
    intercept_y_3 = intercept_y_2-length*sin(theta)+time_corner_3*Vby;
    intercept_y_4 = intercept_y_1-length*sin(theta)+(time_corner_4-time_corner_1)*Vby;

    y_intercept_points = [intercept_y_1 intercept_y_nose intercept_y_2 intercept_y_3 intercept_y_4];
    z_intercept_points = z*ones(1,5);
    x_intercept_points = zeros(1,5);
    
    time_drift_back_rotor_plane = blade_depth/Vbx;
    y_drift_back_rotor_plane =  Vby*time_drift_back_rotor_plane;
    if (y_drift_back_rotor_plane < 0)
        error('Drift should be positive');
    end

    %The y-coordinates of the 5 points on the box at the time of contact with the rotor plane
    initial_y_nose = intercept_y_2 + width/2*cos(theta);
    initial_y_1 = intercept_y_2 + width*cos(theta);
    initial_y_2 = intercept_y_2;
    initial_y_3 = initial_y_2 - length*sin(theta);
    initial_y_4 = initial_y_1 - length*sin(theta);
    %The x-coordinates of the 5 points on the box at the time of contact with the rotor plane
    initial_x_nose = -width/2*sin(theta);
    initial_x_1 = -width*sin(theta);
    initial_x_2 = 0;
    initial_x_3 = -length*cos(theta);
    initial_x_4 = initial_x_1 - length*cos(theta);

    y_initial_points = [initial_y_1 initial_y_nose initial_y_2 initial_y_3 initial_y_4 initial_y_1];
    x_initial_points = [initial_x_1 initial_x_nose initial_x_2 initial_x_3 initial_x_4 initial_x_1];
    z_initial_points = z*ones(1,6);
    
    if (y_drift_back_rotor_plane < 0)
        error('Drift should be positive');
    end

    %Keep the maximum and minimum values on the unit circle
%     if (intercept_y_1 > max(y))
        
    % intercept_y_1 = max(min_y,min(max_y,intercept_y_1));
    % intercept_y_2 = max(min_y,min(max_y,intercept_y_2));
    % intercept_y_3 = max(min_y,min(max_y,intercept_y_3));
    % intercept_y_4 = max(min_y,min(max_y,intercept_y_4));
    % intercept_y_nose = max(min_y,min(max_y,intercept_y_nose));
    
    if z < 0
        assert(chord_angle >= 0 & chord_angle <= pi/2)
        %First, calculate front edge collision points
        left_most_rotor_y = intercept_y_2; %Default
        left_most_rotor_time = time_corner_2;
        left_most_collision_point = [0 intercept_y_2 z];
        if chord_angle > theta %More rotated in positive direction 
            %Collision between corner 1 and the front of the blade is possible
            %Check for collision between front of blade and corner 1 of the bird
            blade_position = DistanceBladeTravelsInTime(z, intercept_y_1, -omega, time_corner_1);
            if blade_position > intercept_y_2
                left_most_rotor_y = blade_position;
                left_most_rotor_time = time_corner_1;
                left_most_collision_point = [0 intercept_y_1 z];
            else
                left_most_rotor_y = intercept_y_2;
                left_most_rotor_time = time_corner_2;
                left_most_collision_point = [0 intercept_y_2 z];
            end
        end
        
        if chord_length > 0
            %Calculate back of blade collision possibility with corner 1
            %Find the initial blade position resulting in a collision betwee the back of the rotor and corner 1
            blade_position = DistanceBladeTravelsInTime(z, intercept_y_1 + y_drift_back_rotor_plane, -omega, time_corner_1+time_drift_back_rotor_plane);
            %Check to see if the front of the blade will clear corner 2 of the bird on this line of intercept
            [passed_in_front_of_corner_2 x_c y_c] = PassInFront(blade_position + blade_width_y , 0, ...
                                                                intercept_y_1 + y_drift_back_rotor_plane + blade_width_y, 0, ...
                                                                initial_y_2, initial_x_2, ...
                                                                initial_y_2 + Vby*(time_corner_1+time_drift_back_rotor_plane), initial_x_2+Vbx*(time_corner_1+time_drift_back_rotor_plane));
            [passed_in_front_of_corner_1 x_c y_c] = PassInFront(blade_position + blade_width_y , 0, ...
                                                                intercept_y_1 + y_drift_back_rotor_plane + blade_width_y, 0, ...
                                                                initial_y_1, initial_x_1, ...
                                                                initial_y_1 + Vby*(time_corner_1+time_drift_back_rotor_plane), initial_x_1+Vbx*(time_corner_1+time_drift_back_rotor_plane));
            %Find where the front edge collision would be after this time has passed
            front_edge_advance_blade_position = DistanceBladeTravelsInTime(z, left_most_rotor_y, omega, time_corner_1+time_drift_back_rotor_plane-left_most_rotor_time);
            if passed_in_front_of_corner_1 && ...
               passed_in_front_of_corner_2 && ...
               (blade_position + blade_width_y > intercept_y_1) && ...
               (blade_position + blade_width_y > front_edge_advance_blade_position)
                %The front of the blade clears corner 1 and corner 2 of the bird, 
                %and this intercept position is further rotated than either front blade
                %collision, so corner 1 intercepts the back of the blade
                left_most_rotor_y = blade_position + blade_width_y;
                left_most_rotor_time = time_corner_1 + time_drift_back_rotor_plane;
                left_most_collision_point = [blade_depth (intercept_y_1+y_drift_back_rotor_plane) z];
            else %Front edge collision impossible for back of blade
                if chord_angle < theta %Less rotated in positive direction 
                    %Find the initial blade position resulting in a collision between the back of the rotor and corner 2
                    blade_position = DistanceBladeTravelsInTime(z, intercept_y_2 + y_drift_back_rotor_plane, -omega, time_corner_2+time_drift_back_rotor_plane);
                    %Check to see if the front of the blade will clear side 2_3 of the bird
                    %and this intercept position is further rotated than either front blade
                    %collision
                    %Find where the front edge collision would be after this time has passed
                    front_edge_advance_blade_position = DistanceBladeTravelsInTime(z, left_most_rotor_y, omega, time_corner_2+time_drift_back_rotor_plane-left_most_rotor_time);
                    if blade_position + blade_width_y > intercept_y_2 && (blade_position + blade_width_y > front_edge_advance_blade_position)
                        left_most_rotor_y = blade_position + blade_width_y;
                        left_most_rotor_time = time_corner_2 + time_drift_back_rotor_plane;
                        left_most_collision_point = [blade_depth (intercept_y_2+y_drift_back_rotor_plane) z];
                    end
                end
            end
        end
        
        %First, calculate front edge collision points for the rightmost rotor points
        blade_time = TimeForBladeToTravelDistance(z, intercept_y_3, intercept_y_4, omega);
        if (blade_time < (time_corner_4 - time_corner_3)) && chord_angle < theta %Less rotated in positive direction 
            %Rotor travels the distance in less time than the 3_4 edge, which means it moves faster, on average
            %than the 3_4 edge, which means that it can clip corner 3 of the bird
            right_most_rotor_y = intercept_y_4;
            right_most_rotor_time = time_corner_4;
        else
            %Rotor travels the distance in equal or more time than the 3_4 edge, which means it moves slower, on average
            %than the 3_4 edge, which means that it cannot clip corner 3 of the bird, and instead hits corner 4
            right_most_rotor_y = intercept_y_3;
            right_most_rotor_time = time_corner_3;
        end
        
        if chord_length > 0
            %Calculate the back of blade collision possibility with corner 4
            blade_position = DistanceBladeTravelsInTime(z, intercept_y_4 + y_drift_back_rotor_plane, -omega, time_corner_4+time_drift_back_rotor_plane);
            %Check to see if the front of the blade will clear corner 3 of the bird on this line of intercept
            [front_passed_behind_3 x_c y_c] = PassBehind(blade_position + blade_width_y, 0, ...
                                                         intercept_y_4 + y_drift_back_rotor_plane + blade_width_y, 0, ...
                                                         initial_y_3, initial_x_3, ...
                                                         initial_y_3 + Vby*(time_corner_4+time_drift_back_rotor_plane), initial_x_3+Vbx*(time_corner_4+time_drift_back_rotor_plane));
            %Check to see if the back of the blade will clear corner 3 of the bird on this line of intercept
            [back_passed_behind_3 x_c y_c] = PassBehind(blade_position , blade_depth, ...
                                                        intercept_y_4 + y_drift_back_rotor_plane, blade_depth, ...
                                                        initial_y_3, initial_x_3, ...
                                                        initial_y_3 + Vby*(time_corner_4+time_drift_back_rotor_plane), initial_x_3+Vbx*(time_corner_4+time_drift_back_rotor_plane));
            %Check to see if the front of the blade will clear corner 4 of the bird on this line of intercept
            [front_passed_behind_4 x_c y_c] = PassBehind(blade_position + blade_width_y, 0, ...
                                                         intercept_y_4 + y_drift_back_rotor_plane + blade_width_y, 0, ...
                                                         initial_y_4, initial_x_4, ...
                                                         initial_y_4 + Vby*(time_corner_4+time_drift_back_rotor_plane), initial_x_4+Vbx*(time_corner_4+time_drift_back_rotor_plane));
            %Find where the front edge collision would be after this time has passed
            front_edge_advance_blade_position = DistanceBladeTravelsInTime(z, right_most_rotor_y, omega, time_corner_4+time_drift_back_rotor_plane-right_most_rotor_time);
            if front_passed_behind_3 && back_passed_behind_3 && front_passed_behind_4 && (intercept_y_4 + y_drift_back_rotor_plane + blade_width_y < front_edge_advance_blade_position)
                %Back blade can hit corner 3
                right_most_rotor_y = intercept_y_4 + y_drift_back_rotor_plane + blade_width_y;
                right_most_rotor_time = time_corner_4 + time_drift_back_rotor_plane;
            elseif chord_angle > theta %More rotated in positive direction 
                %Check to see if the back of the blade can strike corner 3
                blade_position = DistanceBladeTravelsInTime(z, intercept_y_3 + y_drift_back_rotor_plane, -omega, time_corner_3+time_drift_back_rotor_plane);
                %Check to see if the front of the blade will clear corner 3 of the bird on this line of intercept
                [passed_behind x_c y_c] = PassBehind(blade_position + blade_width_y, 0, ...
                                                     intercept_y_3 + y_drift_back_rotor_plane + blade_width_y, 0, ...
                                                     initial_y_3, initial_x_3, ...
                                                     initial_y_3 + Vby*(time_corner_3+time_drift_back_rotor_plane), initial_x_3+Vbx*(time_corner_3+time_drift_back_rotor_plane));
                %Find where the front edge collision would be after this time has passed
                front_edge_advance_blade_position = DistanceBladeTravelsInTime(z, right_most_rotor_y, omega, time_corner_3+time_drift_back_rotor_plane-right_most_rotor_time);
                if passed_behind && (intercept_y_3 + y_drift_back_rotor_plane + blade_width_y < front_edge_advance_blade_position)
                    %The front of the blade clears corner 3 meaning that the back of the blade can hit corner 3
                    %and this will result in a less rotated least rotated rotor position than the front edge collisions
                    right_most_rotor_y = intercept_y_3 + y_drift_back_rotor_plane + blade_width_y;
                    right_most_rotor_time = time_corner_3 + time_drift_back_rotor_plane;
                end
            end
        end
    else %z > 0
        assert(chord_angle <= 0 & chord_angle >= -pi/2)
        %First, calculate front edge collision points
        left_most_rotor_y = intercept_y_2; %Default
        left_most_rotor_time = time_corner_2;
        left_most_collision_point = [0 intercept_y_2 z];
        if chord_angle < theta %More rotated in negative direction 
            %Collision between corner 3 and the front of the blade is possible
            %Check for collision between front of blade and corner 2 of the bird
            blade_position = DistanceBladeTravelsInTime(z, intercept_y_3, -omega, time_corner_3);
            if blade_position < intercept_y_2
                left_most_rotor_y = blade_position;
                left_most_rotor_time = time_corner_3;
                left_most_collision_point = [0 intercept_y_3 z];
            else
                left_most_rotor_y = intercept_y_2;
                left_most_rotor_time = time_corner_2;
                left_most_collision_point = [0 intercept_y_2 z];
            end
        end 
        
        if chord_length > 0
            %Calculate back of blade collision possibility with corner 3
            %Find the initial blade position resulting in a collision between the back of the rotor and corner 3
            blade_position = DistanceBladeTravelsInTime(z, intercept_y_3 + y_drift_back_rotor_plane, -omega, time_corner_3+time_drift_back_rotor_plane);
            %Check to see if the front of the blade will clear corner 2 of the bird on this line of intercept
            [passed_in_front_of_corner_2 x_c y_c] = PassInFront(blade_position - blade_width_y , 0, ...
                                                                intercept_y_3 + y_drift_back_rotor_plane - blade_width_y, 0, ...
                                                                initial_y_2, initial_x_2, ...
                                                                initial_y_2 + Vby*(time_corner_3+time_drift_back_rotor_plane), initial_x_2+Vbx*(time_corner_3+time_drift_back_rotor_plane));
            [passed_in_front_of_corner_3 x_c y_c] = PassInFront(blade_position - blade_width_y , 0, ...
                                                                intercept_y_3 + y_drift_back_rotor_plane - blade_width_y, 0, ...
                                                                initial_y_3, initial_x_3, ...
                                                                initial_y_3 + Vby*(time_corner_3+time_drift_back_rotor_plane), initial_x_3+Vbx*(time_corner_3+time_drift_back_rotor_plane));
            %Find where the front edge collision would be after this time has passed
            front_edge_advance_blade_position = DistanceBladeTravelsInTime(z, left_most_rotor_y, omega, time_corner_3+time_drift_back_rotor_plane-left_most_rotor_time);
            if passed_in_front_of_corner_2 && ...
               passed_in_front_of_corner_3 && ...
               (blade_position - blade_width_y < intercept_y_2) && ...
               (blade_position - blade_width_y < front_edge_advance_blade_position)
                %The front of the blade clears corner 2 and corner 3 of the bird, 
                %and this intercept position is further rotated than either front blade
                %collision, so corner 3 intercepts the back of the blade
                left_most_rotor_y = blade_position - blade_width_y;
                left_most_rotor_time = time_corner_3 + time_drift_back_rotor_plane;
                left_most_collision_point = [blade_depth (intercept_y_3+y_drift_back_rotor_plane) z];
            else %Left edge collision impossible for back of blade
                if chord_angle < theta+pi/2 %More rotated in negative direction than the 2_3 edge
                    %Find the initial blade position resulting in a collision between the back of the rotor and corner 2
                    blade_position = DistanceBladeTravelsInTime(z, intercept_y_2 + y_drift_back_rotor_plane, -omega, time_corner_2+time_drift_back_rotor_plane);
                    %Check to see if the front of the blade will clear side 2_3 of the bird
                    %and this intercept position is further left than either front blade
                    %collision
                    %Find where the front edge collision would be after this time has passed
                    front_edge_advance_blade_position = DistanceBladeTravelsInTime(z, left_most_rotor_y, omega, time_corner_2+time_drift_back_rotor_plane-left_most_rotor_time);
                    if blade_position - blade_width_y < intercept_y_2 && (blade_position - blade_width_y < front_edge_advance_blade_position)
                        left_most_rotor_y = blade_position - blade_width_y;
                        left_most_rotor_time = time_corner_2 + time_drift_back_rotor_plane;
                        left_most_collision_point = [blade_depth (intercept_y_2+y_drift_back_rotor_plane) z];
                    end
                end
            end
        end
        
        %First, calculate front edge collision points for the rightmost rotor points
        blade_time = TimeForBladeToTravelDistance(z, intercept_y_4, intercept_y_1, -omega);
        if (blade_time < (time_corner_4 - time_corner_1)) && chord_angle < theta+pi/2 %More rotated in negative direction than the 2_3 edge
            %Rotor travels the distance in less time than the 4_1 edge, which means it moves faster, on average
            %than the 4_1 edge, which means that it can clip corner 4 of the bird
            right_most_rotor_y = intercept_y_4;
            right_most_rotor_time = time_corner_4;
        else
            %Rotor travels the distance in equal or more time than the 4_1 edge, which means it moves slower, on average
            %than the 4_1 edge, which means that it cannot clip corner 4 of the bird, and instead hits corner 1
            right_most_rotor_y = intercept_y_1;
            right_most_rotor_time = time_corner_1;
        end
        
        if chord_length > 0
            %Calculate the back of blade collision possibility with corner 4
            blade_position = DistanceBladeTravelsInTime(z, intercept_y_4 + y_drift_back_rotor_plane, -omega, time_corner_4+time_drift_back_rotor_plane);
            %Check to see if the front of the blade will clear corner 1 of the bird on this line of intercept
            [front_passed_behind_1 x_c y_c] = PassBehind(blade_position - blade_width_y, 0, ...
                                                         intercept_y_4 + y_drift_back_rotor_plane - blade_width_y, 0, ...
                                                         initial_y_1, initial_x_1, ...
                                                         initial_y_1 + Vby*(time_corner_4+time_drift_back_rotor_plane), initial_x_1+Vbx*(time_corner_4+time_drift_back_rotor_plane));
            %Check to see if the back of the blade will clear corner 1 of the bird on this line of intercept
            [back_passed_behind_1 x_c y_c] = PassBehind(blade_position , blade_depth, ...
                                                        intercept_y_4 + y_drift_back_rotor_plane, blade_depth, ...
                                                        initial_y_1, initial_x_1, ...
                                                        initial_y_1 + Vby*(time_corner_4+time_drift_back_rotor_plane), initial_x_1+Vbx*(time_corner_4+time_drift_back_rotor_plane));
            %Check to see if the front of the blade will clear corner 4 of the bird on this line of intercept
            [front_passed_behind_4 x_c y_c] = PassBehind(blade_position - blade_width_y, 0, ...
                                                         intercept_y_4 + y_drift_back_rotor_plane - blade_width_y, 0, ...
                                                         initial_y_4, initial_x_4, ...
                                                         initial_y_4 + Vby*(time_corner_4+time_drift_back_rotor_plane), initial_x_4+Vbx*(time_corner_4+time_drift_back_rotor_plane));
            %Find where the front edge collision would be after this time has passed
            front_edge_advance_blade_position = DistanceBladeTravelsInTime(z, right_most_rotor_y, omega, time_corner_4+time_drift_back_rotor_plane-right_most_rotor_time);
            if front_passed_behind_1 && back_passed_behind_1 && front_passed_behind_4 && (intercept_y_4 + y_drift_back_rotor_plane - blade_width_y > front_edge_advance_blade_position)
                %Back blade can hit corner 4
                right_most_rotor_y = intercept_y_4 + y_drift_back_rotor_plane - blade_width_y;
                right_most_rotor_time = time_corner_4 + time_drift_back_rotor_plane;
            elseif chord_angle > theta+pi/2 %Less rotated in negative direction than the 2_3 edge
                %Check to see if the back of the blade can strike corner 1
                blade_position = DistanceBladeTravelsInTime(z, intercept_y_1 + y_drift_back_rotor_plane, -omega, time_corner_1+time_drift_back_rotor_plane);
                %Check to see if the front of the blade will clear corner 2 of the bird on this line of intercept
                [passed_behind x_c y_c] = PassBehind(blade_position - blade_width_y, 0, ...
                                                     intercept_y_1 + y_drift_back_rotor_plane - blade_width_y, 0, ...
                                                     initial_y_1, initial_x_1, ...
                                                     initial_y_1 + Vby*(time_corner_1+time_drift_back_rotor_plane), initial_x_1+Vbx*(time_corner_1+time_drift_back_rotor_plane));
                %Find where the front edge collision would be after this time has passed
                front_edge_advance_blade_position = DistanceBladeTravelsInTime(z, right_most_rotor_y, omega, time_corner_1+time_drift_back_rotor_plane-right_most_rotor_time);
                if passed_behind && (intercept_y_1 + y_drift_back_rotor_plane - blade_width_y > front_edge_advance_blade_position)
                    %The front of the blade clears corner 1 meaning that the back of the blade can hit corner 1
                    %and this will result in a less rotated least rotation than the front edge collisions
                    right_most_rotor_y = intercept_y_1 + y_drift_back_rotor_plane - blade_width_y;
                    right_most_rotor_time = time_corner_1 + time_drift_back_rotor_plane;
                end
            end
        end
    end
else %theta < 0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Start Calculations for case wher bird is moving to the left
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %The times of itercept for the 5 points on the box
    time_nose     = -width/2*sin(theta)/Vbx;
    time_corner_1 = 0;
    time_corner_2 = -width*sin(theta)/Vbx;
    time_corner_3 = time_corner_2 + length*cos(theta)/Vbx;
    time_corner_4 = length*cos(theta)/Vbx;
    %The y-coordinates of the intercepts with the rotor plane for the 5 points on the box
    intercept_y_nose     = y;
    intercept_y_1 = intercept_y_nose+width/2*cos(theta)-time_nose*Vby;
    intercept_y_2 = intercept_y_nose-width/2*cos(theta)+(time_corner_2-time_nose)*Vby;
    intercept_y_3 = intercept_y_2-length*sin(theta)+(time_corner_3-time_corner_2)*Vby;
    intercept_y_4 = intercept_y_1-length*sin(theta)+time_corner_4*Vby;

    y_intercept_points = [intercept_y_1 intercept_y_nose intercept_y_2 intercept_y_3 intercept_y_4];
    z_intercept_points = z*ones(1,5);
    x_intercept_points = zeros(1,5);
    
    
    time_drift_back_rotor_plane = blade_depth/Vbx;
    y_drift_back_rotor_plane =  Vby*time_drift_back_rotor_plane;
    if (y_drift_back_rotor_plane > 0)
        error('Drift should be negative');
    end

    %The y-coordinates of the 5 points on the box at the time of contact with the rotor plane
    initial_y_nose = intercept_y_1 - width/2*cos(theta);
    initial_y_1 = intercept_y_1;
    initial_y_2 = intercept_y_1 - width*cos(theta);
    initial_y_3 = initial_y_2 - length*sin(theta);
    initial_y_4 = initial_y_1 - length*sin(theta);
    %The x-coordinates of the 5 points on the box at the time of contact with the rotor plane
    initial_x_nose = width/2*sin(theta);
    initial_x_1 = 0;
    initial_x_2 = width*sin(theta);
    initial_x_3 = initial_x_2 - length*cos(theta);
    initial_x_4 = -length*cos(theta);

    y_initial_points = [initial_y_1 initial_y_nose initial_y_2 initial_y_3 initial_y_4 initial_y_1];
    x_initial_points = [initial_x_1 initial_x_nose initial_x_2 initial_x_3 initial_x_4 initial_x_1];
    z_initial_points = z*ones(1,6);

    %Keep the maximum and minimum values on the unit circle
    % intercept_y_1 = max(min_y,min(max_y,intercept_y_1));
    % intercept_y_2 = max(min_y,min(max_y,intercept_y_2));
    % intercept_y_3 = max(min_y,min(max_y,intercept_y_3));
    % intercept_y_4 = max(min_y,min(max_y,intercept_y_4));
    % intercept_y_nose = max(min_y,min(max_y,intercept_y_nose));
    
    if z >= 0
        assert(chord_angle <= 0 & chord_angle >= -pi/2)
        %First, calculate front edge collision points
        left_most_rotor_y = intercept_y_1; %Default
        left_most_rotor_time = time_corner_1;
        left_most_collision_point = [0 intercept_y_1 z];
        if chord_angle < theta %More rotated in negative direction 
            %Collision between corner 2 and the front of the blade is possible
            %Check for collision between front of blade and corner 2 of the bird
            blade_position = DistanceBladeTravelsInTime(z, intercept_y_2, -omega, time_corner_2);
            if blade_position < intercept_y_1
                left_most_rotor_y = blade_position;
                left_most_rotor_time = time_corner_2;
                left_most_collision_point = [0 intercept_y_2 z];
            else
                left_most_rotor_y = intercept_y_1;
                left_most_rotor_time = time_corner_1;
                left_most_collision_point = [0 intercept_y_1 z];
            end
        end
            
        if chord_length > 0
            %Calculate back of blade collision possibility with corner 2
            %Find the initial blade position resulting in a collision betwee the back of the rotor and corner 2
            blade_position = DistanceBladeTravelsInTime(z, intercept_y_2 + y_drift_back_rotor_plane, -omega, time_corner_2+time_drift_back_rotor_plane);
            %Check to see if the front of the blade will clear corner 1 of the bird on this line of intercept
            [passed_in_front_of_corner_1 x_c y_c] = PassInFront(blade_position - blade_width_y , 0, ...
                                                                intercept_y_2 + y_drift_back_rotor_plane - blade_width_y, 0, ...
                                                                initial_y_1, initial_x_1, ...
                                                                initial_y_1 + Vby*(time_corner_2+time_drift_back_rotor_plane), initial_x_1+Vbx*(time_corner_2+time_drift_back_rotor_plane));
            [passed_in_front_of_corner_2 x_c y_c] = PassInFront(blade_position - blade_width_y , 0, ...
                                                                intercept_y_2 + y_drift_back_rotor_plane - blade_width_y, 0, ...
                                                                initial_y_2, initial_x_2, ...
                                                                initial_y_2 + Vby*(time_corner_2+time_drift_back_rotor_plane), initial_x_2+Vbx*(time_corner_2+time_drift_back_rotor_plane));
            %Find where the front edge collision would be after this time has passed
            front_edge_advance_blade_position = DistanceBladeTravelsInTime(z, left_most_rotor_y, omega, time_corner_2+time_drift_back_rotor_plane-left_most_rotor_time);
            if passed_in_front_of_corner_1 && ...
               passed_in_front_of_corner_2 && ...
               (blade_position - blade_width_y < intercept_y_1) && ...
               (blade_position - blade_width_y < front_edge_advance_blade_position)
                %The front of the blade clears corner 1 and corner 2 of the bird, 
                %and this intercept position is further left than either front blade
                %collision, so corner 2 intercepts the back of the blade
                left_most_rotor_y = blade_position - blade_width_y;
                left_most_rotor_time = time_corner_2 + time_drift_back_rotor_plane;
                left_most_collision_point = [blade_depth (intercept_y_2+y_drift_back_rotor_plane) z];
            else %Front edge collision impossible for back of blade
                if chord_angle > theta %Less rotated in negative direction 
                    %Find the initial blade position resulting in a collision between the back of the rotor and corner 1
                    blade_position = DistanceBladeTravelsInTime(z, intercept_y_1 + y_drift_back_rotor_plane, -omega, time_corner_1+time_drift_back_rotor_plane);
                    %Check to see if the front of the blade will clear side 1_4 of the bird
                    % and this intercept position is further left than either front blade
                    %collision
                    %Find where the front edge collision would be after this time has passed
                    front_edge_advance_blade_position = DistanceBladeTravelsInTime(z, left_most_rotor_y, omega, time_corner_1+time_drift_back_rotor_plane-left_most_rotor_time);
                    if blade_position - blade_width_y < intercept_y_1 && (blade_position - blade_width_y < front_edge_advance_blade_position)
                        left_most_rotor_y = blade_position - blade_width_y;
                        left_most_rotor_time = time_corner_1 + time_drift_back_rotor_plane;
                        left_most_collision_point = [blade_depth (intercept_y_1+y_drift_back_rotor_plane) z];
                    end
                end
            end
        end
           
        %First, calculate front edge collision points for the rightmost rotor points
        blade_time = TimeForBladeToTravelDistance(z, intercept_y_3, intercept_y_4, omega);
        if (blade_time < (time_corner_3 - time_corner_4)) && chord_angle < theta %Less rotated in negative direction 
            %Rotor travels the distance in less time than the 3_4 edge, which means it moves faster, on average
            %than the 3_4 edge, which means that it can clip corner 3 of the bird
            right_most_rotor_y = intercept_y_3;
            right_most_rotor_time = time_corner_3;
        else
            %Rotor travels the distance in equal or more time than the 3_4 edge, which means it moves slower, on average
            %than the 3_4 edge, which means that it cannot clip corner 3 of the bird, and instead hits corner 4
            right_most_rotor_y = intercept_y_4;
            right_most_rotor_time = time_corner_4;
        end
        
        if chord_length > 0
            %Calculate the back of blade collision possibility with corner 3
            blade_position = DistanceBladeTravelsInTime(z, intercept_y_3 + y_drift_back_rotor_plane, -omega, time_corner_3+time_drift_back_rotor_plane);
            %Check to see if the front of the blade will clear corner 4 of the bird on this line of intercept
            [front_passed_behind_4 x_c y_c] = PassBehind(blade_position - blade_width_y, 0, ...
                                                         intercept_y_3 + y_drift_back_rotor_plane - blade_width_y, 0, ...
                                                         initial_y_4, initial_x_4, ...
                                                         initial_y_4 + Vby*(time_corner_3+time_drift_back_rotor_plane), initial_x_4+Vbx*(time_corner_3+time_drift_back_rotor_plane));
            %Check to see if the back of the blade will clear corner 4 of the bird on this line of intercept
            [back_passed_behind_4 x_c y_c] = PassBehind(blade_position , blade_depth, ...
                                                        intercept_y_3 + y_drift_back_rotor_plane, blade_depth, ...
                                                        initial_y_4, initial_x_4, ...
                                                        initial_y_4 + Vby*(time_corner_3+time_drift_back_rotor_plane), initial_x_4+Vbx*(time_corner_3+time_drift_back_rotor_plane));
            %Check to see if the front of the blade will clear corner 3 of the bird on this line of intercept
            [front_passed_behind_3 x_c y_c] = PassBehind(blade_position - blade_width_y, 0, ...
                                                         intercept_y_3 + y_drift_back_rotor_plane - blade_width_y, 0, ...
                                                         initial_y_3, initial_x_3, ...
                                                         initial_y_3 + Vby*(time_corner_3+time_drift_back_rotor_plane), initial_x_3+Vbx*(time_corner_3+time_drift_back_rotor_plane));
            %Find where the front edge collision would be after this time has passed
            front_edge_advance_blade_position = DistanceBladeTravelsInTime(z, right_most_rotor_y, omega, time_corner_3+time_drift_back_rotor_plane-right_most_rotor_time);
            if front_passed_behind_4 && back_passed_behind_4 && front_passed_behind_3 && (intercept_y_3 + y_drift_back_rotor_plane - blade_width_y > front_edge_advance_blade_position)
                %Back blade can hit corner 3
                right_most_rotor_y = intercept_y_3 + y_drift_back_rotor_plane - blade_width_y;
                right_most_rotor_time = time_corner_3 + time_drift_back_rotor_plane;
            elseif chord_angle < theta %More rotated in negative direction 
                %Check to see if the back of the blade can strike corner 4
                blade_position = DistanceBladeTravelsInTime(z, intercept_y_4 + y_drift_back_rotor_plane, -omega, time_corner_4+time_drift_back_rotor_plane);
                %Check to see if the front of the blade will clear corner 4 of the bird on this line of intercept
                [passed_behind x_c y_c] = PassBehind(blade_position - blade_width_y, 0, ...
                                                     intercept_y_4 + y_drift_back_rotor_plane - blade_width_y, 0, ...
                                                     initial_y_4, initial_x_4, ...
                                                     initial_y_4 + Vby*(time_corner_4+time_drift_back_rotor_plane), initial_x_4+Vbx*(time_corner_4+time_drift_back_rotor_plane));
                %Find where the front edge collision would be after this time has passed
                front_edge_advance_blade_position = DistanceBladeTravelsInTime(z, right_most_rotor_y, omega, time_corner_4+time_drift_back_rotor_plane-right_most_rotor_time);
                if passed_behind && (intercept_y_4 + y_drift_back_rotor_plane - blade_width_y > front_edge_advance_blade_position)
                    %The front of the blade clears corner 4 meaning that the back of the blade can hit corner 4
                    %and this will result in a greater right most rotor position than the front edge collisions
                    right_most_rotor_y = intercept_y_4 + y_drift_back_rotor_plane - blade_width_y;
                    right_most_rotor_time = time_corner_4 + time_drift_back_rotor_plane;
                end
            end
        end
    else %z<0
        assert(chord_angle >= 0 & chord_angle <= pi/2)
        %First, calculate front edge collision points
        left_most_rotor_y = intercept_y_1; %Default
        left_most_rotor_time = time_corner_1;
        left_most_collision_point = [0 intercept_y_1 z];
        if chord_angle > theta %More rotated in positive direction 
            %Collision between corner 4 and the front of the blade is possible
            %Check for collision between front of blade and corner 2 of the bird
            blade_position = DistanceBladeTravelsInTime(z, intercept_y_4, -omega, time_corner_4);
            if blade_position > intercept_y_1
                left_most_rotor_y = blade_position;
                left_most_rotor_time = time_corner_4;
                left_most_collision_point = [0 intercept_y_4 z];
            else
                left_most_rotor_y = intercept_y_1;
                left_most_rotor_time = time_corner_1;
                left_most_collision_point = [0 intercept_y_1 z];
            end
        end 
        
        if chord_length > 0
            %Calculate back of blade collision possibility with corner 4
            %Find the initial blade position resulting in a collision between the back of the rotor and corner 4
            blade_position = DistanceBladeTravelsInTime(z, intercept_y_4 + y_drift_back_rotor_plane, -omega, time_corner_4+time_drift_back_rotor_plane);
            %Check to see if the front of the blade will clear corner 1 of the bird on this line of intercept
            [passed_in_front_of_corner_1 x_c y_c] = PassInFront(blade_position + blade_width_y , 0, ...
                                                                intercept_y_4 + y_drift_back_rotor_plane + blade_width_y, 0, ...
                                                                initial_y_1, initial_x_1, ...
                                                                initial_y_1 + Vby*(time_corner_4+time_drift_back_rotor_plane), initial_x_1+Vbx*(time_corner_4+time_drift_back_rotor_plane));
            [passed_in_front_of_corner_4 x_c y_c] = PassInFront(blade_position + blade_width_y , 0, ...
                                                                intercept_y_4 + y_drift_back_rotor_plane - blade_width_y, 0, ...
                                                                initial_y_4, initial_x_4, ...
                                                                initial_y_4 + Vby*(time_corner_4+time_drift_back_rotor_plane), initial_x_4+Vbx*(time_corner_4+time_drift_back_rotor_plane));
            %Find where the front edge collision would be after this time has passed
            front_edge_advance_blade_position = DistanceBladeTravelsInTime(z, left_most_rotor_y, omega, time_corner_4+time_drift_back_rotor_plane-left_most_rotor_time);
            if passed_in_front_of_corner_1 && ...
               passed_in_front_of_corner_4 && ...
               (blade_position + blade_width_y > intercept_y_1) && ...
               (blade_position + blade_width_y > front_edge_advance_blade_position)
                %The front of the blade clears corner 1 and corner 4 of the bird, 
                %and this intercept position is further rotated than either front blade
                %collision, so corner 4 intercepts the back of the blade
                left_most_rotor_y = blade_position + blade_width_y;
                left_most_rotor_time = time_corner_4 + time_drift_back_rotor_plane;
                left_most_collision_point = [blade_depth (intercept_y_4+y_drift_back_rotor_plane) z];
            else %Right edge collision impossible for back of blade
                if chord_angle < theta+pi/2 %Less rotated in positive direction than the 1_4 edge
                    %Find the initial blade position resulting in a collision between the back of the rotor and corner 1
                    blade_position = DistanceBladeTravelsInTime(z, intercept_y_1 + y_drift_back_rotor_plane, -omega, time_corner_1+time_drift_back_rotor_plane);
                    %Check to see if the front of the blade will clear side 1_4 of the bird
                    % and this intercept position is further left than either front blade
                    %collision
                    %Find where the front edge collision would be after this time has passed
                    front_edge_advance_blade_position = DistanceBladeTravelsInTime(z, left_most_rotor_y, omega, time_corner_1+time_drift_back_rotor_plane-left_most_rotor_time);
                    if blade_position + blade_width_y > intercept_y_1 && (blade_position + blade_width_y > front_edge_advance_blade_position)
                        left_most_rotor_y = blade_position + blade_width_y;
                        left_most_rotor_time = time_corner_1 + time_drift_back_rotor_plane;
                        left_most_collision_point = [blade_depth (intercept_y_1+y_drift_back_rotor_plane) z];
                    end
                end
            end
        end
        
        %First, calculate front edge collision points for the rightmost rotor points
        blade_time = TimeForBladeToTravelDistance(z, intercept_y_3, intercept_y_2, omega);
        if (blade_time < (time_corner_3 - time_corner_2)) && chord_angle < theta+pi/2 %Less rotated in positive direction than the 1_4 edge
            %Rotor travels the distance in less time than the 2_3 edge, which means it moves faster, on average
            %than the 2_3 edge, which means that it can clip corner 3 of the bird
            right_most_rotor_y = intercept_y_3;
            right_most_rotor_time = time_corner_3;
        else
            %Rotor travels the distance in equal or more time than the 2_3 edge, which means it moves slower, on average
            %than the 2_3 edge, which means that it cannot clip corner 3 of the bird, and instead hits corner 2
            right_most_rotor_y = intercept_y_2;
            right_most_rotor_time = time_corner_2;
        end
        
        if chord_length > 0
            %Calculate the back of blade collision possibility with corner 3
            blade_position = DistanceBladeTravelsInTime(z, intercept_y_3 + y_drift_back_rotor_plane, -omega, time_corner_3+time_drift_back_rotor_plane);
            %Check to see if the front of the blade will clear corner 2 of the bird on this line of intercept
            [front_passed_behind_2 x_c y_c] = PassBehind(blade_position + blade_width_y, 0, ...
                                                         intercept_y_3 + y_drift_back_rotor_plane + blade_width_y, 0, ...
                                                         initial_y_2, initial_x_2, ...
                                                         initial_y_2 + Vby*(time_corner_3+time_drift_back_rotor_plane), initial_x_2+Vbx*(time_corner_3+time_drift_back_rotor_plane));
            %Check to see if the back of the blade will clear corner 2 of the bird on this line of intercept
            [back_passed_behind_2 x_c y_c] = PassBehind(blade_position , blade_depth, ...
                                                        intercept_y_3 + y_drift_back_rotor_plane, blade_depth, ...
                                                        initial_y_2, initial_x_2, ...
                                                        initial_y_2 + Vby*(time_corner_3+time_drift_back_rotor_plane), initial_x_2+Vbx*(time_corner_3+time_drift_back_rotor_plane));
            %Check to see if the front of the blade will clear corner 3 of the bird on this line of intercept
            [front_passed_behind_3 x_c y_c] = PassBehind(blade_position + blade_width_y, 0, ...
                                                         intercept_y_3 + y_drift_back_rotor_plane + blade_width_y, 0, ...
                                                         initial_y_3, initial_x_3, ...
                                                         initial_y_3 + Vby*(time_corner_3+time_drift_back_rotor_plane), initial_x_3+Vbx*(time_corner_3+time_drift_back_rotor_plane));
            %Find where the front edge collision would be after this time has passed
            front_edge_advance_blade_position = DistanceBladeTravelsInTime(z, right_most_rotor_y, omega, time_corner_3+time_drift_back_rotor_plane-right_most_rotor_time);
            if front_passed_behind_2 && back_passed_behind_2 && front_passed_behind_3 && (intercept_y_3 + y_drift_back_rotor_plane + blade_width_y < front_edge_advance_blade_position)
                %Back blade can hit corner 3
                right_most_rotor_y = intercept_y_3 + y_drift_back_rotor_plane + blade_width_y;
                right_most_rotor_time = time_corner_3 + time_drift_back_rotor_plane;
            elseif chord_angle > theta+pi/2 %More rotated in positive direction than the 1_4 edge
                %Check to see if the back of the blade can strike corner 2
                blade_position = DistanceBladeTravelsInTime(z, intercept_y_2 + y_drift_back_rotor_plane, -omega, time_corner_2+time_drift_back_rotor_plane);
                %Check to see if the front of the blade will clear corner 2 of the bird on this line of intercept
                [passed_behind x_c y_c] = PassBehind(blade_position + blade_width_y, 0, ...
                                                     intercept_y_2 + y_drift_back_rotor_plane + blade_width_y, 0, ...
                                                     initial_y_2, initial_x_2, ...
                                                     initial_y_2 + Vby*(time_corner_2+time_drift_back_rotor_plane), initial_x_2+Vbx*(time_corner_2+time_drift_back_rotor_plane));
                %Find where the front edge collision would be after this time has passed
                front_edge_advance_blade_position = DistanceBladeTravelsInTime(z, right_most_rotor_y, omega, time_corner_2+time_drift_back_rotor_plane-right_most_rotor_time);
                if passed_behind && (intercept_y_2 + y_drift_back_rotor_plane + blade_width_y < front_edge_advance_blade_position)
                    %The front of the blade clears corner 2 meaning that the back of the blade can hit corner 2
                    %and this will result in a less rotated least rotation than the front edge collisions
                    right_most_rotor_y = intercept_y_2 + y_drift_back_rotor_plane + blade_width_y;
                    right_most_rotor_time = time_corner_2 + time_drift_back_rotor_plane;
                end
            end
        end
    end
end

%Calculate the largest psi and the smallest psi that can still clip the bird.
left_most_omega = atan(z/left_most_rotor_y);
if (left_most_omega < 0)
    left_most_omega = left_most_omega + pi;
end
right_most_omega = atan(z/right_most_rotor_y);
if (right_most_omega < 0)
    right_most_omega = right_most_omega + pi;
end
%Now, add in the angle traversed by the blade to intercept the final corner
right_most_omega = right_most_omega + right_most_rotor_time * omega;

delta_omega = left_most_omega - right_most_omega;

if delta_omega <= 0
    foo = 1;
end

%#######################################################
% Calculate the collision probability
%#######################################################
collision_probability = min(B*delta_omega/(2*pi),1);

if z <= hub_radius && z >= -hub_radius
    if left_most_rotor_y < -hub_radius && right_most_rotor_y > hub_radius
        collision_probability = 1;
    elseif left_most_rotor_y >= -hub_radius && left_most_rotor_y <= hub_radius
        collision_probability = 1;
    elseif right_most_rotor_y >= -hub_radius && right_most_rotor_y <= hub_radius
        collision_probability = 1;
    end
end

if plot_flag
    if z > 0
        blade_width_y = -blade_width_y;
    end
    %#######################################################
    % Calculate the location of the bird at the time
    % of the last possible collision
    %#######################################################
    %The y-coordinates of the 5 points on the box at the time of exit with the rotor plane
    y_travel = Vby*left_most_rotor_time;
    x_travel = Vbx*left_most_rotor_time;
    first_collision_y_nose = initial_y_nose + y_travel;
    first_collision_y_1 = initial_y_1 + y_travel;
    first_collision_y_2 = initial_y_2 + y_travel;
    first_collision_y_3 = initial_y_3 + y_travel;
    first_collision_y_4 = initial_y_4 + y_travel;
    %The x-coordinates of the 5 points on the box at the time of contact with the rotor plane
    first_collision_x_nose = initial_x_nose + x_travel;
    first_collision_x_1 = initial_x_1 + x_travel;
    first_collision_x_2 = initial_x_2 + x_travel;
    first_collision_x_3 = initial_x_3 + x_travel;
    first_collision_x_4 = initial_x_4 + x_travel;

    y_first_collision_points = [first_collision_y_1 first_collision_y_nose first_collision_y_2 first_collision_y_3 first_collision_y_4 first_collision_y_1];
    x_first_collision_points = [first_collision_x_1 first_collision_x_nose first_collision_x_2 first_collision_x_3 first_collision_x_4 first_collision_x_1];
    z_first_collision_points = z*ones(1,6);

    %#######################################################
    % Calculate the location of the bird at the time
    % of the last possible collision
    %#######################################################
    %The y-coordinates of the 5 points on the box at the time of exit with the rotor plane
    y_travel = Vby*right_most_rotor_time;
    x_travel = Vbx*right_most_rotor_time;
    last_collision_y_nose = initial_y_nose + y_travel;
    last_collision_y_1 = initial_y_1 + y_travel;
    last_collision_y_2 = initial_y_2 + y_travel;
    last_collision_y_3 = initial_y_3 + y_travel;
    last_collision_y_4 = initial_y_4 + y_travel;
    %The x-coordinates of the 5 points on the box at the time of contact with the rotor plane
    last_collision_x_nose = initial_x_nose + x_travel;
    last_collision_x_1 = initial_x_1 + x_travel;
    last_collision_x_2 = initial_x_2 + x_travel;
    last_collision_x_3 = initial_x_3 + x_travel;
    last_collision_x_4 = initial_x_4 + x_travel;

    y_last_collision_points = [last_collision_y_1 last_collision_y_nose last_collision_y_2 last_collision_y_3 last_collision_y_4 last_collision_y_1];
    x_last_collision_points = [last_collision_x_1 last_collision_x_nose last_collision_x_2 last_collision_x_3 last_collision_x_4 last_collision_x_1];
    z_last_collision_points = z*ones(1,6);
    
%     x_plot_limits = [-R R];
%     y_plot_limits = [-R R];
%     z_plot_limits = [-R R];
    
    x_plot_limits = [-1 1];
    y_plot_limits = [9 11];
    z_plot_limits = [9 11];
    %#######################################################
    %Plot the bird at the point of first contact with the rotor 
    %plane and plot where the corners intersect the rotor plane.
    %#######################################################
    figure;
    hold on
    bird_initial = plot3(x_initial_points,y_initial_points,z_initial_points);
%     bird_final = plot3(x_final_points,y_final_points,z_final_points);
    xlabel('x');ylabel('y');zlabel('z');
    plot3(x_intercept_points, y_intercept_points, z_intercept_points,'*');
    for point_num = 1:5
%         [x_initial_points(point_num) y_initial_points(point_num) ; x_intercept_points(point_num) y_intercept_points(point_num)]
        flight_path = plot3([x_initial_points(point_num) ; x_intercept_points(point_num)], ...
                            [y_initial_points(point_num) ; y_intercept_points(point_num)], ...
                            [z_initial_points(point_num) ; z_intercept_points(point_num)], 'r-*');
    end
    center_point = [mean(x_initial_points([1 3:5])) mean(y_initial_points([1 3:5])) mean(z_initial_points([1 3:5]))];
    %Plot these interception points on the figure;
    left_most = plot3(0,left_most_rotor_y,z,'go');
    set(left_most,'lineWidth',2);
    right_most = plot3(0,right_most_rotor_y,z,'ko');
    set(right_most,'lineWidth',2);
    rotor = plot3([0 blade_depth],[left_most_rotor_y left_most_rotor_y-blade_width_y],[z z],'k');
    set(rotor,'lineWidth',2);
    plot3([center_point(1) ; x_initial_points(2)], [center_point(2) ; y_initial_points(2)], [center_point(3) ; z_initial_points(2)],'r');
    turbine_circumference = linspace(0,2*pi,200);
    front_turbine_edge = plot3(zeros(1,200),R*cos(turbine_circumference),R*sin(turbine_circumference),'g');
    back_turbine_edge = plot3(ones(1,200)*blade_depth,R*cos(turbine_circumference),R*sin(turbine_circumference),'g');
    set(front_turbine_edge,'lineWidth',2);
    hub_circumference = linspace(0,2*pi,200);
    hub_edge = plot3(zeros(1,200),hub_radius*cos(hub_circumference),hub_radius*sin(hub_circumference),'k');
    set(hub_edge,'lineWidth',2);
%     set(gca,'YDir','reverse');
%     L = legend([bird_initial left_most right_most turbine_edge hub_edge],'Bird Entering Rotor Plane','First Possible Intercept','Last Possible Intercept','Turbine Boundary','Hub Boundary','Location','NorthEast');
%     legend boxoff
%     set(L,'FontSize',12)
    title(['Collision Probability: ' num2str(collision_probability)]);
    set(gca,'FontSize',12)
%     view([0 0 -10])
    set(gca,'View',[90 -90])
    xlim(x_plot_limits)
    ylim(y_plot_limits)
    zlim(z_plot_limits)
    
    %#######################################################
    %Plot the bird at the point of the most rotated collision
    %#######################################################
    figure;
    hold on
    bird_initial = plot3(x_initial_points,y_initial_points,z_initial_points,'--b');
    bird_final = plot3(x_first_collision_points,y_first_collision_points,z_first_collision_points);
    xlabel('x');ylabel('y');zlabel('z');
    ylim([-R R]);
    xlim([-R R]);
    zlim([-R R]);
    for point_num = 1:5
        flight_path = plot3([x_initial_points(point_num) ; x_first_collision_points(point_num)], ...
                            [y_initial_points(point_num) ; y_first_collision_points(point_num)], ...
                            [z_initial_points(point_num) ; z_first_collision_points(point_num)], 'r-*');
    end
    center_point = [mean(x_first_collision_points([1 3:5])) mean(y_first_collision_points([1 3:5])) mean(z_first_collision_points([1 3:5]))];
    %Plot these interception points on the figure;
    left_most = plot3(left_most_collision_point(1),left_most_collision_point(2),left_most_collision_point(3),'go');
    set(left_most,'lineWidth',2);
    if left_most_collision_point(1) > 0 %Back of rotor collision
        rotor = plot3([0 blade_depth],[(left_most_collision_point(2)+blade_width_y) left_most_collision_point(2)],[z z],'k');
        set(rotor,'lineWidth',2);
    else %Front of rotor collision
        rotor = plot3([0 blade_depth],[left_most_collision_point(2) (left_most_collision_point(2)-blade_width_y)],[z z],'k');
        set(rotor,'lineWidth',2);
    end
    path = plot3([center_point(1) ; x_first_collision_points(2)], [center_point(2) ; y_first_collision_points(2)], [center_point(3) ; z_first_collision_points(2)],'r');
    turbine_circumference = linspace(0,2*pi,200);
    front_turbine_edge = plot3(zeros(1,200),R*cos(turbine_circumference),R*sin(turbine_circumference),'g');
    back_turbine_edge = plot3(ones(1,200)*blade_depth,R*cos(turbine_circumference),R*sin(turbine_circumference),'g');
    set(front_turbine_edge,'lineWidth',2);
    hub_circumference = linspace(0,2*pi,200);
    hub_edge = plot3(zeros(1,200),hub_radius*cos(hub_circumference),hub_radius*sin(hub_circumference),'k');
    set(hub_edge,'lineWidth',2);
%     set(gca,'YDir','reverse');
%     L = legend([bird_final right_most turbine_edge hub_edge],'Bird At Last Possible Collision','Last Possible Intercept','Turbine Boundary','Hub Boundary','Location','NorthEast');
%     legend boxoff
%     set(L,'FontSize',12)
    title(['Collision Probability: ' num2str(collision_probability)]);
    set(gca,'FontSize',12)
%     view([0 0 -10])
    set(gca,'View',[90 -90])
    xlim(x_plot_limits)
    ylim(y_plot_limits)
    zlim(z_plot_limits)
    
    %#######################################################
    %Plot the bird at the point of the least rotated collision
    %#######################################################
    figure;
    hold on
    bird_initial = plot3(x_initial_points,y_initial_points,z_initial_points,'--b');
    bird_final = plot3(x_last_collision_points,y_last_collision_points,z_last_collision_points);
    xlabel('x');ylabel('y');zlabel('z');
    ylim([-R R]);
    xlim([-R R]);
    zlim([-R R]);
    for point_num = 1:5
        flight_path = plot3([x_initial_points(point_num) ; x_last_collision_points(point_num)], ...
                            [y_initial_points(point_num) ; y_last_collision_points(point_num)], ...
                            [z_initial_points(point_num) ; z_last_collision_points(point_num)], 'r-*');
    end
    center_point = [mean(x_last_collision_points([1 3:5])) mean(y_last_collision_points([1 3:5])) mean(z_last_collision_points([1 3:5]))];
    right_most = plot3(0,right_most_rotor_y,z,'ko');
    rotor = plot3([0 blade_depth],[right_most_rotor_y right_most_rotor_y-blade_width_y],[z z],'k');
    set(rotor,'lineWidth',2);
    set(right_most,'lineWidth',2);
    path = plot3([center_point(1) ; x_last_collision_points(2)], [center_point(2) ; y_last_collision_points(2)], [center_point(3) ; z_last_collision_points(2)],'r');
    turbine_circumference = linspace(0,2*pi,200);
    front_turbine_edge = plot3(zeros(1,200),R*cos(turbine_circumference),R*sin(turbine_circumference),'g');
    back_turbine_edge = plot3(ones(1,200)*blade_depth,R*cos(turbine_circumference),R*sin(turbine_circumference),'g');
    set(front_turbine_edge,'lineWidth',2);
    hub_circumference = linspace(0,2*pi,200);
    hub_edge = plot3(zeros(1,200),hub_radius*cos(hub_circumference),hub_radius*sin(hub_circumference),'k');
    set(hub_edge,'lineWidth',2);
%     set(gca,'YDir','reverse');
%     L = legend([bird_final right_most turbine_edge hub_edge],'Bird At Last Possible Collision','Last Possible Intercept','Turbine Boundary','Hub Boundary','Location','NorthEast');
%     legend boxoff
%     set(L,'FontSize',12)
    title(['Collision Probability: ' num2str(collision_probability)]);
    set(gca,'FontSize',12)
%     view([0 0 -10])
    set(gca,'View',[90 -90])
    xlim(x_plot_limits)
    ylim(y_plot_limits)
    zlim(z_plot_limits)
end

% foo = 1;





