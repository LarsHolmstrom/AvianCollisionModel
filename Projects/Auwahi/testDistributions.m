% A = 1;
% x0 = 0; y0 = 0;
%  
% sigma_x = 1;
% sigma_y = 2;
%  
% for theta = 0:pi/100:pi
%     a = cos(theta)^2/2/sigma_x^2 + sin(theta)^2/2/sigma_y^2;
%     b = -sin(2*theta)/4/sigma_x^2 + sin(2*theta)/4/sigma_y^2 ;
%     c = sin(theta)^2/2/sigma_x^2 + cos(theta)^2/2/sigma_y^2;
% 
%     [X, Y] = meshgrid(-5:.1:5, -5:.1:5);
%     Z = A*exp( - (a*(X-x0).^2 + 2*b*(X-x0).*(Y-y0) + c*(Y-y0).^2)) ;
%     surf(X,Y,Z);shading interp;view(-36,36);axis equal;drawnow
% end
% 
% for i = 1:1000
%     path(i).direction_degrees = norminv(rand(1,1),bird_path_direction_degrees_mean,bird_path_direction_degrees_stdev); % degrees clockwise from north
%     path(i).height = norminv(rand(1,1),bird_path_height_mean,bird_path_height_stdev); % meters
%     path(i).speed = norminv(rand(1,1),bird_speed_mean,bird_speed_stdev); % m/s
% end
% 
% directions = [path.direction_degrees];
% heights = [path.height];
% speeds = [path.speed];
% 
% gkde2([directions ; speeds]')
% 
% figure;
% plot(directions,speeds,'.');
% 
% foo = rand(1,100);
% % bar = rand(1,100);
% bar = foo*10;
% information(foo,bar)
% corr2(foo,bar)

% theta = 2*pi*rand(1,50);
% rose(theta,16)

load flight_heights
figure;hist(flight_heights,20);
xlim([0 1000])
[a b] = gamfit(flight_heights);
p = gampdf(1:0.1:1000,a(1),a(2));
% pinv = gamcdf([99.95 130.5 125],a(1),a(2));
% figure;
hold on
ph = plot(1:0.1:1000,8*p/max(p),'r')
set(ph,'LineWidth',3);
xlabel('Bird Height (m)');
ylabel('n')
legend({'Observed Data','Gamma Fit'})

[bird_speed_pdf ...
 bird_direction_pdf ...
 wind_pdf ...
 bird_height_pdf] = ...
 GeneratePDFs('spring', 'ge', 'morning');

nSimulations = 100000;
wind_directions = nan(1,nSimulations);
wind_speeds = nan(1,nSimulations);
for i = 1:nSimulations
    [wind_speed wind_direction] = GetWindSample(slow_wind_speed, fast_wind_speed);
    wind_speeds(i) = wind_speed;
    wind_directions(i) = wind_direction;
end



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
