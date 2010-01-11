function p = WrapPDF(p)

if max(p.intervals) < 360
%     error('debug this');
    interval = p.intervals(2) - p.intervals(1);
    nIntervals = ceil((360-p.intervals(end))/interval);
    end_val = p.intervals(end) + nIntervals*interval;
    x_vals = p.intervals(end)+interval:interval:end_val;
    p.intervals = [p.intervals x_vals];
    p.pdf = [p.pdf zeros(length(p.intervals))];
end

if min(p.intervals) > 0
%     error('debug this');
    interval = p.intervals(2) - p.intervals(1);
    nIntervals = floor(ceil((min(p.intervals))/interval));
    start_val = p.intervals(1) - nIntervals*interval;
    x_vals = start_val:interval:p.intervals(1)-interval;
    p.intervals = [x_vals p.intervals];
    p.pdf = [zeros(1,length(p.intervals)) p.pdf];
end

less_than_0_indices = find(p.intervals < 0, 1, 'last');
greater_than_360_indices = find(p.intervals > 360, 1);
if isempty(less_than_0_indices)
    less_than_0_indices = 0;
end
p.pdf(less_than_0_indices+1:less_than_0_indices+end-greater_than_360_indices+1) = ...
    p.pdf(less_than_0_indices+1:less_than_0_indices+end-greater_than_360_indices+1) + ...
    p.pdf(greater_than_360_indices:end);
if isempty(greater_than_360_indices)
    greater_than_360_indices = length(p.pdf)+1;
end
p.pdf(greater_than_360_indices-less_than_0_indices:greater_than_360_indices-1) = ...
    p.pdf(greater_than_360_indices-less_than_0_indices:greater_than_360_indices-1) + ...
    p.pdf(1:less_than_0_indices);
p.pdf = p.pdf(less_than_0_indices+1:greater_than_360_indices-1);
p.intervals = p.intervals(less_than_0_indices+1:greater_than_360_indices-1);
