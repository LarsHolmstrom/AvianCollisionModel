function [chord_length,chord_angle] = ChordCharacteristics(R,max_chord_length,sample_points)

bounds = [0 R*0.1 R*0.25 R];
section_1_r = sample_points(find(sample_points < bounds(2)));
section_2_r = sample_points(intersect(find(sample_points >= bounds(2)),find(sample_points < bounds(3))));
section_3_r = sample_points(find(sample_points >= bounds(3)));

c_1 = 0*section_1_r;
c_2 = 0.115*R*ones(1,length(section_2_r));
c_3 = 0.168*R-0.240*section_3_r+0.1*section_3_r.^2/R;

chord_length = [c_1 c_2 c_3];
chord_length = chord_length.*(max_chord_length/(0.115*R));

chord_angle = 0.640*atan(1./(8*(sample_points/R-0.015)))-0.073;
idx = find(chord_angle<0);
chord_angle(idx) = chord_angle(idx) + 2*pi;
%Convert to degrees
chord_angle = chord_angle*360/(2*pi);
chord_angle(find(sample_points < bounds(2))) = 0;


%Note, these generate the same results without scaling
%and are reported in the publication.
% c_1 = 0*section_1_r;
% c_2 = max_chord_length*ones(1,length(section_2_r));
% c_3 = max_chord_length*(1.46-2.09/R*section_3_r+0.87*section_3_r.^2/R^2);


