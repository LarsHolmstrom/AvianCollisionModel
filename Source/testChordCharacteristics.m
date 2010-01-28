% cl

% R = 35.25;
% max_chord_length = 1.5;
R = 10;
max_chord_length = 1.5;
chord_length_at_hub = 0.8;
samplePoints = linspace(0,R,1000);
[c beta] = ChordCharacteristics(R,max_chord_length,chord_length_at_hub,samplePoints);


figure;
subplot(2,1,1)
plot(samplePoints,c)
ylabel('Chord Length (m)');
title('Chord Length')
xlabel('Distance From Rotation Point (m)')
ylim([0 1.7])
subplot(2,1,2);
plot(samplePoints,beta)
title('Rotor Twist');
xlabel('Distance From Rotation Point (m)')
ylabel('Chord Angle (degrees)');