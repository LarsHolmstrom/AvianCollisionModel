function ...
[bird_speed_pdf ...
 bird_direction_pdf ...
 wind_pdf ...
 bird_height_pdf] = ...
 GeneratePDFs(season, turbineType, timeOfDay)

plotPDFs = true;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load and index the raw bird path data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load rawFlightData
windData; %Load the MET tower wind data
textdata = textdata(2:end,:);
bird_directions = data(:,4);
bird_speeds_mph = data(:,10);
bird_speeds_ms = convvel(bird_speeds_mph, 'mph', 'm/s');
wind_speeds_mph = data(:,12);
wind_speeds_ms = convvel(wind_speeds_mph, 'mph', 'm/s');
wind_direction_strs = textdata(:,14);
wind_directions = nan(1,length(wind_direction_strs));
for i = 1:length(wind_direction_strs)
    switch wind_direction_strs{i}
        case 'N'
            wind_directions(i) = 0;
        case 'NE'
            wind_directions(i) = 45;
        case 'E'
            wind_directions(i) = 90;
        case 'SE'
            wind_directions(i) = 135;
        case 'S'
            wind_directions(i) = 180;
        case 'SW'
            wind_directions(i) = 225;
        case 'W'
            wind_directions(i) = 270;
        case 'NW'
            wind_directions(i) = 315;
    end
end
bird_height = data(1:19,17);

iSummer = 20:26;
iFall = [1:19 27:103];
iGE = strmatch('N',textdata(:,21));
iSiemans = strmatch('N',textdata(:,22));
iVestas = strmatch('N',textdata(:,23));
hourStrs = strtok(textdata(2:end,4),':');
hours = nan(1,length(hourStrs));
for i=1:length(hours)
    hours(i) = str2num(hourStrs{i});
end
iMorning = find(hours < 12);
iEvening = find(hours >= 12);

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
    otherwise
        error('Badly specified timeOfDay string');
end

switch turbineType
    case 'ge'
        workingSet = intersect(workingSet,iGE);
    case 'siemans'
        workingSet = intersect(workingSet,iSiemans);
    case 'vestas'
        workingSet = intersect(workingSet,iVestas);
    otherwise
        error('Badly specified turbineType string');
end

[wind_directions wind_speeds] =  SimulateWindData(wind_speed_data);

% Select only the rows from the raw data corresponding to the specifications
% for the run
bird_directions = bird_directions(workingSet);
bird_speeds_ms = bird_speeds_ms(workingSet);

wind_pdf = gkde2([wind_directions ; wind_speeds]',200,[10 0.9086]);
wind_pdf.f = wind_pdf.f/sum(wind_pdf.f(:));
wind_pdf = WrapPDF2(wind_pdf);
sum(wind_pdf.f(:))
if plotPDFs
    figure;
    imagesc(wind_pdf.x(1,:),wind_pdf.y(:,1),wind_pdf.f);
    set(gca,'YDir','normal');
    xlabel('Wind Direction (Degrees Clockwise from North)');
    ylabel('Wind Speed (m/s)');
    title('Real Data');      
end
                   
[bird_speed_pdf bird_speed_Intervals] = ksdensity(bird_speeds_ms,'function','cdf');
[bird_direction_pdf  bird_direction_Intervals] = ksdensity(bird_directions,'function','cdf');
[bird_height_pdf bird_height_Intervals] = ksdensity(bird_height,'function','cdf');
                 
                 
                 
                 
                 
                 
                 
                 
                 