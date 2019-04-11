import unittest
import json
from pytz import timezone
from datetime import datetime
from datetime import timedelta
from helpers import authenticate, neo4j
from objects.user import User

class TestDeleteReply(unittest.TestCase):
    def test_delete_reply(self):

        # get msg, username, and post_id from client
        location = {'latitude': 43.0100431, 'longitude': -78.8012356}
        username = "admin"
        pwd = "admin"
        email = "admin@admin.com"
        fn = "Darren"
        ln = "Matthew"
        password_hash = authenticate.generate_hash(username, pwd)

        # delete user if already exists
        neo4j.delete_user(username, password_hash)

        user = User(username, fn, ln, email, password_hash)
        # test adding user
        self.assertTrue(neo4j.add_user(user))
        msg = "this is a neo4j deletion test reply"
        placeId = 'ChIJwe_oGNJz04kRDxhd61f1WiQ'

        # get current time for time of post
        es = timezone("US/Eastern")
        exp_time = str((datetime.now().astimezone(es) + timedelta(days=7)))

        # create a test post to reply to
        post_id = neo4j.post_message(username, location, msg, exp_time,placeId)
        print(post_id)

        # make a reply to the post
        reply_id = neo4j.reply_to_post(msg, post_id, username)

        # get number of replies returned before removing
        replies_json = neo4j.get_post_replies(post_id)
        before_num = len(json.loads(replies_json))

        # delete test reply
        neo4j.delete_reply(reply_id)

        # get number of replies returned after removing
        replies_json = neo4j.get_post_replies(post_id)
        after_num = len(json.loads(replies_json))

        self.assertLess(after_num, before_num)

        # delete test post
        neo4j.delete_post(post_id)
        # delete user
        neo4j.delete_user(username, password_hash)

if __name__ == '__main__':
        unittest.main()
