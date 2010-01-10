function [x y] = DrawFromPDF2(p)

roll = rand(1,1);
draw = find(cumsum(p.f(:)) > roll,1,'first');
if isempty(draw)
    draw = length(p.f(:));
end
x = p.x(draw);
y = p.y(draw);