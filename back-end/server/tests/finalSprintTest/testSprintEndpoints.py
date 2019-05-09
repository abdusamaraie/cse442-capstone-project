import unittest,os,uuid
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
        user = User(self.uname, self.fn, self.ln, self.email,
                    self.password_hash, self.brd, self.hometown)
        neo4j.delete_user(self.uname, self.password_hash)
        neo4j.add_user(user)
        self.post_id = neo4j.post_message(self.uname, self.location,
                           self.msg, self.exp_time, self.place_id)


    def test_1_get_user_profile(self):
        # Post request payload to server endpoint
        payload = {'username': 'admin'}
        #test ip. I can also test for neo4j cluster ip
        url = 'http://127.0.0.1:5000/profile'
        r = requests.get(url=url,params=payload)
        self.assertEqual(r.status_code, 200)
        print("CSE-125/Getting user profile : \n" + str(r.text) +"\n")

        self.assertTrue(r.text)

    def test_2_get_user_setting(self):
        payload = {'username': self.uname}
        url = 'http://127.0.0.1:5000/settings'

        r = requests.get(url, params=payload)
        self.assertEqual(r.status_code, 200)
        print("CSE-67/Getting user Profile setting: \n" + str(r.text) + "\n")
        self.assertTrue(r.text)



    def test_3_get_place(self):
        payload = {'lat': self.location['latitude'],
                   'long': self.location['longitude'],
                   'radius':self.radius}

        url = 'http://127.0.0.1:5000/place'
        r = requests.get(url=url, params=payload)
        self.assertEqual(r.status_code, 200)
        print("Getting a place : \n" + str(r.text) + "\n")
        self.assertTrue(r.text)

    def test_4_get_message_at_place(self):
        payload = {'placeId':self.place_id}
        url = 'http://127.0.0.1:5000/place/message'
        r = requests.get(url=url, params=payload)
        self.assertEqual(r.status_code, 200)
        print("Getting a message at a place: \n" +str(r.text)+ "\n")

        self.assertTrue(r.text)

    def test_5_get_user_post_history(self):

        payload = {'username': self.uname}
        url = 'http://127.0.0.1:5000/history/posts'

        r = requests.get(url, params=payload)
        self.assertEqual(r.status_code, 200)
        print("CSE-111/Getting user posts history: \n" + str(r.text) + "\n")
        self.assertTrue(r.text)

    def test_6_get_user_ratings(self):
        payload = {'username': self.uname}
        url = 'http://127.0.0.1:5000/history/ratings'


        relation = "LIKED"
        self.msg = "This message for a reply"

        neo4j.rate_post(self.post_id,relation,self.uname)

        r = requests.get(url, params=payload)
        self.assertEqual(r.status_code, 200)
        print("CSE-111/Getting user rating: \n" + str(r.text) + "\n")
        self.assertTrue(r.text)

    def test_7_check_If_user_didrare(self):

        payload = {'postId': self.post_id,
                   'username': self.uname}

        relation = "DISLIKED"
        self.msg = "This message for a rating"

        neo4j.rate_post(self.post_id, relation, self.uname)

        url = 'http://127.0.0.1:5000/didrate'
        r = requests.get(url, params=payload)

        self.assertEqual(r.status_code, 200)
        print("CSE-118/Checking if user did rate a post: \n" + str(r.text) + "\n")
        self.assertTrue(r.text)


    def test_8_get_user_reply_history(self):
        payload = {'username': self.uname}
        url = 'http://127.0.0.1:5000/history/replies'

        self.msg = "This is a second reply"

        self.assertTrue(neo4j.reply_to_post(self.msg, self.post_id, self.uname))

        r = requests.get(url, params=payload)
        self.assertEqual(r.status_code, 200)
        print("CSE-111/Getting user reply history: \n" + str(r.text) + "\n")
        self.assertTrue(r.text)


    # def test_9_upload_profile_image(self):
    #
    #     url = 'http://127.0.0.1:5000/profile/image'
    #     file = 'C:/Users/abdu/Desktop/wallpapers/pic.jpg'
    #     payload = {'username': self.uname}
    #     r = requests.get(url,json=payload)
    #
    #     self.assertEqual(r.status_code, 200)
    #     print("Uploading profile photo: \n" + str(r.text) + "\n")
    #     self.assertTrue(r.text)



   #Verify that database has been whipped
    def test_z_wipe_database(self):
        # test ip. I can also test for neo4j cluster ip
        url = 'http://127.0.0.1:5000/neo4j'
        r = requests.delete(url=url)
        print("Deleting user: \n")
        neo4j.delete_user(self.uname, self.password_hash)
        print("Cleaning database: " + str(r.text) +"\n")
        self.assertTrue(r.text)

if __name__ == '__main__':
        unittest.main()

