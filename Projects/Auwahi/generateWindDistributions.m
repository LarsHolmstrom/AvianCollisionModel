function [wind_directions wind_speeds] =  SimulateWindData(wind_data)

nSimulations = 100;
wind_directions = nan(1,nSimulations);
wind_speeds = nan(1,nSimulations);

for i = 1:nSimulations
    roll = rand(1,1)
    if roll<0.16
        filtered_wind_data = wind_data(find(wind_data < 4));
        wind_directions(i) = roll * 360/0.16;
    elseif roll<0.56
        filtered_wind_data = wind_data(intersect(find(wind_data < 0.95*max(wind_data(:), find(wind_data >= 4)))));
        wind_directions(i) = rand(1,1)*22.5 + 56.25;
    else
        filtered_wind_data = wind_data(find(wind_data >= 4));
        wind_directions(i) = rand(1,1)*22.5 + 78.75;
    end
end