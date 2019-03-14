import unittest
from helpers import authenticate, neo4j
from objects.user import User


class TestUserSignUp(unittest.TestCase):
    #    Verify that user is able to login with valid username and password
    def test_user_signup(self):

        # get username and password from database
        uname = "daru"
        pwd = "password"
        fn = "Darren"
        ln = "Matthew"
        password_hash = authenticate.generate_hash(pwd)

        user = User(uname, fn, ln, password_hash)

        self.assertTrue(neo4j.add_user(user))


if __name__ == '__main__':
        unittest.main()
