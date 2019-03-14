import unittest
from pytz import timezone
from datetime import datetime
from datetime import timedelta
from helpers import neo4j


class TestPostingReply(unittest.TestCase):
    def test_posting_replies(self):

        # get msg, username, and post_id from client
        location = {'latitude': 43.0100431, 'longitude': -78.8012356}
        username = "daru"
        msg = "this is a neo4j test reply"

        # get current time for time of post
        es = timezone("US/Eastern")
        exp_time = str((datetime.now().astimezone(es) + timedelta(days=7)))

        # create a test post to reply to
        post_id = neo4j.post_message(username, location, msg, exp_time)
        print(post_id)

        self.assertTrue(neo4j.reply_to_post(msg, post_id, username))

        # delete test post
        neo4j.delete_post(post_id)


if __name__ == '__main__':
        unittest.main()
