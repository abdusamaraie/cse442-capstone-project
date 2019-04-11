import unittest,json
from pytz import timezone
from datetime import datetime
from datetime import timedelta
from helpers import neo4j,authenticate
from objects.user import User



class TestPostingMessages(unittest.TestCase):
    def test_posting_messages(self):

        # get location, username, msg, and expiration time from client
        location = {'latitude': 43.0100431, 'longitude': -78.8012356}
        username = "admin"
        msg = "this is a neo4j test post"
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
        # post a message with the above information
        post_id = neo4j.post_message(username, location, msg, exp_time,place_id)
        print(post_id)
        self.assertNotEqual(post_id, None)
        #delete user
        self.assertTrue(neo4j.delete_user(username, password_hash))
        # remove to post created for the test
        neo4j.delete_post(post_id)




if __name__ == '__main__':
        unittest.main()
