import unittest
from helpers import authenticate


class TestAuthenticateMethods(unittest.TestCase):
    def test_verify_user(self):
        #get username and password from database
        tempUserName = "abd"
        tempPassword = "123"
        #code here
        self.assertTrue(authenticate.verify_user(tempUserName,tempPassword))

    def test_generate_hash(self):
        tempUserPassword = "123"
        self.assertTrue(authenticate.generate_hash(tempUserPassword))

if __name__ == '__main__':
        unittest.main()