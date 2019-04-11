import unittest
from helpers import authenticate, neo4j
from objects.user import User
import json

class TestDeleteUser(unittest.TestCase):

    def test_delete_user(self):
        # add username and password to database to signup
        uname = "admin"
        pwd = "admin"
        email = "admin@admin.com"
        fn = "Darren"
        ln = "Matthew"
        password_hash = authenticate.generate_hash(uname, pwd)

        user = User(uname, fn, ln, email, password_hash)
        # test adding user first
        self.assertTrue(neo4j.add_user(user))

        result = neo4j.delete_user(uname, pwd)
        if result == 'False':
            print("user not found")
        else:
            print("THIS: {}".format(result))
            self.assertTrue(result)


if __name__ == '__main__':
        unittest.main()