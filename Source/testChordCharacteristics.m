% cl

R = 36;
max_chord_length = 2;
samplePoints = linspace(0,R,1000);
[c beta] = ChordCharacteristics(R,max_chord_length,samplePoints);


figure;
subplot(2,1,1)
plot(samplePoints,c)
ylabel('Chord Length (m)');
title('Chord Length')
xlabel('Distance From Rotation Point (m)')
subplot(2,1,2);
plot(samplePoints,beta)
title('Rotor Twist');
xlabel('Distance From Rotation Point (m)')
ylabel('Chord Angle (degrees)');