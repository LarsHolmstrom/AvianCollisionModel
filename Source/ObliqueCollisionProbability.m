function collision_probability = ObliqueCollisionProbability(B, ... %Number of blades
                                                             hub_radius, ...
                                                             bird_length, ...
                                                             bird_wingspan, ...
                                                             omega, ...
                                                             maximum_blade_chord_length, ... %Meters
                                                             blade_chord_length_at_hub, ... %Meters
                                                             R, ...
                                                             theta_degrees, ...
                                                             Vbx, ...%Bird's velocity in the x-direction
                                                             Vby, ...%Bird's velocity in the y-direction
                                                             y, ... %The y position as if you were looking directly downwind
                                                             z, ...
                                                             plot_flag, ...
                                                             rotor_pitch) % Degrees. Additional, wind determined rotation of the turbine blade
      
%Convert theta to radians
theta = theta_degrees/360*2*pi;

%Distance from the center of the hub
r = sqrt(y^2 + z^2);

%The length of the bird
length = bird_length;
%The width of the bird
width = bird_wingspan;

%If the bird is travelling upwind, invert the z component to place the bird
%on the opposite side of the z axis, rectify the ground velocity of the bird
%as if it is going downwind, and adjust theta.
upwind = false;
if (Vbx < 0)
%     assert(theta >= pi); % Flying backwards
    Vbx = abs(Vbx);
%     theta = mod(theta+pi,pi);
    theta = -(theta-pi);
    z = -z;
    upwind = true;
end

if abs(theta) >= pi/2
%     error_string = {'Improbable input parameters. Bird would be flying backwards.',...
%                     'Check Wind & Bird Speeds and Directions'};
%     errordlg(error_string,'Error');
    display('Improbable input parameters. Bird would be flying backwards.');
    collision_probability = nan;
    return
end

%Constrain theta to be -pi <= theta <= pi
theta = rem(theta,2*pi);
if theta > pi
    theta = theta - 2*pi;
elseif theta < -pi
    theta = theta + 2*pi;
end

% There may be divide by zero warnings here, but
% atan(Inf) and atan(-Inf) seem to do the right thing.
psi = atan(z/y);
if (y < 0)
    psi = psi + pi;
end
if isnan(psi)
    psi = 0;
end

if r>R
    %If the bird's nose enters the rotor plane outside of the radius of
    %the rotor, use the chord characteristics of the edge of the rotor.
    [chord_length,chord_angle] = ChordCharacteristics(R,maximum_blade_chord_length,blade_chord_length_at_hub,R);
else
    [chord_length,chord_angle] = ChordCharacteristics(R,maximum_blade_chord_length,blade_chord_length_at_hub,r);
end


if nargin == 15
    chord_angle = chord_angle + rotor_pitch;
end

if chord_angle > 90
    assert(chord_angle <= 180);
    amount_over = chord_angle - 90;
    positive_projection = chord_angle - amount_over;
    chord_angle = positive_projection;
end
    
chord_angle = chord_angle/360*2*pi;
blade_depth = abs(chord_length*sin(chord_angle));
blade_width = abs(chord_length*cos(chord_angle)); %Tangent to rotation

assert(chord_angle <= pi/2 && chord_angle >=0);

% blade_width_y = abs(blade_width*sin(psi));
blade_width_y = abs(blade_width/sin(psi));
blade_arc_width = 2*atan(blade_width/2/r);
if isnan(blade_arc_width)
    blade_arc_width = 0;
end
assert(blade_arc_width >= 0);

% Make chord angle on same rotational coordinate space as the bird
if z >= 0
    chord_angle = -abs(chord_angle);
end

