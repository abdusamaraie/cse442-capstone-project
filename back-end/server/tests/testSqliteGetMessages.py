import unittest
import json
from helpers import sqlite


class TestGetMessages(unittest.TestCase):
    def test_get_messages(self):

        # get location and distance from client
        location = json.dump({'latitude': '43.0100431', 'longitude': '-78.8012356'})
        distance = 30  # radius in meters

        messages_json = sqlite.get_messages(location, distance)
        num_messages = len(json.loads(messages_json))

        self.assertTrue(num_messages, 2)


if __name__ == '__main__':
        unittest.main()
