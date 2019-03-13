import unittest
import json
from datetime import datetime
from datetime import timedelta
from helpers import neo4j


class TestGetUser(unittest.TestCase):
    def test_get_user(self):

        username = "daru"

        user = neo4j.get_user(username)

        self.assertEqual(user['username'], 'daru')
        # self.assertLess(after_num, before_num)


if __name__ == '__main__':
        unittest.main()
