
num_samples = 100;

%Counterclockwise, first quadrant
omegas = linspace(0,-100,num_samples);
% omegas = -5;
z = -5;
y_start = 5;
time = 0.1;
idx = 1;
distances = zeros(1,num_samples);
for omega = omegas
    distances(idx) = DistanceBladeTravelsInTime(z, y_start, omega, time);
    idx = idx + 1;
end
figure;
plot(distances);

%Clockwise, first quadrant
omegas = linspace(0,100,num_samples);
% z = 5;
% y_start = 5;
time = 0.1;
idx = 1;
distances = zeros(1,num_samples);
for omega = omegas
    distances(idx) = DistanceBladeTravelsInTime(z, y_start, omega, time);
    idx = idx + 1;
end
figure;
plot(distances);
    