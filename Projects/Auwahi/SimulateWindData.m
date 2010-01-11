function [wind_directions wind_speeds] =  SimulateWindData(wind_data)

nSimulations = 10000;
wind_directions = nan(1,nSimulations);
wind_speeds = nan(1,nSimulations);

slowWind = wind_data(find(wind_data < 4));
fastWind = wind_data(intersect(find(wind_data < 0.8*max(wind_data(:))), find(wind_data >= 4)));
fastestWind = wind_data(find(wind_data >= 4));

[slowWindCDF slowWindIntervals] = ksdensity(slowWind,'function','cdf');
[fastWindCDF fastWindIntervals] = ksdensity(fastWind,'function','cdf');
[fastestWindCDF fastestWindIntervals] = ksdensity(fastestWind,'function','cdf');

for i = 1:nSimulations
    roll = rand(1,1);
    if roll<0.20
        wind_speeds(i) = DrawFromCDF(slowWindCDF, slowWindIntervals);
        wind_directions(i) = roll * 360/0.20;
    elseif roll<0.56
        wind_speeds(i) = DrawFromCDF(fastWindCDF, fastWindIntervals);
        wind_directions(i) = rand(1,1)*22.5 + 56.25;
    else
        wind_speeds(i) = DrawFromCDF(fastestWindCDF, fastestWindIntervals);
        wind_directions(i) = rand(1,1)*22.5 + 78.75;
    end
end