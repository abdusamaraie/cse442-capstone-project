import unittest
from datetime import datetime
from datetime import timedelta
from helpers import sqlite


class TestPostingMessages(unittest.TestCase):
    def test_posting_messages(self):

        # get location, username, msg, and expiration time from client
        location = {'latitude': 43.0100431, 'longitude': -78.8012356}
        username = "daru"
        msg = "this is a test post"
        exp_time = (datetime.now() + timedelta(days=7))

        # post a message with the above information
        post_id = sqlite.post_message(username, location, msg, exp_time)

        # remove to post created for the test
        sqlite.delete_message(post_id)

        self.assertGreaterEqual(post_id, 0)




if __name__ == '__main__':
        unittest.main()
