import unittest
from datetime import datetime
from datetime import timedelta
from helpers import sqlite


class TestRatingMessage(unittest.TestCase):
    def test_rating_messages(self):

        # get rating and post_id from client
        post_id = 1
        table = "likes"

        self.assertTrue(sqlite.rate_message(post_id, table))


if __name__ == '__main__':
        unittest.main()
