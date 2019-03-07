import unittest
from helpers import sqlite
from objects.user import User
import json

class TestSqliteMethods(unittest.TestCase):
    def test_add_user(self):
        # get username and password fro User class object
        tempUserName = "admin"
        tempPassword = "admin"
        #create a User object
        user = User(tempUserName,tempPassword)
        # if user does not exist then raise error
        if self.assertIsNotNone(sqlite.add_user(user)):
            print("No user found")
        else:
            print("User has been added")

    def test_get_user(self):

        tempUserName = "admin"
        user = sqlite.get_user(tempUserName)
        tempUser = User(tempUserName)

        self.assertEqual(tempUser.username,user.username)

    def test_add_photo(self):
        url = "database/uploads/image.jpg"
        username = "admin"
        self.assertTrue(sqlite.add_photo(username,url))

    def test_get_photo(self):
        username = "admin"
        tempfilepath = "database/uploads/image.jpg"

        photoPath = sqlite.get_photo(username)
        self.assertTrue(photoPath)
        filePath = json.loads(photoPath)

        self.assertEqual(filePath['filename'],tempfilepath)

if __name__ == '__main__':
        unittest.main()