from objects.user_bounds import UserBounds
from constants.constants import DEGREE_CONVERSION
import math
# converts the user's defined radius from meters to decimal degrees


def get_user_radius_bounds(location, distance):
    lat = location['latitude']
    long = location['longitude']

    # the distance between longitude lines changes as they approach the poles, this is accounted for
    latitude_decimal = distance/DEGREE_CONVERSION
    longitude_decimal = distance/(DEGREE_CONVERSION * 1000 * math.cos(lat * (math.pi/180)))

    return UserBounds(lat, long, latitude_decimal, longitude_decimal)
