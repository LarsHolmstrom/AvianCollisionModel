clear variables
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulation settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
plot_stuff = ~true;
n_simulations = 100000;
figure_handle = nan;

rotor_avoidance_rates = [0.9 0.95 0.99];
tower_avoidance_rate = 0.99;

timeOfYear = 'spring';
turbineType = 'ge';
timeOfDay = 'morning';
typeOfBird = 'petrel';

fid = fopen('SimulationResults.csv','w');
fprintf(fid,'Turbine Type, Time of Year, Time of Day, Bird Species, 0.9, 0.95, 0.99\n');

% turbineTypes = {'ge','siemans','vestas'};
% timesOfYear = {'spring','fall'};
% timesOfDay = {'morning','evening'};
% typesOfBird = {'petrel','shearwater'};

turbineTypes = {'vestas'};
timesOfYear = {'fall'};
timesOfDay = {'evening'};
typesOfBird = {'shearwater'};

all_probabilities = {};

iRun = 0;
for iTurbineType = 1:length(turbineTypes)
    iRun = iRun + 1;
    turbineType = turbineTypes{iTurbineType};
    for iTimeOfYear = 1:length(timesOfYear);
        timeOfYear = timesOfYear{iTimeOfYear};
        for iTimeOfDay = 1:length(timesOfDay)
            timeOfDay = timesOfDay{iTimeOfDay};
            for iTypeOfBird = 1:length(typesOfBird)
                typeOfBird = typesOfBird{iTypeOfBird};
                display([turbineType ' ' timeOfYear ' ' timeOfDay ' ' typeOfBird]);
                auwahi_simulation
                all_probabilities{iRun} = all_collision_probabilities;
                fprintf(fid, '%s, %s, %s, %s, %f, %f, %f\n', turbineType, timeOfYear, timeOfDay, typeOfBird, mean_collision_probabilities(1), mean_collision_probabilities(2), mean_collision_probabilities(3));
            end
        end
    end
end

fclose('all');