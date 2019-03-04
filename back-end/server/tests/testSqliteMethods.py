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
        user = sqlite.get_user(tempUserName)
        tempUser = User(tempUserName)

        self.assertEqual(tempUser.username,user.username)

    def test_add_photo(self):
        url = 'database/upload/image.jpg'
        username = "admin"
        self.assertTrue(sqlite.add_photo(username,url))

    #def test_get_photo(self):
     #   self.assertTrue()

if __name__ == '__main__':
        unittest.main()