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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load and index the raw bird path data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load rawFlightData
textdata = textdata(2:end,:);
bird_directions = data(:,4);
bird_speeds_mph = data(:,10);
bird_speeds_ms = convvel(bird_speeds_mph, 'mph', 'm/s');

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





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate probability distributions from raw data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p = gkde2([bird_directions' ; bird_speeds_ms']',400,[41 .9]);
p = WrapPDF(p);
sum(p.f(:))
figure;
imagesc(p.x(1,:),p.y(:,1),p.f);
set(gca,'YDir','normal');
xlabel('Direction (Degrees Clockwise from North)');
ylabel('Ground Speed (m/s)');
title('Real Data');

figure;
plot(bird_directions, bird_speeds_ms,'.');
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
p = gkde2([directions ; speeds]',400,[41 .9]);
p = WrapPDF(p);
sum(p.f(:))
figure;
imagesc(p.x(1,:),p.y(:,1),p.f);
set(gca,'YDir','normal');
xlabel('Direction (Degrees Clockwise from North)');
ylabel('Ground Speed (m/s)');
title('Simulated data');
