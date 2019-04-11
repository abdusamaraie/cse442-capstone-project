import unittest
from helpers import authenticate, neo4j
from objects.user import User


class TestGetPhoto(unittest.TestCase):
    def test_get_photo(self):
        # add username and password to database to signup
        username = "admin"
        pwd = "admin"
        email = "admin@admin.com"
        fn = "Darren"
        ln = "Matthew"
        password_hash = authenticate.generate_hash(username, pwd)

        user = User(username, fn, ln, email, password_hash)
        # test adding user first
        self.assertTrue(neo4j.add_user(user))

        expected = "https://i.kym-cdn.com/photos/images/original/001/297/938/8e6.png"
        #add photo first
        user = neo4j.add_photo(username, expected)
        #test if photo is added
        self.assertTrue(user)

        actual = neo4j.get_photo(username)

        self.assertEqual(expected, actual)
        neo4j.delete_user(username, pwd)

if __name__ == '__main__':
        unittest.main()
