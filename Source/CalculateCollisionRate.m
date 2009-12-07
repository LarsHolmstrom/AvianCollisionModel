function collision_rate = CalculateCollisionRate(windfarm_probabilities, ...
                                                 x_ticks, ...
                                                 y_ticks, ...
                                                 distribution_type, ...
                                                 distribution_param_1, ...mean_bird_height, ...
                                                 distribution_param_2, ...variance_bird_height, ...
                                                 bird_frequency, ...
                                                 avoidance_rate, ...
                                                 survey_width, ...
                                                 plot_flag)
                                             
[size_y size_x] = size(windfarm_probabilities);
y_tick_sampling_interval = y_ticks(2) - y_ticks(1);

if distribution_type == 0 % Gaussian
    mean_bird_height = distribution_param_1;
    variance_bird_height = distribution_param_2;
    %Normalized normal distribution about the mean_bird_height
    %Takes into account the sampling interval.
    weights = 1/(sqrt(variance_bird_height*2*pi))*exp(-(y_ticks - mean_bird_height).^2 / (2 * variance_bird_height))*y_tick_sampling_interval;
    %Replicate across the x-dimension of the winfarm collision area.
    %This is a 2-dimesional pdf which is consant across the x-dimension and
    %gaussian in the y-dimension.
    location_probabilities = repmat(weights(:),1,size_x);
    %Normalize it so that it sums to one across 2-d collision area. 
    normalized_location_probabilities = location_probabilities./size_x;
elseif distribution_type == 1 % Uniform
    min_bird_height = distribution_param_1;
    max_bird_height = distribution_param_2;
    weights = zeros(1,size_y);
    bird_path = intersect(find(y_ticks >= min_bird_height),find(y_ticks <= max_bird_height));
    weights(bird_path) = 1;
    weights = weights/sum(weights);
    %Replicate across the x-dimension of the winfarm collision area.
    %This is a 2-dimesional pdf which is consant across the x-dimension and
    %uniform in the y-direction over the specified range
    location_probabilities = repmat(weights(:),1,size_x);
    %Calculate the percentage of the distribution that is above the height specified by y_ticks(end)
    amount_above_y_ticks = max_bird_height - y_ticks(end);
    if amount_above_y_ticks > 0
        total_range = max_bird_height - min_bird_height;
        overlap_fraction = 1 - (amount_above_y_ticks/total_range);
    else
        overlap_fraction = 1;
    end
    %Normalize it so that it sums to overlap_fraction across 2-d collision area. 
    normalized_location_probabilities = overlap_fraction*location_probabilities./size_x;
end

if survey_width > 0
    %Account for the fact that the collision area is only a fraction of
    %the area being surveyed. Assume a uniform distribution across the
    %whole survey area.
    windfarm_fraction_of_survey_width = (x_ticks(end) - x_ticks(1)) / survey_width;
    normalized_location_probabilities = normalized_location_probabilities ...
                                        .* windfarm_fraction_of_survey_width;
end

flightpath_windfarm_combined_probability = windfarm_probabilities ...
                                           .* normalized_location_probabilities;
                                       
%Integrate over the whole collision area to find the probability of a single
%bird colliding with a tower or turbine.
per_bird_collision_probability = sum(sum(flightpath_windfarm_combined_probability));

%Account for both the passage rate of the birds and the avoidance rate.
collision_rate = per_bird_collision_probability * bird_frequency * (1 - avoidance_rate/100);


if plot_flag
    figure;
    imagesc(x_ticks,y_ticks,windfarm_probabilities*100);
    set(gca,'YDir','normal');
    caxis([0 100]);
    colorbar
    axis image
    map = 1-bone;
    colormap(map)
%     title({'Wind Farm Collision Probabilities','from the Flightpath Perspective'});
    title({'Collision Probabilities','from the Flightpath Perspective'});
    xlabel('Meters');
    ylabel('Meters');
    
    plot_grid = true;
    if plot_grid
        blackX = [];
        blackY = [];
        whiteX = [];
        whiteY = [];
        for iX = 1:30:length(x_ticks)
            for iY = 1:30:length(y_ticks)
                if windfarm_probabilities(iY,iX) == 1
                    whiteX = [whiteX x_ticks(iX)];
                    whiteY = [whiteY y_ticks(iY)];
                else
                    blackX = [blackX x_ticks(iX)];
                    blackY = [blackY y_ticks(iY)];
                end
            end
        end
        hold on
        p = plot(blackX,blackY,'.r');
        set(p,'MarkerSize',4);
        p = plot(whiteX,whiteY,'.r');
        set(p,'MarkerSize',4);
    end
    
    figure;
    imagesc(x_ticks,y_ticks,normalized_location_probabilities);
    set(gca,'YDir','normal');
%     colorbar
    axis image
    title({'Bird Flighpath Probability Density','in Windfarm Coverage Area'});
    xlabel('Meters');
    ylabel('Meters');
    
    figure;
    imagesc(x_ticks,y_ticks,flightpath_windfarm_combined_probability);
    set(gca,'YDir','normal');
%     colorbar
    axis image
    title({'Combined Flighpath/Windfarm Collision Probability Density', ...
           ['Estimated Collision Rate: ' num2str(collision_rate) ' birds/year']});
    xlabel('Meters');
    ylabel('Meters');
end

                                                 