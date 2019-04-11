import unittest
from pytz import timezone
from datetime import datetime
from datetime import timedelta
from helpers import neo4j
from helpers import authenticate, neo4j
from objects.user import User

class TestGetMessageHistory(unittest.TestCase):
    def test_get_message_history(self):

        # get location, username, msg, and expiration time from client
        user_location = {'latitude': 13.0100431, 'longitude': -8.8012356}
        location1 = {'latitude': 43.0100431, 'longitude': -78.8012356}
        location2 = {'latitude': 139.0100, 'longitude': -20.8012356}
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
        msg = "this is a test post"
        place_id = "ChIJwe_oGNJz04kRDxhd61f1WiQ"
        # get current time for time of post
        es = timezone("US/Eastern")
        exp_time = str((datetime.now().astimezone(es) + timedelta(days=7)))

        # get number of posts returned
        messages_json = neo4j.get_posts(user_location, 20)
        before_num = len(messages_json)

        # neither of theses messages would be visible normally, but would show up in a user's history
        id1 = neo4j.post_message(username, location1, msg, exp_time,place_id)
        id2 = neo4j.post_message(username, location2, msg, exp_time,place_id)

        # get number of posts returned after
        messages_json = neo4j.get_user_post_history(username)
        after_num = len(messages_json)

        # delete messages created for test
        neo4j.delete_post(id1)
        neo4j.delete_post(id2)
        # delete user
        neo4j.delete_user(username, password_hash)
        self.assertGreater(after_num, before_num)


if __name__ == '__main__':
        unittest.main()
