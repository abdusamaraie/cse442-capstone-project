import unittest
from pytz import timezone
from datetime import datetime
from datetime import timedelta
from helpers import neo4j


class TestGettingReplies(unittest.TestCase):
    def test_getting_replies(self):
        # set initial vars
        location = {'latitude': 43.0100431, 'longitude': -78.8012356}

        # get current time for time of post
        es = timezone("US/Eastern")
        exp_time = str((datetime.now().astimezone(es) + timedelta(days=7)))

        # add a post to the database in case there isn't one
        post_id = neo4j.post_message('daru', location, "unit test post for getting replies", exp_time)

        # get number of replies before posting one
        replies_json = neo4j.get_post_replies(post_id)
        before_num = len(replies_json)

        # add a reply to the post
        neo4j.reply_to_post("unit test reply", post_id, "daru")

        # get number of replies returned after posting one
        replies_json = neo4j.get_post_replies(post_id)
        after_num = len(replies_json)

        # delete the post created for the test (also deletes replies)
        neo4j.delete_post(post_id)

        self.assertGreater(after_num, before_num)


if __name__ == '__main__':
        unittest.main()
