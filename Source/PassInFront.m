function [passed_in_front x_c y_c] = PassInFront(x_1, y_1, ...
                                                 x_2, y_2, ...
                                                 x_3, y_3, ...
                                                 x_4, y_4)
%Check to see whether an object passing from point 1 to point 2
%will pass in front of an object passing from point 3 to point 4
denominator = (y_4 - y_3)*(x_2 - x_1) - (x_4 - x_3)*(y_2 - y_1);

collision_ratio_1_2 = ((x_4 - x_3)*(y_1 - y_3) - (y_4 - y_3)*(x_1 - x_3)) / denominator;
collision_ratio_3_4 = ((x_2 - x_1)*(y_1 - y_3) - (y_2 - y_1)*(x_1 - x_3)) / denominator;

if (collision_ratio_1_2 > 1 || collision_ratio_3_4 > 1)
    %The segments don't intersect
%     if mean([y_1 y_2]) > mean([y_3 y_4])
        passed_in_front = true;
%     else
%         passed_in_front = false;
%     end
    x_c = nan;
    y_c = nan;
    return;
end

if collision_ratio_1_2 < collision_ratio_3_4
    %The first object intersects the path of the
    %second object before the second object has reached
    %this point
    passed_in_front = true;
    x_c = nan;
    y_c = nan;
    return;
end

passed_in_front = false;
x_c = x_1 + collision_ratio_1_2*(x_2 - x_1);
y_c = y_1 + collision_ratio_1_2*(y_2 - y_1);