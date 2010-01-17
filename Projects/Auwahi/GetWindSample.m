function [wind_speed wind_direction] = GetWindSample(slow_wind_pdf, fast_wind_pdf)

chance_of_slow_wind = 0.1;
chance_of_nee_wind = 0.35;
roll = rand(1,1);
if roll<chance_of_slow_wind
    wind_speed = DrawFromPDF(slow_wind_pdf.pdf, slow_wind_pdf.intervals);
    wind_direction = roll * 360/chance_of_slow_wind;
elseif roll<chance_of_slow_wind+chance_of_nee_wind
    wind_speed = DrawFromPDF(fast_wind_pdf.pdf, fast_wind_pdf.intervals);
    wind_direction = rand(1,1)*22.5 + 56.25;
else
    wind_speed = DrawFromPDF(fast_wind_pdf.pdf, fast_wind_pdf.intervals);
    wind_direction = rand(1,1)*22.5 + 78.75;
end