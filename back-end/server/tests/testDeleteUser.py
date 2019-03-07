import unittest
from helpers import sqlite
from objects.user import User
import json

class TestDeleteUser(unittest.TestCase):

    def test_delete_user(self):
        username = "admin"
        password = "admin"
        result = sqlite.delete_user(username, password)
        if result == False:
            print("user not found")
        else:
            print("THIS: {}".format(result))
            self.assertTrue(result)


if __name__ == '__main__':
        unittest.main()