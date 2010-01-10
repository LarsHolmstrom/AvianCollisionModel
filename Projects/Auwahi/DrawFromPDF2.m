function [x y] = DrawFromPDF2(p)

roll = rand(1,1);
% draw = find(roll < cumsum(p.f(:)),1,'last');
draw = find(cumsum(p.f(:)) > roll,1,'first');
x = p.x(draw);
y = p.y(draw);