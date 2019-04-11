import unittest
from pytz import timezone
from datetime import datetime
from datetime import timedelta
from helpers import neo4j,authenticate
from objects.user import User


class TestPostingReply(unittest.TestCase):
    def test_posting_replies(self):

        # get msg, username, and post_id from client
        location = {'latitude': 43.0100431, 'longitude': -78.8012356}
        username = "admin"
        msg = "this is a neo4j test reply"
        place_id = "ChIJwe_oGNJz04kRDxhd61f1WiQ"

        # get current time for time of post
        es = timezone("US/Eastern")
        exp_time = str((datetime.now().astimezone(es) + timedelta(days=7)))
        # add username and password to database to signup
        pwd = "admin"
        email = "admin@admin.com"
        fn = "Darren"
        ln = "Matthew"
        password_hash = authenticate.generate_hash(username, pwd)
        user = User(username, fn, ln, email, password_hash)
        # test adding user
        self.assertTrue(neo4j.add_user(user))
        # create a test post to reply to
        post_id = neo4j.post_message(username, location, msg, exp_time,place_id)
        print(post_id)

        self.assertTrue(neo4j.reply_to_post(msg, post_id, username))

        # delete test post
        neo4j.delete_post(post_id)
        # delete user
        self.assertTrue(neo4j.delete_user(username, password_hash))

if __name__ == '__main__':
        unittest.main()
