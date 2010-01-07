A = 1;
x0 = 0; y0 = 0;
 
sigma_x = 1;
sigma_y = 2;
 
for theta = 0:pi/100:pi
    a = cos(theta)^2/2/sigma_x^2 + sin(theta)^2/2/sigma_y^2;
    b = -sin(2*theta)/4/sigma_x^2 + sin(2*theta)/4/sigma_y^2 ;
    c = sin(theta)^2/2/sigma_x^2 + cos(theta)^2/2/sigma_y^2;

    [X, Y] = meshgrid(-5:.1:5, -5:.1:5);
    Z = A*exp( - (a*(X-x0).^2 + 2*b*(X-x0).*(Y-y0) + c*(Y-y0).^2)) ;
    surf(X,Y,Z);shading interp;view(-36,36);axis equal;drawnow
end

for i = 1:1000
    path(i).direction_degrees = norminv(rand(1,1),bird_path_direction_degrees_mean,bird_path_direction_degrees_stdev); % degrees clockwise from north
    path(i).height = norminv(rand(1,1),bird_path_height_mean,bird_path_height_stdev); % meters
    path(i).speed = norminv(rand(1,1),bird_speed_mean,bird_speed_stdev); % m/s
end

directions = [path.direction_degrees];
heights = [path.height];
speeds = [path.speed];

gkde2([directions ; speeds]')

figure;
plot(directions,speeds,'.');