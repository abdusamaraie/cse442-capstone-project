import unittest
from helpers import sqlite
from objects.user import User


class TestSqliteMethods(unittest.TestCase):
    def test_add_user(self):
        # get username and password fro User class object
        tempUserName = "abd"
        tempPassword = "123"
        #create a User object
        user = User(tempUserName,tempPassword)

        #if user does exist the raise error
        self.assertTrue(sqlite.add_user(user))
    def test_get_user(self):

        tempUserName = "admin"

        self.assertTrue(sqlite.get_user(tempUserName))


if __name__ == '__main__':
        unittest.main()