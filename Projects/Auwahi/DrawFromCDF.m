function result = DrawFromCDF(f,x)

roll = rand(1,1);
draw = find(f > roll,1,'first');
if isempty(draw)
    draw = length(f);
end
result = x(draw);