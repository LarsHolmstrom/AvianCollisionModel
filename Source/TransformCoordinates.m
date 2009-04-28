function [transformed_x transformed_y] = TransformCoordinates(x, y, rotation)

%Convert to polar coordinates for rotation
r = sqrt(x.^2 + y.^2);
theta = atan(y./x);
theta(isnan(theta)) = 0;
%Account for quadrant ambiguity in arctangent function
quadrant_2_idx = intersect(find(x <= 0), find(y >= 0));
quadrant_3_idx = intersect(find(x <= 0), find(y <= 0));
rotated_theta = theta + rotation;
rotated_theta([quadrant_2_idx' quadrant_3_idx']) = rotated_theta([quadrant_2_idx' quadrant_3_idx'])+pi;
transformed_x = r.*cos(rotated_theta);
transformed_y = r.*sin(rotated_theta);