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
        brd = "2000/1/1"
        hometown = "buffalo"
        password_hash = authenticate.generate_hash(uname,pwd)

        user = neo4j.get_user(uname)
        if user == uname:
            #delete user if already exists
            neo4j.delete_user(uname, password_hash)

        user = User(uname, fn, ln,email, password_hash,brd,hometown)
        # test adding user
        self.assertTrue(neo4j.add_user(user))
        #delete user
        neo4j.delete_user(uname, password_hash)

if __name__ == '__main__':
        unittest.main()
