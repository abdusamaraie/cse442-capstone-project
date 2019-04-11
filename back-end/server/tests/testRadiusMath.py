import unittest
import json
from helpers import radius_math


class TestRadiusMath(unittest.TestCase):
    def test_radius_math(self):

        # get location and distance from client
        location = {"latitude": 43.0100431, "longitude": -78.8012356}
        distance = 30  # radius in meters


        bounds = radius_math.get_user_radius_bounds(location, distance)
        # check that each point is further in their respective directions from the origin (the user location)
        ngt = bounds.lat_N > location['latitude']  # north greater than
        slt = bounds.lat_S < location['latitude']  # south less than
        egt = bounds.long_E > location['longitude']  # east greater than
        wgt = bounds.long_W < location['longitude']  # west less

        self.assertTrue(ngt and slt and egt and wgt)


if __name__ == '__main__':
        unittest.main()
