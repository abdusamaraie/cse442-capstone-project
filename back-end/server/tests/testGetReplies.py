import unittest
from pytz import timezone
from datetime import datetime
from datetime import timedelta
from helpers import authenticate, neo4j
from objects.user import User


class TestGettingReplies(unittest.TestCase):
    def test_getting_replies(self):
        # set initial vars
        location = {'latitude': 43.0100431, 'longitude': -78.8012356}

        # get current time for time of post
        es = timezone("US/Eastern")
        exp_time = str((datetime.now().astimezone(es) + timedelta(days=7)))
        place_id = "ChIJwe_oGNJz04kRDxhd61f1WiQ"
        # add username and password to database to signup
        uname = "admin"
        pwd = "admin"
        email = "admin@admin.com"
        fn = "Darren"
        ln = "Matthew"
        password_hash = authenticate.generate_hash(uname, pwd)

        # delete user if already exists
        neo4j.delete_user(uname, password_hash)

        user = User(uname, fn, ln, email, password_hash)
        # test adding user
        self.assertTrue(neo4j.add_user(user))

        # add a post to the database in case there isn't one
        post_id = neo4j.post_message(uname, location, "unit test post for getting replies", exp_time,place_id)

        # get number of replies before posting one
        replies_json = neo4j.get_post_replies(post_id)
        before_num = len(replies_json)

        # add a reply to the post
        neo4j.reply_to_post("unit test reply", post_id, uname)

        # get number of replies returned after posting one
        replies_json = neo4j.get_post_replies(post_id)
        after_num = len(replies_json)

        # delete the post created for the test (also deletes replies)
        neo4j.delete_post(post_id)
        # delete user
        neo4j.delete_user(uname, password_hash)
        self.assertGreater(after_num, before_num)


if __name__ == '__main__':
        unittest.main()