%Time drift and y-drift to back of rotor plane
time_drift_back_rotor_plane = blade_depth/Vbx;
y_drift_back_rotor_plane =  Vby*time_drift_back_rotor_plane;

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
    
    if z < 0
        assert(chord_angle >= 0 && chord_angle <= pi/2)
        %First, calculate front edge collision points
        %Check for collision between front of blade and corner 1 of the bird
        blade_position = DistanceBladeTravelsInTime(z, intercept_y_1, -omega, time_corner_1);
        if blade_position > intercept_y_2
            most_rotated_rotor_y = blade_position;
            most_rotated_rotor_time = time_corner_1;
            most_rotated_collision_point = [0 intercept_y_1 z];
        else
            most_rotated_rotor_y = intercept_y_2;
            most_rotated_rotor_time = time_corner_2;
            most_rotated_collision_point = [0 intercept_y_2 z];
        end
        
        %First, calculate front edge collision points for the rightmost rotor points
        blade_position = DistanceBladeTravelsInTime(z, intercept_y_4, -omega, (time_corner_4 - time_corner_3));
        if (blade_position < intercept_y_3)
            least_rotated_rotor_y = intercept_y_4;
            least_rotated_rotor_time = time_corner_4;
        else
            least_rotated_rotor_y = intercept_y_3;
            least_rotated_rotor_time = time_corner_3;
        end
    else %z > 0
        assert(chord_angle <= 0 && chord_angle >= -pi/2)
        %First, calculate front edge collision points
        %Check for collision between front of blade and corner 2 of the bird
        blade_position = DistanceBladeTravelsInTime(z, intercept_y_3, -omega, time_corner_3);
        if blade_position < intercept_y_2
            most_rotated_rotor_y = blade_position;
            most_rotated_rotor_time = time_corner_3;
            most_rotated_collision_point = [0 intercept_y_3 z];
        else
            most_rotated_rotor_y = intercept_y_2;
            most_rotated_rotor_time = time_corner_2;
            most_rotated_collision_point = [0 intercept_y_2 z];
        end
        
        %First, calculate front edge collision points for the rightmost rotor points
        blade_position = DistanceBladeTravelsInTime(z, intercept_y_4, -omega, (time_corner_4 - time_corner_1));
        if (blade_position > intercept_y_1)
            least_rotated_rotor_y = intercept_y_4;
            least_rotated_rotor_time = time_corner_4;
        else
            least_rotated_rotor_y = intercept_y_1;
            least_rotated_rotor_time = time_corner_1;
        end
    end
else %theta <= 0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Start Calculations for case where bird is moving to the left
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
    
    if (y_drift_back_rotor_plane > 0)
        error('Drift should be positive');
    end
    
    if z >= 0
        assert(chord_angle <= 0 && chord_angle >= -pi/2)
        %First, calculate front edge collision points
        %Check for collision between front of blade and corner 2 of the bird
        blade_position = DistanceBladeTravelsInTime(z, intercept_y_2, -omega, time_corner_2);
        if blade_position < intercept_y_1
            most_rotated_rotor_y = blade_position;
            most_rotated_rotor_time = time_corner_2;
            most_rotated_collision_point = [0 intercept_y_2 z];
        else
            most_rotated_rotor_y = intercept_y_1;
            most_rotated_rotor_time = time_corner_1;
            most_rotated_collision_point = [0 intercept_y_1 z];
        end
        
        %First, calculate front edge collision points for the rightmost rotor points
        blade_position = DistanceBladeTravelsInTime(z, intercept_y_3, -omega, (time_corner_3 - time_corner_4));
        if (blade_position > intercept_y_4)
                least_rotated_rotor_y = intercept_y_3;
                least_rotated_rotor_time = time_corner_3;
        else
                least_rotated_rotor_y = intercept_y_4;
                least_rotated_rotor_time = time_corner_4;
        end
        
    else %z<0
        assert(chord_angle >= 0 && chord_angle <= pi/2)
        %First, calculate front edge collision points
        blade_position = DistanceBladeTravelsInTime(z, intercept_y_4, -omega, time_corner_4);
        if blade_position > intercept_y_1
            most_rotated_rotor_y = blade_position;
            most_rotated_rotor_time = time_corner_4;
            most_rotated_collision_point = [0 intercept_y_4 z];
        else
            most_rotated_rotor_y = intercept_y_1;
            most_rotated_rotor_time = time_corner_1;
            most_rotated_collision_point = [0 intercept_y_1 z];
        end
        
        %First, calculate front edge collision points for the rightmost rotor points
        blade_position = DistanceBladeTravelsInTime(z, intercept_y_3, -omega, (time_corner_3 - time_corner_2));
        if (blade_position < intercept_y_2)
            least_rotated_rotor_y = intercept_y_3;
            least_rotated_rotor_time = time_corner_3;
        else
            least_rotated_rotor_y = intercept_y_2;
            least_rotated_rotor_time = time_corner_2;
        end
    end
