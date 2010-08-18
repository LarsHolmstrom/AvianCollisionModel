%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Start Flight Heights
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filterFlightData = ~true;

if filterFlightData
    load FilteredFlightHeights_updated
    flight_heights = data(2:end,8);
    scale = 5;
else
    load AllFlightHeights_updated
    flight_heights = data(2:end,5);
    scale = 14;
end

% load flight_heights
figure;
maxval = 800;
evaluationPoints = 1:maxval;
subplot(2,1,1)
hist(flight_heights,20);
h = findobj(gca,'Type','patch');
set(h,'FaceColor',[0.7 0.7 0.7],'EdgeColor',[0.7 0.7 0.7])

xlim([0 maxval])
[a b] = gamfit(flight_heights);
p = gampdf(evaluationPoints,a(1),a(2));
% pinv = gamcdf([99.95 130.5 125],a(1),a(2));
% figure;
hold on
ph = plot(evaluationPoints,scale*p/max(p),'r');
set(ph,'LineWidth',2);
% xlabel('Bird Height (m)');
title('A')
ylabel('n')
legend({'Observed Data','Gamma Fit'})

subplot(2,1,2)
hold on
p1 = plot(evaluationPoints', gamcdf(evaluationPoints,a(1),a(2))','r');
set(p1,'LineWidth',2)
p2 = cdfplot(flight_heights);
set(p2,'LineWidth',2)
title('B');
xlabel('Bird Height (m)');
ylabel('CDF');
legend({'Gamma CDF','Observed CDF'},'location','SE');
PrintFigure('GammaFitTest','png',5,4);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Flight Heights
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test function for the estimation of all PDFs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[bird_speed_pdf ...
 bird_direction_pdf ...
 wind_pdf ...
 bird_height_pdf] = ...
 GeneratePDFs('spring', 'ge', 'morning');

load RotorRotationData
turbine_data_wind_speed = data(:,1);
turbine_data_rotor_speed = data(:,2);
turbine_data_rotor_pitch = data(:,3);
figure;
ph = plot(turbine_data_wind_speed, turbine_data_rotor_speed);
xlabel('Wind Speed (m/s)')
ylabel('Rotor Speed (RPMs)');
ylim([0 17]);
set(ph,'LineWidth',3);
PrintFigure('RotorSpeed','jpeg',5,3)


uniform_dist = randn(1,1000)-1;
[pdf intervals] = ksdensity(uniform_dist);
pdf = pdf/sum(pdf);
figure;
plot(intervals,pdf)
sum(pdf.*intervals)
mean(uniform_dist)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot density of collision probability PDF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
roc_90_avoidance = all_collision_probabilities(:,1);
roc_90_avoidance_non_zero = roc_90_avoidance(find(roc_90_avoidance > 0));
[roc_pdf roc_intervals] = ksdensity(roc_90_avoidance_non_zero,'function','pdf','support','positive','width',0.05);
figure;
semilogy(roc_intervals, roc_pdf);
figure;hist(roc_90_avoidance_non_zero,100);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create bird distribution figures
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;

[bird_speed_pdf ...
 bird_direction_pdf ...
 wind_pdf ...
 bird_height_pdf] = ...
 GeneratePDFs('all', 'all', 'morning');

subplot(1,2,1);
% load morningFigData
p1 = plot(bird_speed_pdf.intervals, bird_speed_pdf.pdf,'r');
set(p1,'LineWidth',2);
foo = [min(bird_speed_pdf.intervals) max(bird_speed_pdf.intervals)];
hold on;

[bird_speed_pdf ...
 bird_direction_pdf ...
 wind_pdf ...
 bird_height_pdf] = ...
 GeneratePDFs('all', 'all', 'evening');

p2 = plot(bird_speed_pdf.intervals, bird_speed_pdf.pdf);
set(p2,'LineWidth',2);
xlabel('Bird speed (m/s)');
ylabel('Density');
bar = [min(bird_speed_pdf.intervals) max(bird_speed_pdf.intervals)];
xlim([min([foo bar]) max([foo bar])]);
legend([p1 p2], {'Dawn', 'Dusk'})

[bird_speed_pdf ...
 bird_direction_pdf ...
 wind_pdf ...
 bird_height_pdf] = ...
 GeneratePDFs('all', 'all', 'morning');

subplot(1,2,2);
% load morningFigData
p1 = plot(bird_direction_pdf.intervals, bird_direction_pdf.pdf,'r');
set(p1,'LineWidth',2);
hold on;

[bird_speed_pdf ...
 bird_direction_pdf ...
 wind_pdf ...
 bird_height_pdf] = ...
 GeneratePDFs('all', 'all', 'evening');

% load eveningFigData
p2 = plot(bird_direction_pdf.intervals, bird_direction_pdf.pdf);
set(p2,'LineWidth',2);
xlabel('Bird bearing (Degrees Clockwise from North)');
% ylabel('Density');
xlim([min(bird_direction_pdf.intervals) max(bird_direction_pdf.intervals)]);
ylim([0 0.04]);
% AxisSet(16,'Garamond');
legend([p1 p2], {'Dawn', 'Dusk'},'location','NorthEast')

PrintFigure('BirdPDFs','png',8,5)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load and index the raw bird path data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all

load rawFlightData
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

figure;
hist(wind_speeds_ms,20);

test_heights = nan(1,2000);
for iz = 1:2000
    test_heights(iz) =  DrawFromPDF(bird_height_pdf.pdf,bird_height_pdf.intervals);
end
figure;hist(test_heights,200);


% workingSet = intersect(iSummer,iSiemans);
% bird_directions = bird_directions(workingSet);
% bird_speeds_ms = bird_speeds_ms(workingSet);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate probability distributions from raw data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% p = gkde2([bird_directions' ; bird_speeds_ms']',200,[41 .9]);
p = gkde2([wind_directions ; wind_speeds_ms']',200,[41 .9]);
% p = gkde2([bird_speeds_ms' ; wind_speeds_ms']',200,[41 .9]);
p.f = p.f/sum(p.f(:));
p = WrapPDF(p);
sum(p.f(:))
figure;
imagesc(p.x(1,:),p.y(:,1),p.f);
set(gca,'YDir','normal');
xlabel('Direction (Degrees Clockwise from North)');
ylabel('Ground Speed (m/s)');
title('Real Data');

figure;
% plot(bird_directions, bird_speeds_ms,'.');
plot(wind_directions, wind_speeds_ms,'.');
% plot(bird_speeds_ms, wind_speeds_ms,'.');
xlim([min(p.x(1,:)) max(p.x(1,:))]);
ylim([min(p.y(:,1)) max(p.y(:,1))]);

testIterations = 1000;
directions = nan(1,testIterations);
speeds = nan(1,testIterations);
for i = 1:testIterations
    [direction speed] = DrawFromPDF2(p);
    directions(i) = direction;
    speeds(i) = speed;
end
p2 = gkde2([directions ; speeds]',200,[41 .9]);
p2.f = p2.f/sum(p2.f(:));
p2 = WrapPDF(p2);
sum(p2.f(:))
figure;
plot(directions, speeds,'.');
figure;
imagesc(p2.x(1,:),p2.y(:,1),p2.f);
set(gca,'YDir','normal');
xlabel('Direction (Degrees Clockwise from North)');
ylabel('Ground Speed (m/s)');
title('Simulated data');
xlim([min(p2.x(1,:)) max(p2.x(1,:))]);
ylim([min(p2.y(:,1)) max(p2.y(:,1))]);
