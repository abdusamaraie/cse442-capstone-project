import unittest
import json
from pytz import timezone
from datetime import datetime
from datetime import timedelta
from helpers import neo4j


class TestDeletReply(unittest.TestCase):
    def test_delete_reply(self):

        # get msg, username, and post_id from client
        location = {'latitude': 43.0100431, 'longitude': -78.8012356}
        username = "daru"
        msg = "this is a neo4j deletion test reply"

        # get current time for time of post
        es = timezone("US/Eastern")
        exp_time = str((datetime.now().astimezone(es) + timedelta(days=7)))

        # create a test post to reply to
        post_id = neo4j.post_message(username, location, msg, exp_time)
        print(post_id)

        # make a reply to the post
        reply_id = neo4j.reply_to_post(msg, post_id, username)

        # get number of replies returned before removing
        replies_json = neo4j.get_post_replies(post_id)
        before_num = len(json.loads(replies_json))

        # delete test post
        neo4j.delete_reply(reply_id)



        self.assertLess(after_num, before_num)


if __name__ == '__main__':
        unittest.main()