end

% Keep the maximum and minimum values on the unit circle
least_rotated_rotor_y = max(min_y,min(max_y,least_rotated_rotor_y));
most_rotated_rotor_y = max(min_y,min(max_y,most_rotated_rotor_y));

if least_rotated_rotor_y ~= most_rotated_rotor_y
    %#######################################################
    %Calculate the largest psi and the smallest psi that can still clip the bird.
    %#######################################################
    most_rotated_psi = atan(z/most_rotated_rotor_y);
    if (most_rotated_psi < 0)
        most_rotated_psi = most_rotated_psi + pi;
    end
    least_rotated_psi = atan(z/least_rotated_rotor_y);
    if (least_rotated_psi < 0)
        least_rotated_psi = least_rotated_psi + pi;
    end
    %Now, add in the angle traversed by the blade to intercept the final corner
    least_rotated_psi = least_rotated_psi + least_rotated_rotor_time * omega;
    
    delta_psi = most_rotated_psi - least_rotated_psi;

    %Now, add in the 3d rotor correction
    %Note, this is the arc width of the rotor minus the arc-travel in the time
    %it takes to pass from the front rotor plane to the back rotor plane.
    %The addition is here because omega is negative.
    most_rotated_y_drift = atan(z/(intercept_y_nose-y_drift_back_rotor_plane));
    if (most_rotated_y_drift < 0)
        most_rotated_y_drift = most_rotated_y_drift + pi;
    end
    least_rotated_y_drift = atan(z/(intercept_y_nose+y_drift_back_rotor_plane));
    if (least_rotated_y_drift < 0)
        least_rotated_y_drift = least_rotated_y_drift + pi;
    end
    y_drift_arc_length = most_rotated_y_drift - least_rotated_y_drift;
    %Add or subtract the y_drift_arc_length depending on the angle of
    %sapproach and the quadrant on the turbine.
    if theta < 0
        if z > 0
            assert(y_drift_arc_length <= 0);
            y_drift_arc_length = -abs(y_drift_arc_length);
        else
            assert(y_drift_arc_length >= 0);
            y_drift_arc_length = abs(y_drift_arc_length);
        end
    elseif theta > 0
        if z > 0
            assert(y_drift_arc_length >= 0);
            y_drift_arc_length = abs(y_drift_arc_length);
        else
            assert(y_drift_arc_length <= 0);
            y_drift_arc_length = -abs(y_drift_arc_length);
        end
    else
        assert(y_drift_arc_length == 0);
    end
    rotor_3d_correction = abs(blade_arc_width + y_drift_arc_length + time_drift_back_rotor_plane*omega);
    delta_psi = delta_psi + rotor_3d_correction;
    %#######################################################
    % Calculate the collision probability
    %#######################################################
    collision_probability = min(B*delta_psi/(2*pi),1);
else
    %Bird doesn't intersect rotor
    collision_probability = 0;
end

if z <= hub_radius && z >= -hub_radius
    hub_width_at_z = sqrt(hub_radius^2 - z^2);
    if most_rotated_rotor_y < -hub_width_at_z && least_rotated_rotor_y > hub_width_at_z
        collision_probability = 1;
    elseif most_rotated_rotor_y >= -hub_width_at_z && most_rotated_rotor_y <= hub_width_at_z
        collision_probability = 1;
    elseif least_rotated_rotor_y >= -hub_width_at_z && least_rotated_rotor_y <= hub_width_at_z
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
    y_travel = Vby*most_rotated_rotor_time;
    x_travel = Vbx*most_rotated_rotor_time;
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
    y_travel = Vby*least_rotated_rotor_time;
    x_travel = Vbx*least_rotated_rotor_time;
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
    
    x_plot_limits = [-R R];
    y_plot_limits = [-R R];
    z_plot_limits = [-R R];
    
