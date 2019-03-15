import unittest
from pytz import timezone
from datetime import datetime
from datetime import timedelta
from helpers import neo4j


class TestGetMessageHistory(unittest.TestCase):
    def test_get_message_history(self):

        # get location, username, msg, and expiration time from client
        user_location = {'latitude': 13.0100431, 'longitude': -8.8012356}
        location1 = {'latitude': 43.0100431, 'longitude': -78.8012356}
        location2 = {'latitude': 139.0100, 'longitude': -20.8012356}
        username = "daru"
        msg = "this is a test post"

        # get current time for time of post
        es = timezone("US/Eastern")
        exp_time = str((datetime.now().astimezone(es) + timedelta(days=7)))

        # get number of posts returned
        messages_json = neo4j.get_posts(user_location, 20)
        before_num = len(messages_json)

        # neither of theses messages would be visible normally, but would show up in a user's history
        id1 = neo4j.post_message(username, location1, msg, exp_time)
        id2 = neo4j.post_message(username, location2, msg, exp_time)

        # get number of posts returned after
        messages_json = neo4j.get_user_post_history(username)
        after_num = len(messages_json)

        # delete messages created for test
        neo4j.delete_post(id1)
        neo4j.delete_post(id2)

        self.assertGreater(after_num, before_num)


if __name__ == '__main__':
        unittest.main()
