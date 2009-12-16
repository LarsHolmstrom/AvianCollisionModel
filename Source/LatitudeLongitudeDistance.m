function distance_in_meters = LatitudeLongitudeDistance(lat1,lon1,lat2,lon2)

%Convert to radians

latrad1 = lat1*pi/180;
lonrad1 = lon1*pi/180;
latrad2 = lat2*pi/180;
lonrad2 = lon2*pi/180;

londif = abs(lonrad2-lonrad1);

raddis = acos(sin(latrad2)*sin(latrad1) + cos(latrad2)*cos(latrad1)*cos(londif));

nautdis = raddis * 3437.74677;
distance_in_meters = nautdis * 1.852 * 1000;
