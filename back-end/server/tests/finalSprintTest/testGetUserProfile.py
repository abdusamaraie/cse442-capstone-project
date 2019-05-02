import unittest
from helpers import authenticate, neo4j
import requests,json
from objects.user import User


class TestGetUserProfile(unittest.TestCase):
    def setUp(self):
        # add username and password to database to signup
        self.uname = "admin"
        self.pwd = "admin"
        self.email = "admin@admin.com"
        self.fn = "Darren"
        self.ln = "Matthew"
        self.brd = "2000/1/1"
        self.hometown = "buffalo"
        self.password_hash = authenticate.generate_hash(self.uname, self.pwd)

    def test1_user_signup(self):



        user = neo4j.get_user(self.uname)
        if user == self.uname:
            #delete user if already exists
            neo4j.delete_user(self.uname, self.password_hash)

        user = User(self.uname, self.fn, self.ln,self.email,
                    self.password_hash,self.brd,self.hometown)
        # test adding user
        self.assertTrue(neo4j.add_user(user))


    def test2_user_profile(self):
        # Post request payload to server endpoint
        payload = {'username': 'admin'}
        #test ip. I can also test for neo4j cluster ip
        url = 'http://127.0.0.1:5000/profile'
        r = requests.get(url=url,params=payload)
        self.assertEqual(r.status_code, 200)
        print(r.text)
        self.assertTrue(r.text)
        # delete user
        neo4j.delete_user(self.uname, self.password_hash)

if __name__ == '__main__':
        unittest.main()
