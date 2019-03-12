import unittest
from datetime import datetime
from datetime import timedelta
from helpers import sqlite


class TestRatingMessage(unittest.TestCase):
    def test_rating_messages(self):

        # for creating a post to like
        location = {'latitude': 43.0100431, 'longitude': -78.8012356}
        username = "daru"
        msg = "this is a test reply"
        time = datetime.now()
        # for liking
        table = "likes"

        # create a test post to add a like to
        post_id = sqlite.post_message(username, location, msg, time)

        # add like to the post
        success = sqlite.rate_message(post_id, table)

        # delete test post
        sqlite.delete_message(post_id)

        self.assertTrue(success)



if __name__ == '__main__':
        unittest.main()
