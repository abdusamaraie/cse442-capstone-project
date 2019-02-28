import unittest
from datetime import datetime
from datetime import timedelta
from helpers import sqlite


class TestPostingMessages(unittest.TestCase):
    def test_posting_messages(self):

        # get location, username, msg, and time from client
        location = {'latitude': 43.0100431, 'longitude': -78.8012356}
        username = "daru1"
        msg = "this is a test post"
        time = (datetime.now() + timedelta(days=7))

        self.assertTrue(sqlite.post_message(username, location, msg, time))


if __name__ == '__main__':
        unittest.main()
