function [return_probabilities ...
          angle_of_orientation_degrees ...
          mean_probability ...
          mean_aperture_probability] = TurbineCollision(bird_wingspan, ... %Meters
                                                       bird_length, ... %Meters
                                                       n_blades, ...
                                                       turbine_radius, ... %Meters
                                                       hub_radius, ... %Meters
                                                       angular_velocity, ... %RPMs
                                                       maximum_blade_chord_length, ... %Meters
                                                       blade_chord_length_at_hub, ... %Meters
                                                       axial_induction, ...
                                                       wind_speed, ... %Meters/Second
                                                       wind_direction, ... %Degrees clockwise from 12:00
                                                       bird_speed, ... %Meters/Second, relative to ground
                                                       bird_direction, ... %Degrees clockwise from 12:00 of the flightpath
                                                       plot_type, ... %0:no_plot, 1:turbine, 2:bird
                                                       resolution, ... %Pixels/Meter
                                                       model_type, ...
                                                       y_dim, ... %Meters
                                                       z_dim) %Meters

pixels = round(resolution * 2 * turbine_radius);
%Convert angular velocity from rpm's to rad/s
angular_velocity = 2*pi*angular_velocity/60; 
R = turbine_radius;
mean_probability = 0;
mean_aperture_probability = 0;

[angle_of_orientation_degrees ...
 bird_downwind_relative_direction_radians ...
 Vbx ...
 Vby ...
 Vx] = BirdOrientation(bird_direction, ...
                       bird_speed, ...
                       wind_direction, ...
                       wind_speed, ...
                       axial_induction);

if plot_type == 2
    plot_individual_bird_collisions = false;
    oblique_p = ObliqueCollisionProbability(n_blades, ...
                                            hub_radius, ...
                                            bird_length, ...
                                            bird_wingspan, ...
                                            angular_velocity, ...
                                            maximum_blade_chord_length, ... %Meters
                                            blade_chord_length_at_hub, ... %Meters
                                            R, ...
                                            angle_of_orientation_degrees, ...
                                            Vx, ...
                                            Vby, ...
                                            y_dim, ...
                                            z_dim, ...
                                            plot_individual_bird_collisions);
                                        
                                        
    return_probabilities = oblique_p;
