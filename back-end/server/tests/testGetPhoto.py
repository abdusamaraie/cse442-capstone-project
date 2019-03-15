import unittest
import json
from datetime import datetime
from datetime import timedelta
from helpers import neo4j


class TestGetPhoto(unittest.TestCase):
    def test_get_photo(self):

        username = "daru"
        expected = "https://i.kym-cdn.com/photos/images/original/001/297/938/8e6.png"

        actual = neo4j.get_photo(username)

        self.assertEqual(expected, actual)


if __name__ == '__main__':
        unittest.main()
