a = 2.9868;
b = 75.8201;

% data = gamrnd(a,b,1,10000);
% data = [0:1:1000];
load flight_heights
data = flight_heights;

cdf_sample = 0:1:round(max(data))+1;
cdf = [cdf_sample' gamcdf(cdf_sample,a,b)'];

figure
cdfplot(data);
% figure
hold on
plot(cdf_sample', gamcdf(cdf_sample,a,b)','r')

[h,p,ksstat,cv] = kstest(data, cdf, 0.05)