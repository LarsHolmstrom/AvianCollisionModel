clear variables
% close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulation settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plot_stuff = ~true;
n_simulations = 250000;
% n_simulations = 100;
figure_handle = nan;
use_ge_configuration_only = true;

rotor_avoidance_rates = [0.9 0.95 0.99];
tower_avoidance_rate = 0.99;

fid = fopen('SimulationResultsGEConfig.csv','w');
fprintf(fid,'Turbine Type, Time of Year, Time of Day, Bird Species, 0.9, 0.95, 0.99\n');

turbineTypes = {'ge','siemans','vestas'};
timesOfYear = {'spring','fall'};
timesOfDay = {'morning','evening'};
typesOfBird = {'petrel','shearwater'};

% turbineTypes = {'ge','siemans','vestas'};
% turbineTypes = {'vestas','siemans','ge'};
% timesOfYear = {'spring'};
% timesOfDay = {'morning'};
% typesOfBird = {'petrel'};

all_probabilities = {};

iRun = 0;
for iTurbineType = 1:length(turbineTypes)
    turbineType = turbineTypes{iTurbineType};
    for iTimeOfYear = 1:length(timesOfYear);
        timeOfYear = timesOfYear{iTimeOfYear};
        for iTimeOfDay = 1:length(timesOfDay)
            timeOfDay = timesOfDay{iTimeOfDay};
            for iTypeOfBird = 1:length(typesOfBird)
                iRun = iRun + 1;
                typeOfBird = typesOfBird{iTypeOfBird};
                display([turbineType ' ' timeOfYear ' ' timeOfDay ' ' typeOfBird]);
                all_collision_probabilities = auwahi_simulation(turbineType, ...
                                                                timeOfYear, ...
                                                                timeOfDay, ...
                                                                typeOfBird, ...
                                                                use_ge_configuration_only, ...
                                                                n_simulations, ...
                                                                rotor_avoidance_rates, ...
                                                                tower_avoidance_rate, ...
                                                                figure_handle, ...
                                                                plot_stuff);
                all_probabilities{iRun} = all_collision_probabilities;
                mean_collision_probabilities = nanmean(all_collision_probabilities);
                fprintf(fid, '%s, %s, %s, %s, %f, %f, %f\n', turbineType, timeOfYear, timeOfDay, typeOfBird, mean_collision_probabilities(1), mean_collision_probabilities(2), mean_collision_probabilities(3));
            end
        end
    end
end

fclose('all');
