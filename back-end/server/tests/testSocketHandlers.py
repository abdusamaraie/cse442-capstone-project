import unittest
import requests,json
from server import app, socketio
from pytz import timezone
from datetime import datetime
from datetime import timedelta

class TestSocketHandler(unittest.TestCase):

    def setUp(self):
        # log the user in through Flask test client
        self.flask_test_client = app.test_client()

        # connect to Socket.IO without being logged in
        self.socketio_test_client = socketio.test_client(
            app, flask_test_client=self.flask_test_client)
        # propagate the exceptions to the test client
        self.flask_test_client.testing = True

    def test_1_home_status_code(self):
        # sends HTTP GET request to the application
        # on the specified path
        result = self.flask_test_client.get('/')
        # assert the status code of the response
        self.assertEqual(result.status_code, 200)


    def test_2_auth_post_req(self):
        url = 'http://127.0.0.1:5000/auth'
        # Post request payload to server endpoint
        payload = {'username':'admin',
                   'password':'admin',
                   'firstname':'abd',
                   'lastname':'nazar',
                   'email':'admin@admin.com'}
        r = requests.post(url=url, json=payload)
        self.assertEqual(r.status_code, 200)
        print(r.text)
        self.assertEqual(r.text,"True",msg=" User already exists ")

    def test_3_auth_get_req(self):
        url = 'http://127.0.0.1:5000/auth'
        # Get request payload to server endpoint
        payload = {'username': 'admin',
                   'password': 'admin'}
        r = requests.get(url=url, params=payload)
        self.assertEqual(r.status_code, 200)
        print(r.text)
        self.assertEqual(r.text,"True",msg=" User couldn't be retrieved")

    def test_4_message_post_req(self):
        url = 'http://127.0.0.1:5000/message'

        # get current time for time of post
        es = timezone("US/Eastern")
        exp_time = str((datetime.now().astimezone(es) + timedelta(days=7)))

        # post request payload to server endpoint
        payload = {'username': 'admin',
                   'location': {'latitude': 43.0100431,
                                'longitude': -78.8012356},
                   'message': 'hello there again',
                   'expireTime': exp_time,
                   'placeId':'ChIJwe_oGNJz04kRDxhd61f1WiQ'}

        r = requests.post(url=url, json=payload)
        self.assertEqual(r.status_code, 200)
        print(r.text)
        self.assertNotEqual(r.text, None,msg=" Message not found error")




    def test_5_message_get_req(self):
        url = 'http://127.0.0.1:5000/message'
        # get request payload to server endpoint
        payload = {'lat': 43.0100431,
                   'long': -78.8012356,
                   'distance': 30}

        r = requests.get(url=url, params=payload)
        self.assertEqual(r.status_code, 200)
        print(r.text)
        self.assertNotEqual(r.text, None,msg=" Message not found error")



    # use sockets with auth
    def test_6_auth_socket(self):

        # make sure the server rejected the connection
        assert not self.socketio_test_client.is_connected()

        # Post request payload to server endpoint
        payload = {'username':'admin2',
                   'password':'admin2',
                   'firstname':'abd',
                   'lastname':'nazar',
                   'email':'admin2@admin.com'}

        # check if user is already registered
        R = self.flask_test_client.get('/auth', query_string={'username': 'admin2',
                                                            'password': 'admin2'})
        self.assertNotEqual(R.data, b'True')

        # Signup in via HTTP
        r = self.flask_test_client.post('/auth', json=payload)
        assert r.status_code == 200

        # Login user via HTTP
        R = self.flask_test_client.get('/auth', query_string={'username': 'admin2',
                                                              'password': 'admin2'})
        self.assertEqual(R.status_code, 200)

        # Connect to Socket.IO again, but now as a logged in user
        self.socketio_test_client = socketio.test_client(
            app,'/auth', flask_test_client=self.flask_test_client)

        # Invoke socket handler and send event to server
        self.socketio_test_client.emit('my login')

        r = self.socketio_test_client.get_received('/auth')
        self.assertEqual(R.status_code, 200)

        print("socket client r:" + str(r))
        print("flask client R:" + str(R.data))
        assert len(r) == 1
        assert r[0]['name'] == 'my response'
        assert len(r[0]['args']) == 1
        assert r[0]['args'][0] == {'username': 'admin2'}
        # end connection
        self.socketio_test_client.disconnect('/auth')


    def test_7_message_socket_handler(self):
        # make sure the server rejected the connection
        assert not self.socketio_test_client.is_connected()
        #for login
        payload = {'username': 'admin2',
                   'password': 'admin2'}

        # log in via HTTP
        r = self.flask_test_client.get('/auth', query_string=payload)
        assert r.status_code == 200
        self.assertEqual(r.data, b'True')

        # connect to Socket.IO again, but now as a logged in user
        self.socketio_test_client = socketio.test_client(
            app, '/message', flask_test_client=self.flask_test_client)

        # get current time for time of post
        es = timezone("US/Eastern")
        exp_time = str((datetime.now().astimezone(es) + timedelta(days=7)))

        #for message
        payload = {'username': 'admin2',
                   'location':{'latitude': 43.0100431,
                                'longitude': -78.8012356},
                   'message': 'hello',
                   'expireTime': exp_time,
                   'placeId':'ChIJwe_oGNJz04kRDxhd61f1WiQ'}

        #test POST message
        R = self.flask_test_client.post('/message',json=payload)

        self.assertEqual(R.status_code, 200)
        # invoke socket handler and send event to server
        self.socketio_test_client.emit('my message',{'data':'this is a message'})

        r = self.socketio_test_client.get_received('/message')
        self.assertEqual(R.status_code, 200)

        print("flask client R:" + str(R.data))
        print("socket client r:" + str(r))

        self.socketio_test_client.disconnect('/message')


    # def test_socket_connection(self):
    #     #check socket connection
    #     assert self.socketio_test_client.is_connected()



if __name__ == '__main__':
            unittest.main()
