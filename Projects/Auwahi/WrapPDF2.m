function p = WrapPDF2(p)

if max(p.x(1,:)) < 360
    interval = p.x(1,2) - p.x(1,1);
    nIntervals = ceil((360-p.x(1,end))/interval);
    end_val = p.x(1,end) + nIntervals*interval;
    x_vals = p.x(1,end)+interval:interval:end_val;
    x_vals = repmat(x_vals,size(p.x,1),1);
    p.x = [p.x x_vals];
    p.y = [p.y repmat(p.y(:,1),1,nIntervals)];
    p.f = [p.f zeros(size(p.y,1),size(p.y,2))];
end

less_than_0_indices = find(p.x(1,:) < 0, 1, 'last');
greater_than_360_indices = find(p.x(1,:) > 360, 1);
if isempty(less_than_0_indices)
    less_than_0_indices = 0;
end
p.f(:,less_than_0_indices+1:less_than_0_indices+end-greater_than_360_indices+1) = ...
    p.f(:,less_than_0_indices+1:less_than_0_indices+end-greater_than_360_indices+1) + ...
    p.f(:,greater_than_360_indices:end);
if isempty(greater_than_360_indices)
    greater_than_360_indices = size(p.f,2)+1;
end
p.f(:,greater_than_360_indices-less_than_0_indices:greater_than_360_indices-1) = ...
    p.f(:,greater_than_360_indices-less_than_0_indices:greater_than_360_indices-1) + ...
    p.f(:,1:less_than_0_indices);
p.f = p.f(:,less_than_0_indices+1:greater_than_360_indices-1);
p.x = p.x(:,less_than_0_indices+1:greater_than_360_indices-1);
p.y = p.y(:,less_than_0_indices+1:greater_than_360_indices-1);

if min(p.y(:,1)) < 0
    less_than_0_indices_y = find(p.y(:,1) < 0, 1, 'last');
    p.x = p.x(less_than_0_indices_y+1:end,:);
    p.y = p.y(less_than_0_indices_y+1:end,:);
    p.f = p.f(less_than_0_indices_y+1:end,:);
    p.f = p.f/sum(p.f(:));
end