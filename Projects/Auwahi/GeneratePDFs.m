function ...
[bird_speed ...
 bird_direction ...
 slow_wind_speed ...
 fast_wind_speed ...
 bird_height] = ...
 GeneratePDFs(season, turbineType, timeOfDay)

plotPDFs = ~true;
filterFlightData = true; %Use only data that crosses the windpark for the specified turbine configuration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load and index the raw bird path data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load rawFlightData
% load flight_heights

if filterFlightData
    load FilteredFlightHeights_updated
    flight_heights = data(:,8);
else
    load AllFlightHeights_updated
    flight_heights = data(:,8);
end
load FilteredFlightPathData_updated

%Load the survey data
% handle = fopen('sempra_run_3_master_NA_flight_speed_removed.csv');
handle = fopen('Sempra_Run_3_All_Data.csv');
%Skip the first line
data = textscan(handle,'%s',7,'delimiter',',');
try
    data = textscan(handle,'%s %f %f %s %s %s %s','delimiter',',');
catch
    fclose(handle);
end

windData; %Load the MET tower wind data
% textdata = textdata(2:end,:);
% bird_directions = data(:,4);
bird_directions = data{2};
% bird_speeds_mph = data(:,10);
bird_speeds_mph = data{3};
bird_speeds_ms = convvel(bird_speeds_mph, 'mph', 'm/s');
% wind_speeds_mph = data(:,12);
% wind_speeds_ms = convvel(wind_speeds_mph, 'mph', 'm/s');
% wind_direction_strs = textdata(:,14);
% wind_directions = nan(1,length(wind_direction_strs));
% for i = 1:length(wind_direction_strs)
%     switch wind_direction_strs{i}
%         case 'N'
%             wind_directions(i) = 0;
%         case 'NE'
%             wind_directions(i) = 45;
%         case 'E'
%             wind_directions(i) = 90;
%         case 'SE'
%             wind_directions(i) = 135;
%         case 'S'
%             wind_directions(i) = 180;
%         case 'SW'
%             wind_directions(i) = 225;
%         case 'W'
%             wind_directions(i) = 270;
%         case 'NW'
%             wind_directions(i) = 315;
%     end
% end

% iSummer = 20:26;
% iFall = [1:19 27:103];
% iSummerAndFall = [iSummer iFall];
% iSpring = 97:187;
% iFall = 1:96;
iFall = 1:229;
iSpring = 230:396;
iSpringAndFall = [iSpring iFall];
% iGE = strmatch('N',textdata(:,21));
iGE = strmatch('"N"',data{5});
% iSiemans = strmatch('N',textdata(:,22));
iSiemans23 = strmatch('"N"',data{6});
iSiemans30 = strmatch('"N"',data{7});
% iVestas = strmatch('N',textdata(:,23));
% hourStrs = strtok(textdata(2:end,4),':');
% hourStrs = strtok(textdata(:,4),':');
% hourStrs = strtok(data{2},':');
% hours = nan(1,length(hourStrs));
% for i=1:length(hours)
%     % Remove the leading "
%     hours(i) = str2num(hourStrs{i}(2:end));
% end
% iMorning = find(hours < 12);
% iEvening = find(hours >= 12);
iMorning = strmatch('"M"',data{4});
iEvening = strmatch('"E"',data{4});
iMorningAndEvening = [iMorning' iEvening'];

