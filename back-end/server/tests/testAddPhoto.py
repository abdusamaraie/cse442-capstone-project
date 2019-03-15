import unittest
import json
from datetime import datetime
from datetime import timedelta
from helpers import neo4j


class TestAddPhoto(unittest.TestCase):
    def test_add_user(self):

        username = "daru"
        url = "https://i.kym-cdn.com/photos/images/original/001/297/938/8e6.png"

        user = neo4j.add_photo(username, url)

        self.assertTrue(user)
        # self.assertLess(after_num, before_num)


if __name__ == '__main__':
        unittest.main()
