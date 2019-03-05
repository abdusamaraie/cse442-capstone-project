import unittest
import json
from datetime import timedelta
from datetime import datetime
from helpers import sqlite


class TestGettingReplies(unittest.TestCase):
    def test_getting_replies(self):

        # set initial vars
        location = {'latitude': 43.0100431, 'longitude': -78.8012356}
        distance = 30  # radius in meters

        # add a post to the database in case there isn't one
        sqlite.post_message('daru1', location, "unit test post", exp_time=(datetime.now() + timedelta(days=7)))

        # get post id of the first returned post
        messages_json = json.loads(sqlite.get_messages(location, distance))
        post_id = messages_json[0]['post_id']

        # get number of replies before posting one
        replies_json = sqlite.get_post_replies(post_id)
        before_num = len(json.loads(replies_json))

        # add a reply to the post
        sqlite.reply_to_post("unit test reply", post_id, "daru1")

        # get number of replies returned after posting one
        replies_json = sqlite.get_post_replies(post_id)
        after_num = len(json.loads(replies_json))

        self.assertGreater(after_num, before_num)


if __name__ == '__main__':
        unittest.main()
