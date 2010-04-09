a = 2.9868;
b = 75.8201;

% data = gamrnd(a,b,1,10000);
% data = [0:1:1000];
load flight_heights
data = flight_heights;

% cdf_sample = 0:1:round(max(data))+1;
cdf_sample = 0:1:1000;
cdf = [cdf_sample' gamcdf(cdf_sample,a,b)'];

figure
hold on
p2 = plot(cdf_sample', gamcdf(cdf_sample,a,b)','r')
p1 = cdfplot(data);
set(p1,'LineWidth',3)
set(p2,'LineWidth',3)
title('');
xlabel('Bird Height (m)');
ylabel('CDF');
legend({'Gamma CDF','Empirical CDF'});
PrintFigure('GammaFitTest','png',5,4);

[h,p,ksstat,cv] = kstest(data, cdf, 0.05)

