import unittest
from helpers import authenticate


class TestAuthenticateMethods(unittest.TestCase):
    def test_verify_user(self):
        #get username and password from database
        tempUserName = "abd@gmail.com"
        tempPassword = "123"
        #code here
        self.assertTrue(authenticate.verify_user(tempUserName,tempPassword))


if __name__ == '__main__':
        unittest.main()