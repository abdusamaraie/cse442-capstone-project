from objects.user_radius import UserRadius
from constants.constants import DEGREE_CONVERSION
import math
# converts the user's defined radius from meters to decimal degrees


def get_user_radius(location, distance):
    lat = location['longitude']
    long = location['latitude']

    # the distance between longitude lines changes as they approach the poles, this is accounted for
    latitude_decimal = distance/DEGREE_CONVERSION
    longitude_decimal = distance/(DEGREE_CONVERSION * 1000 * math.cos(lat * (math.pi/180)))

    return UserRadius(lat, long, latitude_decimal, longitude_decimal)
