import unittest
import json
from datetime import datetime
from helpers import sqlite


class TestPostingMessages(unittest.TestCase):
    def test_posting_messages(self):

        # get location, username, msg, and expiration time from client
        user_location = {'latitude': 13.0100431, 'longitude': -8.8012356}

        location1 = {'latitude': 43.0100431, 'longitude': -78.8012356}
        location2 = {'latitude': 139.0100, 'longitude': -20.8012356}

        username = "daru1"
        msg = "this is a test post"
        exp_time = datetime.now()

        # get number of posts returned
        messages_json = sqlite.get_messages(user_location, 20)
        before_num = len(json.loads(messages_json))

        # neither of theses messages would be visible normally
        id1 = sqlite.post_message(username, location1, msg, exp_time)
        id2 = sqlite.post_message(username, location2, msg, exp_time)

        messages_json = sqlite.get_user_message_history(username)
        after_num = len(json.loads(messages_json))

        self.assertGreater(after_num, before_num)


if __name__ == '__main__':
        unittest.main()
