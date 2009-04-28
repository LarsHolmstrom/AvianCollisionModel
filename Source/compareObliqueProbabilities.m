clear variables

% load 'BaseValues'
% load 'Comparison_1m_10ms';
% load 'Comparison_5ms';
% load 'Comparison_20ms';
% load 'Comparison_2m_10ms';
% load 'Comparison_1m_15ms_bird_10ms_wind';
% load 'Comparison_1m_10ms_bird_5ms_wind';

% fileName = 'sharp-shinned-hawk_5ms_wind.mat';
% fileName = 'sharp-shinned-hawk_10ms_wind.mat';
% fileName = 'golden-eagle_5ms_wind.mat';
fileName = 'golden-eagle_10ms_wind.mat';

load(fileName)

% load 'sharp-shinned-hawk_5ms_wind_no_hub.mat';
% load 'sharp-shinned-hawk_10ms_wind_no_hub.mat';
% load 'golden-eagle_5ms_wind_no_hub.mat';
% load 'golden-eagle_10ms_wind_no_hub.mat';

%############################################################
% Set wind variables
%############################################################
% wind_speed = str2double(model_data.wind_speed);
wind_speed = 12;
% wind_direction = str2double(model_data.wind_direction);

%############################################################
% Set turbine variables
%############################################################
n_rotors = str2double(model_data.n_rotors);
turbine_radius = str2double(model_data.turbine_radius);
hub_radius = str2double(model_data.hub_radius);
angular_velocity = str2double(model_data.angular_velocity);
chord_length = str2double(model_data.chord_length);

%############################################################
% Set bird variables
%############################################################
wingspan = str2double(model_data.wingspan);
length = str2double(model_data.length);
bird_speed = str2double(model_data.bird_speed);
% bird_direction = str2double(model_data.bird_direction);

%############################################################
% Assume wind is always blowing at 0 degrees (NORTH)
%############################################################
wind_direction = 0;
induction = 0;
resolution = 3;
hub_radius = 0;
wind_speeds = [4 12];
% wind_speeds = [12];
% wind_speed = 0;
% chord_length = 0;
% wind_directions = -80:2.5:80;
% wind_directions = -50:10:50;
% bird_directions = -30:2.5:30;
% bird_directions = -50:1:50;
bird_directions = -50:10:50; %For testing
% bird_directions = -50:1:50; %For plot
% wind_directions = [-10];
% y_dim = 0;
% z_dim = 20;

model_idx = 0;
for model_type = 0%:1%2
    model_type
    model_idx = model_idx + 1;
    wind_idx = 0;
    for wind_speed = wind_speeds
        wind_idx = wind_idx + 1;
        bird_idx = 0;
        for bird_direction = bird_directions
            bird_direction
            bird_idx = bird_idx + 1;

            [oblique_probabilities ...
             angle_of_orientation ...
             mean_probability ...
             mean_aperature_probability] = TurbineCollision(wingspan, ...
                                                            length, ...
                                                            n_rotors, ...
                                                            turbine_radius, ...
                                                            hub_radius, ...
                                                            angular_velocity, ...
                                                            chord_length, ...
                                                            induction, ...
                                                            wind_speed, ...
                                                            wind_direction, ...
                                                            bird_speed, ...
                                                            bird_direction, ...
                                                            0, ...
                                                            resolution, ...
                                                            model_type);

            mean_probabilities(wind_idx,bird_idx) = mean_probability;
            mean_aperature_probabilities(wind_idx,bird_idx) = mean_aperature_probability;
            bird_orientations(wind_idx,bird_idx) = angle_of_orientation;
        end
    end
end
        
% figure;
% plot(bird_orientations(1,:),mean_probabilities');
% title('Turbine Comparison');
% xlabel('Angle of Approach');
% ylabel('Mean Probability Across Turbine');
% % legend('Hamer', 'Tucker','Podoski');
% legend('Hamer', 'Tucker');
%         
% figure;
% plot(bird_orientations(1,:),mean_aperature_probabilities');
% title('Normalized Turbine Comparison');
% xlabel('Angle of Approach');
% ylabel('Normalized Probability Across Turbine');
% legend('Hamer', 'Tucker');
% 
% figure;
% plot(bird_orientations(1,:),[mean_aperature_probabilities(1,:)' repmat(mean_probabilities(2,floor(size(mean_probabilities,2)/2)),1,size(mean_aperature_probabilities,2))']);
% title('Normalized Turbine Comparison');
% xlabel('Angle of Approach');
% ylabel('Normalized Probability Across Turbine');
% legend('Hamer', 'Tucker');

figure;
hl1 = plot(bird_directions,[mean_aperature_probabilities' repmat(min(mean_aperature_probabilities(1,:)),1,size(mean_aperature_probabilities,2))']);
set(hl1(1),'LineStyle','-.');
set(hl1(3),'LineStyle','--');
xlabel('Angle of Approach');
ylabel('Collision Probability Across Turbine');
legend('Cut-in wind speed', 'Rated wind speed','Tucker model predictions','Location','North');
legend boxoff
minRate = min(min(mean_aperature_probabilities));
maxRate = max(max(mean_aperature_probabilities));
ylim([minRate - 0.01*minRate, maxRate + 0.01*maxRate]);
xlim([bird_directions(1) bird_directions(end)]);
% set(gca,'XTickMode','manual');

ax1 = gca;
ax2 = axes('Position',get(ax1,'Position'),...
           'XAxisLocation','top',...
           'YAxisLocation','left',...
           'Color','none',...
           'XColor','k','YColor','k');
set(ax2,'YTick',[]);
hl2 = line(bird_orientations,[repmat(0,1,size(mean_aperature_probabilities,2))'],'Parent',ax2);
set(hl2,'Color',[1 1 1]);
xlabel('Angle of Orientation');
xlim([bird_orientations(2,1) bird_orientations(2,end)]);

percent_increase_1 = (max(mean_aperature_probabilities(1,:)) - min(mean_aperature_probabilities(1,:))) / min(mean_aperature_probabilities(1,:))
percent_increase_2 = (max(mean_aperature_probabilities(2,:)) - min(mean_aperature_probabilities(2,:))) / min(mean_aperature_probabilities(2,:))
% suptitle(['Percent increase: ' num2str(percent_increase)]);


PrintFigure(fileName(1:end-4),'epsc');
% PrintFigure(fileName(1:end-4),'jpeg');

%0.1035/0.1977
%0.2493/0.3062