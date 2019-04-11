import unittest
import json
from datetime import datetime
from pytz import timezone
from datetime import timedelta
from helpers import authenticate, neo4j
from objects.user import User

class TestGetMessages(unittest.TestCase):
    def test_get_messages(self):

        # get location and distance from client
        location = {'latitude': 43.0100431, 'longitude': -78.8012356}
        distance = 30  # radius in meters
        es = timezone("US/Eastern")
        time = str(datetime.now().astimezone(es) + timedelta(days=7))
        place_id = "ChIJwe_oGNJz04kRDxhd61f1WiQ"
        # get number of posts returned
        messages_json = neo4j.get_posts(location, distance)
        before_num = len(json.loads(messages_json))
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


        # add a post to the database
        post_id = neo4j.post_message(uname, location, "unit test post", time, place_id)

        # get number of posts returned after adding one
        messages_json = neo4j.get_posts(location, distance)
        after_num = len(json.loads(messages_json))

        # delete test post
        neo4j.delete_post(post_id)
        # delete user
        neo4j.delete_user(uname, password_hash)
        self.assertGreater(after_num, before_num)


if __name__ == '__main__':
        unittest.main()
