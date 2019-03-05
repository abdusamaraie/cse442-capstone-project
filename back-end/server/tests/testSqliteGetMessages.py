import unittest
import json
from datetime import datetime
from datetime import timedelta
from helpers import sqlite


class TestGetMessages(unittest.TestCase):
    def test_get_messages(self):

        # get location and distance from client
        location = {'latitude': 43.0100431, 'longitude': -78.8012356}
        distance = 30  # radius in meters

        # get number of posts returned
        messages_json = sqlite.get_messages(location, distance)
        before_num = len(json.loads(messages_json))

        # add a post to the database
        sqlite.post_message('daru1', location, "unit test post", time=(datetime.now() + timedelta(days=7)))

        # get number of posts returned after adding one
        messages_json = sqlite.get_messages(location, distance)
        after_num = len(json.loads(messages_json))

        self.assertGreater(after_num, before_num)


if __name__ == '__main__':
        unittest.main()
