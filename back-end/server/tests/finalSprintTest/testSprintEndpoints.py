import unittest
from pytz import timezone
from datetime import datetime
from datetime import timedelta
from helpers import authenticate, neo4j
import requests,json
from objects.user import User


class TestSprintEndpoints(unittest.TestCase):
    def setUp(self):
        # add username and password to database to signup
        self.uname = "admin"
        self.pwd = "admin"
        self.email = "admin@admin.com"
        self.fn = "Darren"
        self.ln = "Matthew"
        self.brd = "2000/1/1"
        self.hometown = "buffalo"
        self.msg = "this is a neo4j test reply"
        self.place_id = "ChIJwe_oGNJz04kRDxhd61f1WiQ"
        self.radius = 10000
        # get current time for time of post
        es = timezone("US/Eastern")
        self.location = {'latitude': 43.0100431, 'longitude': -78.8012356}
        self.exp_time = str((datetime.now().astimezone(es) + timedelta(days=7)))
        self.password_hash = authenticate.generate_hash(self.uname, self.pwd)

    def test_1_user_signup(self):

        user = neo4j.get_user(self.uname)
        if user == self.uname:
            #delete user if already exists
            print("Deleting user: \n")
            neo4j.delete_user(self.uname, self.password_hash)

        user = User(self.uname, self.fn, self.ln,self.email,
                    self.password_hash,self.brd,self.hometown)
        # test adding user
        self.assertTrue(neo4j.add_user(user))


    def test_2_user_profile(self):
        # Post request payload to server endpoint
        payload = {'username': 'admin'}
        #test ip. I can also test for neo4j cluster ip
        url = 'http://127.0.0.1:5000/profile'
        r = requests.get(url=url,params=payload)
        self.assertEqual(r.status_code, 200)
        print("Getting user profile : \n" + str(r.text) +"\n")

        self.assertTrue(r.text)

    def test_3_posting_messages(self):

        print("Posting A message: \n")

        post_id = neo4j.post_message(self.uname, self.location,
                                     self.msg, self.exp_time, self.place_id)
        print("post id: " + str(post_id) + "\n")
        self.assertNotEqual(post_id, None)

    def test_4_get_place(self):
        payload = {'lat': self.location['latitude'],
                   'long': self.location['longitude'],
                   'radius':self.radius}

        url = 'http://127.0.0.1:5000/place'
        r = requests.get(url=url, params=payload)
        self.assertEqual(r.status_code, 200)
        print("Getting a place : \n" + str(r.text) + "\n")
        self.assertTrue(r.text)

    def test_5_get_message_at_place(self):
        payload = {'placeId':self.place_id}
        url = 'http://127.0.0.1:5000//place/message'
        r = requests.get(url=url, params=payload)
        self.assertEqual(r.status_code, 200)
        print("Getting a message at a place: \n" +str(r.text)+ "\n")

        self.assertTrue(r.text)


    # def test_y_delete_user(self):
    #
    #     user = neo4j.get_user(self.uname)
    #     self.assertEqual(user,self.uname)
    #     # delete user if already exists
    #     neo4j.delete_user(self.uname, self.password_hash)

#    Verify that database has been whipped
    def test_z_wipe_database(self):
        # test ip. I can also test for neo4j cluster ip
        url = 'http://127.0.0.1:5000/neo4j'
        r = requests.delete(url=url)

        print("Whipping database: " + str(r.text) +"\n")
        self.assertTrue(r.text)

if __name__ == '__main__':
        unittest.main()

