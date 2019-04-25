import unittest
from helpers import neo4j
import requests,json


class TestWipeDatabase(unittest.TestCase):
    #    Verify that database has been whipped
    def test_wipe_database(self):
        #test ip. I can also test for neo4j cluster ip
        url = 'http://127.0.0.1:5000/neo4j'
        r = requests.delete(url=url)
        print(r.text)
        self.assertTrue(r.text)


if __name__ == '__main__':
        unittest.main()
