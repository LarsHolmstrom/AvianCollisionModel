
% Case where psi is positive (bird in top half of turbine) and moving to left
r = 1;
psi = pi/4;
y = linspace(0,2*sqrt(2),1000);
% there is a discontinuity as psi crosses the y-axis.
% must add pi to all negative psi values.
angles = atan(r*sin(psi)./(r*cos(psi)-y/2));
idx = find(angles < 0);
angles(idx) = angles(idx) + pi;
figure;
plot(y,angles);


% Case where psi is negative (bird in bottom half of turbine) and moving to left
r = 1;
psi = -pi/4;
y = linspace(0,2*sqrt(2),1000);
% there is a discontinuity as psi crosses the y-axis.
% must add pi to all negative psi values.
angles = atan(r*sin(psi)./(r*cos(psi)-y/2));
idx = find(angles > 0);
angles(idx) = angles(idx) - pi;
figure;
plot(y,angles);

% Case where psi is positive (bird in top half of turbine) moving to right
r = 1;
psi = 3*pi/4;
y = linspace(0,2*sqrt(2),1000);
% there is a discontinuity as psi crosses the y-axis.
% must add pi to all negative psi values.
angles = atan(r*sin(psi)./(r*cos(psi)+y/2));
idx = find(angles < 0);
angles(idx) = angles(idx) + pi;
figure;
plot(y,angles);


% Case where psi is negative (bird in bottom half of turbine) and moving to left
r = 1;
psi = -3*pi/4;
y = linspace(0,2*sqrt(2),1000);
% there is a discontinuity as psi crosses the y-axis.
% must add pi to all negative psi values.
angles = atan(r*sin(psi)./(r*cos(psi)+y/2));
idx = find(angles > 0);
angles(idx) = angles(idx) - pi;
figure;
plot(y,angles);


%Generic bottom half of rotor test
z = 5;
y = linspace(-5,5,1000);
angles = atan(z./y);
idx = find(angles < 0);
angles(idx) = angles(idx) + pi;
figure;plot(y,angles);

%Generic top half of rotor test
z = -5;
y = linspace(-5,5,1000);
angles = atan(z./y);
idx = find(angles < 0);
angles(idx) = angles(idx) + pi;
figure;plot(y,angles);