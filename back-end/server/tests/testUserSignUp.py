import unittest
from helpers import authenticate


class TestAuthenticateMethods(unittest.TestCase):
    #    Verify that user is able to login with valid username and password
    def test_verify_user(self):

        # get username and password from database
        uname = "daru"
        pwd = "password"

        self.assertTrue(authenticate.verify_user(tempUserName, tempPassword))


if __name__ == '__main__':
        unittest.main()
