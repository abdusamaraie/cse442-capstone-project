import unittest
import json
from datetime import datetime
from datetime import timedelta
from helpers import sqlite


class TestDeleteMessage(unittest.TestCase):
    def test_delete_message(self):

        # get location and distance from client
        location = {'latitude': 43.0100431, 'longitude': -78.8012356}
        distance = 30  # radius in meters

        # add a post to the database
        remove_id = sqlite.post_message('daru1', location, "unit test post to be removed", exp_time=(datetime.now() + timedelta(days=7)))

        # get total number of posts
        messages_json = sqlite.get_messages(location, distance)
        before_num = len(json.loads(messages_json))

        # remove the added post
        sqlite.delete_message(remove_id)

        # get number of posts returned after removing
        messages_json = sqlite.get_messages(location, distance)
        after_num = len(json.loads(messages_json))

        self.assertLess(after_num, before_num)


if __name__ == '__main__':
        unittest.main()
