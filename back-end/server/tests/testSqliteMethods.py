import unittest
from helpers import sqlite
from objects.user import User


class TestSqliteMethods(unittest.TestCase):
    def test_add_user(self):
        # get username and password fro User class object
        tempUserName = "admin"
        tempPassword = "admin"
        #create a User object
        user = User(tempUserName,tempPassword)

        #if user does exist the raise error
        self.assertTrue(sqlite.add_user(user))
    def test_get_user(self):

        tempUserName = "admin"
        tempUser = User(tempUserName)
        user = sqlite.get_user(tempUserName)

        self.assertTrue(tempUser.username,user.username)


if __name__ == '__main__':
        unittest.main()