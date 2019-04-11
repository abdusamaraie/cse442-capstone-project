import unittest
from helpers import authenticate, neo4j
from objects.user import User


class TestUserSignUp(unittest.TestCase):
    #    Verify that user is able to login with valid username and password
    def test_user_signup(self):

        # add username and password to database to signup
        uname = "admin"
        pwd = "admin"
        email = "admin@admin.com"
        fn = "Darren"
        ln = "Matthew"
        password_hash = authenticate.generate_hash(uname,pwd)

        #delete user if already exists
        neo4j.delete_user(uname, password_hash)

        user = User(uname, fn, ln,email, password_hash)
        # test adding user
        self.assertTrue(neo4j.add_user(user))
        #delete user
        neo4j.delete_user(uname, password_hash)

if __name__ == '__main__':
        unittest.main()