%     x_plot_limits = [-1 1];
%     y_plot_limits = [9 11];
%     z_plot_limits = [9 11];
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
    most_rotated = plot3(0,most_rotated_rotor_y,z,'go');
    set(most_rotated,'lineWidth',2);
    least_rotated = plot3(0,least_rotated_rotor_y,z,'ko');
    set(least_rotated,'lineWidth',2);
    rotor = plot3([0 blade_depth],[most_rotated_rotor_y most_rotated_rotor_y-blade_width_y],[z z],'k');
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
    L = legend([bird_initial most_rotated least_rotated front_turbine_edge hub_edge],'Bird Entering Rotor Plane','First Possible Intercept','Last Possible Intercept','Turbine Boundary','Hub Boundary','Location','NorthEast');
    legend boxoff
    set(L,'FontSize',12)
    title(['Birt at time of intersection with the rotor plane. Collision Probability: ' num2str(collision_probability)]);
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
    most_rotated = plot3(most_rotated_collision_point(1),most_rotated_collision_point(2),most_rotated_collision_point(3),'go');
    set(most_rotated,'lineWidth',2);
    if most_rotated_collision_point(1) > 0 %Back of rotor collision
        rotor = plot3([0 blade_depth],[(most_rotated_collision_point(2)+blade_width_y) most_rotated_collision_point(2)],[z z],'k');
        set(rotor,'lineWidth',2);
    else %Front of rotor collision
        rotor = plot3([0 blade_depth],[most_rotated_collision_point(2) (most_rotated_collision_point(2)-blade_width_y)],[z z],'k');
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
    L = legend([bird_final least_rotated front_turbine_edge hub_edge],'Bird At Last Possible Collision','Last Possible Intercept','Turbine Boundary','Hub Boundary','Location','NorthEast');
    legend boxoff
    set(L,'FontSize',12)
    title(['Bird at the time of the most rotated collision. Collision Probability: ' num2str(collision_probability)]);
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
    least_rotated = plot3(0,least_rotated_rotor_y,z,'ko');
    rotor = plot3([0 blade_depth],[least_rotated_rotor_y least_rotated_rotor_y-blade_width_y],[z z],'k');
    set(rotor,'lineWidth',2);
    set(least_rotated,'lineWidth',2);
    path = plot3([center_point(1) ; x_last_collision_points(2)], [center_point(2) ; y_last_collision_points(2)], [center_point(3) ; z_last_collision_points(2)],'r');
    turbine_circumference = linspace(0,2*pi,200);
    front_turbine_edge = plot3(zeros(1,200),R*cos(turbine_circumference),R*sin(turbine_circumference),'g');
    back_turbine_edge = plot3(ones(1,200)*blade_depth,R*cos(turbine_circumference),R*sin(turbine_circumference),'g');
    set(front_turbine_edge,'lineWidth',2);
    hub_circumference = linspace(0,2*pi,200);
    hub_edge = plot3(zeros(1,200),hub_radius*cos(hub_circumference),hub_radius*sin(hub_circumference),'k');
    set(hub_edge,'lineWidth',2);
%     set(gca,'YDir','reverse');
    L = legend([bird_final least_rotated front_turbine_edge hub_edge],'Bird At Last Possible Collision','Last Possible Intercept','Turbine Boundary','Hub Boundary','Location','NorthEast');
    legend boxoff
    set(L,'FontSize',12)
    title(['Bird at the time of the least rotated collision. Collision Probability: ' num2str(collision_probability)]);
    set(gca,'FontSize',12)
%     view([0 0 -10])
    set(gca,'View',[90 -90])
    xlim(x_plot_limits)
    ylim(y_plot_limits)
    zlim(z_plot_limits)
end

% foo = 1;