else
    oblique_probabilities = zeros(pixels,pixels);
    y_samples = linspace(-R,R,pixels);
    z_samples = linspace(-R,R,pixels);
    summed_probabilities = 0;
    num_summed_probabilities = 0;
    
    if model_type == 0 %Hamer
        for y_idx = 1:pixels
            for z_idx = 1:pixels
                y = y_samples(y_idx);
                y = y/cos(bird_downwind_relative_direction_radians);
                z = z_samples(z_idx);
                r = sqrt(y^2 + z^2);
                if r <= R %&& r > r0
                    oblique_p = ObliqueCollisionProbability(n_blades, ...
                                                            hub_radius, ...
                                                            bird_length, ...
                                                            bird_wingspan, ...
                                                            angular_velocity, ...
                                                            maximum_blade_chord_length, ... %Meters
                                                            blade_chord_length_at_hub, ... %Meters
                                                            R, ...
                                                            angle_of_orientation_degrees, ...
                                                            Vx, ...
                                                            Vby, ...
                                                            y, ...
                                                            z, ...
                                                            0);

                    oblique_probabilities(z_idx,y_idx) = oblique_p;
                    summed_probabilities = summed_probabilities + oblique_p;
                    num_summed_probabilities = num_summed_probabilities + 1;
                end
            end
        end
    elseif model_type == 1 %Tucker
        for y_idx = 1:pixels
            for z_idx = 1:pixels
                y = y_samples(y_idx);
                y = y/cos(bird_downwind_relative_direction_radians);
                z = z_samples(z_idx);
                r = sqrt(y^2 + z^2);
                if r <= R %&& r > r0
                    p = TuckerCollisionProbability(n_blades, ... %Number of blades
                                                   hub_radius, ...
                                                   bird_length, ...
                                                   bird_wingspan, ...
                                                   angular_velocity, ...
                                                   maximum_blade_chord_length, ... %Meters
                                                   blade_chord_length_at_hub, ... %Meters
                                                   R, ...
                                                   Vx, ...%Bird's velocity in the x-direction
                                                   y, ...
                                                   z);

                    oblique_probabilities(z_idx,y_idx) = p;
                    summed_probabilities = summed_probabilities + p;
                    num_summed_probabilities = num_summed_probabilities + 1;
                end
            end
        end
    else
        for y_idx = 1:pixels %Podolsky
            for z_idx = 1:pixels
                y = y_samples(y_idx);
                y = y/cos(bird_downwind_relative_direction_radians);
                z = z_samples(z_idx);
                r = sqrt(y^2 + z^2);
                if r <= R %&& r > r0
                    p = PodolskiCollisionProbability(n_blades, ... %Number of blades
                                                     hub_radius, ...
                                                     bird_length, ...
                                                     bird_wingspan, ...
                                                     angular_velocity, ... %Rads/s
                                                     maximum_blade_chord_length, ... %Meters
                                                     blade_chord_length_at_hub, ... %Meters
                                                     bird_downwind_relative_direction_radians, ... %Naive angle of attack
                                                     R, ...
                                                     Vx, ...%Bird's velocity in the x-direction
                                                     y, ...
                                                     z);

                    oblique_probabilities(z_idx,y_idx) = p;
                    summed_probabilities = summed_probabilities + p;
                    num_summed_probabilities = num_summed_probabilities + 1;
                end
            end
        end
    end

    %For comparing the different modeling approaches, this calculates the number of pixels
    %that fall within the "aperture" of the perfect turbine circle.
    num_summed_aperture_probabilities = 0;
    for y_idx = 1:pixels
        for z_idx = 1:pixels
            y = y_samples(y_idx);
            z = z_samples(z_idx);
            r = sqrt(y^2 + z^2);
            if r <= R %&& r > r0
                num_summed_aperture_probabilities = num_summed_aperture_probabilities + 1;
            end
        end
    end
    
    mean_probability = summed_probabilities / num_summed_probabilities;
    mean_aperture_probability = summed_probabilities / num_summed_aperture_probabilities;
    
    if plot_type == 1
        % Plot color figure
        figure;
        imagesc(y_samples,z_samples,oblique_probabilities);
        hold on
        [c h] = contour(y_samples,z_samples,oblique_probabilities);
        set(h,'LineColor','k');
        contour_handle = clabel(c,h,0:0.1:1);
        set(h,'LevelList',0:0.1:1)
        circumference = linspace(0,2*pi,pixels);
        set(gca,'YDir','normal');
        h = plot(R*cos(circumference)*cos(bird_downwind_relative_direction_radians),R*sin(circumference),'w');
        set(h,'lineWidth',2);
        xlabel('y');
        ylabel('z');
        caxis([0 1]);
        colorbar
%         title({'Collision Probability Contours For an Individual Turbine',...
%                ['Mean Collision Probability: ' num2str(mean_probability)],...
%                ['Mean Rotation Adjusted Collision Probability: ' num2str(mean_aperture_probability)]});
        PrintFigure('Color_Turbine','epsc2',4.1,3.1);   
        % Plot black and white figure
        figure;
        hold on
        [c h] = contour(y_samples,z_samples,oblique_probabilities);
        set(h,'LineColor','k');
        clabel(c,h,0:0.1:1);
        circumference = linspace(0,2*pi,pixels);
        set(gca,'YDir','normal');
        h = plot(R*cos(circumference)*cos(bird_downwind_relative_direction_radians),R*sin(circumference),'k');
        set(h,'lineWidth',2);
        xlabel('y');
        ylabel('z');
%         title({'Collision Probability Contours For an Individual Turbine',...
%                ['Mean Collision Probability: ' num2str(mean_probability)],...
%                ['Mean Rotation Adjusted Collision Probability: ' num2str(mean_aperture_probability)]});
        PrintFigure('BW_Turbine','epsc2',3.7,3.5);    
    end
    return_probabilities = oblique_probabilities;
end

%Return the birds orientation relative to 12:00, not downwind.
angle_of_orientation_degrees = angle_of_orientation_degrees + wind_direction;