import unittest
from pytz import timezone
from datetime import datetime
from datetime import timedelta
from helpers import neo4j


class TestPostingMessages(unittest.TestCase):
    def test_posting_messages(self):

        # get location, username, msg, and expiration time from client
        location = {'latitude': 43.0100431, 'longitude': -78.8012356}
        username = "daru"
        msg = "this is a neo4j test post"

        # get current time for time of post
        es = timezone("US/Eastern")
        exp_time = str((datetime.now().astimezone(es) + timedelta(days=7)))

        # post a message with the above information
        post_id = neo4j.post_message(username, location, msg, exp_time)

        self.assertNotEqual(post_id, None)

        # remove to post created for the test
        neo4j.delete_post(post_id)


if __name__ == '__main__':
        unittest.main()
