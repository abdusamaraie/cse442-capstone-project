import unittest
from helpers import authenticate, neo4j
from objects.user import User


class TestAddPhoto(unittest.TestCase):
    def test_add_photo(self):

        username = "admin"
        url = "https://i.kym-cdn.com/photos/images/original/001/297/938/8e6.png"
        # add user to database first
        pwd = "admin"
        email = "admin@admin.com"
        fn = "Darren"
        ln = "Matthew"
        password_hash = authenticate.generate_hash(username, pwd)

        user = User(username, fn, ln, email, password_hash)

        self.assertTrue(neo4j.add_user(user))

        user = neo4j.add_photo(username, url)

        self.assertTrue(user)
        # delete user
        neo4j.delete_user(username, password_hash)
        # self.assertLess(after_num, before_num)


if __name__ == '__main__':
        unittest.main()
