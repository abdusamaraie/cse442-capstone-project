import unittest
from helpers import authenticate, neo4j
from objects.user import User


class TestGetUser(unittest.TestCase):
    def test_get_user(self):
        # add username and password to database to signup
        username = "admin"
        pwd = "admin"
        email = "admin@admin.com"
        fn = "Darren"
        ln = "Matthew"
        password_hash = authenticate.generate_hash(username, pwd)

        # delete user if already exists
        neo4j.delete_user(username, password_hash)

        user = User(username, fn, ln, email, password_hash)
        # test adding user
        self.assertTrue(neo4j.add_user(user))

        user = neo4j.get_user(username)

        self.assertEqual(user['username'], username)
        # self.assertLess(after_num, before_num)
        # delete user
        neo4j.delete_user(username, password_hash)


if __name__ == '__main__':
        unittest.main()
