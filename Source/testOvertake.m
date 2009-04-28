cl

length = 1;
width = 2;
Vr = -1;
Vx = 2;
theta = linspace(0,pi/2,1000);
Vy = -Vx*tan(theta);

overtake_distance1 = (Vr-Vy).*(length.*sin(theta)./Vy);
overtake_distance2 = (Vr*length*sin(theta)./Vy)-(length*sin(theta));
overtake_distance3 = (Vr*length*sin(theta)./(-Vx*tan(theta)))-length*sin(theta);
overtake_distance4 = (Vr*length*cos(theta)./(-Vx))-length*sin(theta);

figure;plot(theta,length*cos(theta)/Vx);
figure;semilogy(theta,Vy);
figure;semilogy(theta,overtake_distance1);
figure;semilogy(theta,overtake_distance2);
figure;semilogy(theta,overtake_distance3);
figure;semilogy(theta,overtake_distance4);
