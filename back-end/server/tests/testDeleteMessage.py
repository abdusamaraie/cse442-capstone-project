import unittest
import json
from pytz import timezone
from datetime import datetime
from datetime import timedelta
from helpers import neo4j


class TestDeleteMessage(unittest.TestCase):
    def test_delete_message(self):

        # get location and distance from client
        location = {'latitude': 43.0100431, 'longitude': -78.8012356}
        distance = 30  # radius in meters
        es = timezone("US/Eastern")
        time = str(datetime.now().astimezone(es) + timedelta(days=7))
        placeId = 'ChIJwe_oGNJz04kRDxhd61f1WiQ'
        # add a post to the database
        remove_id = neo4j.post_message('admin', location, "unit test post to be removed", time, placeId)
        print(remove_id)

        # get total number of posts
        messages_json = neo4j.get_posts(location, distance)
        before_num = len(json.loads(messages_json))

        # remove the added post
        neo4j.delete_post(remove_id)

        # get number of posts returned after removing
        messages_json = neo4j.get_posts(location, distance)
        after_num = len(json.loads(messages_json))

        self.assertLess(after_num, before_num)


if __name__ == '__main__':
        unittest.main()
