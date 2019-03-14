import unittest
from pytz import timezone
from datetime import datetime
from datetime import timedelta
from helpers import neo4j


class TestRatingMessage(unittest.TestCase):
    def test_rating_messages(self):

        # for creating a post to like
        location = {'latitude': 43.0100431, 'longitude': -78.8012356}
        username = "daru"
        msg = "this is a rating test post"
        es = timezone("US/Eastern")
        time = str(datetime.now().astimezone(es) + timedelta(days=7))
        # for liking
        rel = "LIKED"

        # create a test post to add a like to
        post_id = neo4j.post_message(username, location, msg, time)
        print(post_id)
        # add like to the post
        success = neo4j.rate_post(post_id, rel, username)

        # delete test post
        neo4j.delete_post(post_id)

        self.assertTrue(success)


if __name__ == '__main__':
        unittest.main()
