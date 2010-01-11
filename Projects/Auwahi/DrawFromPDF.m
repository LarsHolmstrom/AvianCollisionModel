function result = DrawFromPDF(f,x)

roll = rand(1,1);
draw = find(cumsum(f) > roll,1,'first');
if isempty(draw)
    draw = length(f);
end
result = x(draw);