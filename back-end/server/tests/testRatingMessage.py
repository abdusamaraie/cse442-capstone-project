import unittest
from pytz import timezone
from datetime import datetime
from datetime import timedelta
from helpers import authenticate, neo4j
from objects.user import User


class TestRatingMessage(unittest.TestCase):
    def test_rating_messages(self):

        # for creating a post to like
        location = {'latitude': 43.0100431, 'longitude': -78.8012356}
        username = "admin"
        msg = "this is a rating test post"
        place_id = "ChIJwe_oGNJz04kRDxhd61f1WiQ"
        es = timezone("US/Eastern")
        time = str(datetime.now().astimezone(es) + timedelta(days=7))
        # for liking
        rel = "LIKED"

        #add user to database first
        pwd = "admin"
        email = "admin@admin.com"
        fn = "Darren"
        ln = "Matthew"
        password_hash = authenticate.generate_hash(username, pwd)

        user = User(username, fn, ln, email, password_hash)

        self.assertTrue(neo4j.add_user(user))

        # create a test post to add a like to
        post_id = neo4j.post_message(username, location, msg, time,place_id)
        # add like to the post
        success = neo4j.rate_post(post_id, rel, username)

        # delete test post
        neo4j.delete_post(post_id)
        # delete user
        neo4j.delete_user(username, password_hash)
        self.assertTrue(success)


if __name__ == '__main__':
        unittest.main()
