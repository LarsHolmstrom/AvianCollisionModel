function p = WrapPDF(p)

less_than_0_indices = find(p.x(1,:) < 0, 1, 'last');
greater_than_360_indices = find(p.x(1,:) > 360, 1);
p.f(:,less_than_0_indices+1:less_than_0_indices+end-greater_than_360_indices) = ...
    p.f(:,less_than_0_indices+1:less_than_0_indices+end-greater_than_360_indices) + p.f(:,greater_than_360_indices:end);
r_length = length(p.x(1,:)) - greater_than_360_indices + 1;
p.f(:,greater_than_360_indices-r_length:greater_than_360_indices-1) = p.f(:,greater_than_360_indices-r_length:greater_than_360_indices-1) + p.f(:,1:less_than_0_indices);
p.f = p.f(:,less_than_0_indices+1:greater_than_360_indices-1);
p.x = p.x(:,less_than_0_indices+1:greater_than_360_indices-1);
p.y = p.y(:,less_than_0_indices+1:greater_than_360_indices-1);