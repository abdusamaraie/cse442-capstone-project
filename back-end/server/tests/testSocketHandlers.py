import unittest
import requests,json
from server import app, socketio


class TestSocketHandler(unittest.TestCase):

    def setUp(self):
        # log the user in through Flask test client
        self.flask_test_client = app.test_client()

        # connect to Socket.IO without being logged in
        self.socketio_test_client = socketio.test_client(
            app, flask_test_client=self.flask_test_client)
        # propagate the exceptions to the test client
        self.flask_test_client.testing = True

    def test_home_status_code(self):
        # sends HTTP GET request to the application
        # on the specified path
        result = self.flask_test_client.get('/')
        # assert the status code of the response
        self.assertEqual(result.status_code, 200)


    def test_auth_endpoint(self):
        url = 'http://127.0.0.1:5000/auth'
        #post
        payload = {'username':'admin',
                   'password':'admin',
                   'firstname':'abd',
                   'lastname':'nazar',
                   'email':'admin@admin.com'}
        r = requests.post(url=url, json=payload)
        self.assertTrue(r.text)
        print(r.text)
        if r.text == True:
            print("user has signed up")
        else:
            print("error user exists ")



        #get
        payload = {'username': 'admin',
                   'password': 'admin'}
        r = requests.get(url=url, params=payload)

        self.assertTrue(r.text)

    def test_message_endpoint(self):
        url = 'http://127.0.0.1:5000/message'

        # post
        payload = {'username': 'admin',
                   'location': {'latitude': '50',
                                'longitude': '50'},
                   'message': 'hello',
                   'expireTime': 'now',
                   'placeId':'123'}

        # post
        r = requests.post(url=url, json=payload)
        if r.text:
            print("message posting error")
        else:
            print("successfully posted")
        # get
        payload = {'lat': '50',
                   'lon': '51',
                   'distance': '52'}

        r = requests.get(url=url, params=payload)

        print(r.text)
        self.assertEqual(r.status_code, 200)



    def test_auth_socket(self):

        # make sure the server rejected the connection
        assert not self.socketio_test_client.is_connected()

        # post
        payload = {'username':'admin',
                   'password':'admin',
                   'firstname':'abd',
                   'lastname':'nazar',
                   'email':'admin@admin.com'}

        # log in via HTTP
        r = self.flask_test_client.post('/auth', json=payload)
        assert r.status_code == 200

        # test GET
        R = self.flask_test_client.get('/auth', query_string=payload)
        self.assertEqual(R.status_code, 200)

        # connect to Socket.IO again, but now as a logged in user
        self.socketio_test_client = socketio.test_client(
            app,'/auth', flask_test_client=self.flask_test_client)

        # # test POST
        # R = self.flask_test_client.post('/auth',json=payload)
        # test GET with non registered user
        R = self.flask_test_client.get('/auth', query_string={'username':'admin',
                   'password':'addmin'})
        self.assertEqual(R.status_code, 200)

        #invoke socket handler and send event to server
        self.socketio_test_client.emit('my login')

        r = self.socketio_test_client.get_received('/auth')
        print("client R:" + str(R.data))
        print("client r:" + str(r))
        self.assertEqual(R.status_code, 200)
        self.socketio_test_client.disconnect('/auth')


    def test_message_socket_handler(self):
        # make sure the server rejected the connection
        assert not self.socketio_test_client.is_connected()
        #for login
        payload = {'username': 'admin',
                   'password': 'admin'}

        # log in via HTTP
        r = self.flask_test_client.post('/login', data=payload)
        assert r.status_code == 200

        # connect to Socket.IO again, but now as a logged in user
        self.socketio_test_client = socketio.test_client(
            app, '/message', flask_test_client=self.flask_test_client)
        #for message
        payload = {'username': 'admin',
                   'location': {'latitude': '50',
                                'longitude': '50'},
                   'message': 'hello',
                   'expireTime': 'now'}

        #test POST
        R = self.flask_test_client.post('/message',json=payload)

        # test GET
        #R = self.flask_test_client.get('/', query_string=payload)

        self.assertEqual(R.status_code, 200)
        # invoke socket handler and send event to server
        self.socketio_test_client.emit('my message',{'data':'this is a message'})

        r = self.socketio_test_client.get_received('/message')
        print("client R:" + str(R.data))
        print("client r:" + str(r))
        self.assertEqual(R.status_code, 200)
        self.socketio_test_client.disconnect('/message')


    # def test_socket_connection(self):
    #     #check socket connection
    #     assert self.socketio_test_client.is_connected()



if __name__ == '__main__':
            unittest.main()