% Initialize by using all data
workingSet = 1:size(bird_speeds_mph,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Specify the MET wind data to use based on the season
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch season
    case 'spring'
        wind_speed_data = [wind_speeds_04_07 ;...
                           wind_speeds_04_08 ;...
                           wind_speeds_04_09 ;...
                           wind_speeds_05_07 ;...
                           wind_speeds_05_08 ;...
                           wind_speeds_05_09 ;...
                           wind_speeds_06_07 ;...
                           wind_speeds_06_08 ;...
                           wind_speeds_06_09];
    case 'fall'
        wind_speed_data = [wind_speeds_09_07 ;...
                           wind_speeds_09_08 ;...
                           wind_speeds_09_09 ;...
                           wind_speeds_10_07 ;...
                           wind_speeds_10_08 ;...
                           wind_speeds_10_09 ;...
                           wind_speeds_11_07 ;...
                           wind_speeds_11_08 ;...
                           wind_speeds_11_09];
    case {'springAndFall','all'}
        wind_speed_data = [wind_speeds_04_07 ;...
                           wind_speeds_04_08 ;...
                           wind_speeds_04_09 ;...
                           wind_speeds_05_07 ;...
                           wind_speeds_05_08 ;...
                           wind_speeds_05_09 ;...
                           wind_speeds_06_07 ;...
                           wind_speeds_06_08 ;...
                           wind_speeds_06_09 ;...
                           wind_speeds_09_08 ;...
                           wind_speeds_09_09 ;...
                           wind_speeds_10_07 ;...
                           wind_speeds_10_08 ;...
                           wind_speeds_10_09 ;...
                           wind_speeds_11_07 ;...
                           wind_speeds_11_08 ;...
                           wind_speeds_11_09];
    otherwise
        error('Badly specified season string');
end

switch timeOfDay
    case 'morning'
        wind_data = wind_speed_data(:,5:8);
        workingSet = intersect(workingSet,iMorning);
    case 'evening'
        wind_data = wind_speed_data(:,19:22);
        workingSet = intersect(workingSet,iEvening);
    case 'morningAndEvening'
        wind_data = wind_speed_data(:,[5:8 19:22]);
        workingSet = intersect(workingSet,iEvening);
    case 'all'
    otherwise
        error('Badly specified timeOfDay string');
end

% Assumption of uniform distribution probably means that we should use
% all bird paths (no filterin)
switch turbineType
    case 'ge'
        workingSet = intersect(workingSet,iGE);
    case 'siemans23'
        workingSet = intersect(workingSet,iSiemans23);
    case 'siemans30'
        workingSet = intersect(workingSet,iSiemans30);
    case 'vestas'
        workingSet = intersect(workingSet,iVestas);
    case 'all'
        workingSet = intersect(workingSet,unique([iGE' iSiemans23' iSiemans30']));
    otherwise
        error('Badly specified turbineType string');
end

[wind_speed_pdf wind_speed_intervals] = ksdensity(wind_data(:),'function','pdf');
wind_speed.pdf = wind_speed_pdf/sum(wind_speed_pdf);
wind_speed.intervals = wind_speed_intervals;
less_than_zero_index = find(wind_speed.intervals < 0,1,'last');
if ~isempty(less_than_zero_index)
    wind_speed.intervals = wind_speed.intervals(less_than_zero_index+1:end);
    wind_speed.pdf = wind_speed.pdf(less_than_zero_index+1:end);
    wind_speed.pdf = wind_speed.pdf/sum(wind_speed.pdf);
end
less_than_four_index = find(wind_speed.intervals < 4,1,'last');
if ~isempty(less_than_four_index)
    slow_wind_speed.intervals = wind_speed.intervals(1:less_than_four_index);
    slow_wind_speed.pdf = wind_speed.pdf(1:less_than_four_index);
    slow_wind_speed.pdf = slow_wind_speed.pdf/sum(slow_wind_speed.pdf);

    fast_wind_speed.intervals = wind_speed.intervals(less_than_four_index+1:end);
    fast_wind_speed.pdf = wind_speed.pdf(less_than_four_index+1:end);
    fast_wind_speed.pdf = fast_wind_speed.pdf/sum(fast_wind_speed.pdf);
end

% Select only the rows from the raw data corresponding to the specifications
% for the run
bird_directions = bird_directions(workingSet);
bird_speeds_ms = bird_speeds_ms(workingSet);

% % User kernel smoothing for the pdf estimation
% wind_pdf = gkde2([wind_directions ; wind_speeds]',200,[10 0.9086]);
% wind_pdf.f = wind_pdf.f/sum(wind_pdf.f(:));
% wind_pdf = WrapPDF2(wind_pdf);
                   
% [bird_speed_pdf bird_speed_intervals bandwidth] = ksdensity(bird_speeds_ms,'function','pdf');
[bird_speed_pdf bird_speed_intervals bandwidth] = ksdensity(bird_speeds_ms,'function','pdf','width',1.4);
bird_speed.pdf = bird_speed_pdf/sum(bird_speed_pdf);
bird_speed.intervals = bird_speed_intervals;
less_than_zero_index = find(bird_speed.intervals < 0,1,'last');
if ~isempty(less_than_zero_index)
    bird_speed.intervals = bird_speed.intervals(less_than_zero_index+1:end);
    bird_speed.pdf = bird_speed.pdf(less_than_zero_index+1:end);
    bird_speed.pdf = bird_speed.pdf/sum(bird_speed.pdf);
end

[bird_direction_pdf  bird_direction_intervals bandwidth] = ksdensity(bird_directions,'function','pdf');
% [bird_direction_pdf  bird_direction_intervals bandwidth] = ksdensity(bird_directions,'function','pdf','width',5);
bird_direction.intervals = bird_direction_intervals;
bird_direction.pdf = bird_direction_pdf/sum(bird_direction_pdf);
bird_direction = WrapPDF(bird_direction);
bird_direction.pdf = bird_direction.pdf/sum(bird_direction.pdf);

load flight_heights
height_samples = 1:1:1000;
[a b] = gamfit(flight_heights);
bird_height.pdf = gampdf(height_samples,a(1),a(2));
bird_height.intervals = height_samples;
bird_height.pdf = bird_height.pdf/sum(bird_height.pdf);

% [bird_height_pdf bird_height_intervals] = ksdensity(flight_heights,'function','pdf');
% bird_height.pdf = bird_height_pdf/sum(bird_height_pdf);
% bird_height.intervals = bird_height_intervals;
% less_than_zero_index = find(bird_height.intervals < 0,1,'last');
% if ~isempty(less_than_zero_index)
%     bird_height.intervals = bird_height.intervals(less_than_zero_index+1:end);
%     bird_height.pdf = bird_height.pdf(less_than_zero_index+1:end);
%     bird_height.pdf = bird_height.pdf/sum(bird_height.pdf);
% end
                 
% Confirm that they are normalized
% sum(wind_pdf.f(:))
sum(slow_wind_speed.pdf(:))
sum(fast_wind_speed.pdf(:))
sum(bird_speed.pdf(:))
sum(bird_direction.pdf(:))
sum(bird_height.pdf(:))
                 
                 

if plotPDFs
%     figure;
%     imagesc(wind_pdf.x(1,:),wind_pdf.y(:,1),wind_pdf.f);
%     set(gca,'YDir','normal');
%     xlabel('Wind Direction (Degrees Clockwise from North)');
%     ylabel('Wind Speed (m/s)');
%     colorbar

    figure;
    plot(slow_wind_speed.intervals, slow_wind_speed.pdf);
    xlabel('Wind speed slow (m/s)');
    ylabel('Density');
    xlim([min(slow_wind_speed.intervals) max(slow_wind_speed.intervals)]);
    
    figure;
    plot(fast_wind_speed.intervals, fast_wind_speed.pdf);
    xlabel('Wind speed fast (m/s)');
    ylabel('Density');
    xlim([min(fast_wind_speed.intervals) max(fast_wind_speed.intervals)]);
    
    figure;
    plot(bird_speed.intervals, bird_speed.pdf);
    xlabel('Bird speed (m/s)');
    ylabel('Density');
    xlim([min(bird_speed.intervals) max(bird_speed.intervals)]);
    
    figure;
    plot(bird_direction.intervals, bird_direction.pdf);
    xlabel('Bird bearing PDF (Degrees Clockwise from North)');
    ylabel('Density');
    xlim([min(bird_direction.intervals) max(bird_direction.intervals)]);
    
    figure;
    plot(bird_height.intervals, bird_height.pdf);
    xlabel('Bird height (m)');
    ylabel('Density');
    xlim([min(bird_height.intervals) max(bird_height.intervals)]);
    
    figure;
    plot(wind_speed.intervals, wind_speed.pdf);
    xlabel('Wind Speed (m/s)');
    ylabel('Density');
    xlim([min(wind_speed.intervals) max(wind_speed.intervals)]);
end
                 
                 
                 