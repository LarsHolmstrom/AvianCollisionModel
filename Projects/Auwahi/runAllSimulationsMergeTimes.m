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

fid = fopen('SimulationResultsCombined.csv','w');
fprintf(fid,'Turbine Type, Bird Species, 0.9, 0.95, 0.99\n');

% turbineTypes = {'ge','siemans','vestas'};
% timeOfYear = 'springAndFall';
% timeOfDay = 'morningAndEvening';
% typesOfBird = {'petrel','shearwater'};

turbineTypes = {'ge'};
timeOfYear = 'springAndFall';
timeOfDay = 'morning';
typesOfBird = {'petrel'};

all_probabilities = {};

iRun = 0;
for iTurbineType = 1:length(turbineTypes)
    iRun = iRun + 1;
    turbineType = turbineTypes{iTurbineType};
    for iTypeOfBird = 1:length(typesOfBird)
        typeOfBird = typesOfBird{iTypeOfBird};
        display([turbineType ' ' typeOfBird]);
        auwahi_simulation
        all_probabilities{iRun} = all_collision_probabilities;
        fprintf(fid, '%s, %s, %f, %f, %f\n', turbineType, typeOfBird, mean_collision_probabilities(1), mean_collision_probabilities(2), mean_collision_probabilities(3));
    end
end

fclose('all');