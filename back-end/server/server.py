# Local Helpers
from constants import constants
from helpers import authenticate, sqlite
from objects.user import User

# Flask
from flask import Flask, request

# Core Libaries
import multiprocessing
import signal
import sys

app = Flask(__name__)
 

@app.route('/', methods=['GET'])
def hello_world():
    return 'Hello, World!'


@app.route('/authenticate', methods=['GET', 'POST'])
def authenticate():

    username = request.json['username']
    password = request.json['password']

    # USED FOR SIGN IN
    if request.method == 'GET':

        password_hash = authenticate.generate_hash(password)

        # check if username and password exist
        return authenticate.verify_user(username, password_hash)

    # USED FOR SIGN UP
    else:

        password_hash = authenticate.generate_hash(password)

        user = User(username, password_hash=password_hash)

        return sqlite.add_user(user)


@app.route('message', methods=['GET', 'POST'])
def message():

    # THESE FIELDS ARE REQUIRED BY DEFAULT
    username = request.json['username']
    location = request.json['location']

    # USED FOR RETRIEVING MESSAGES
    if request.method == 'GET':
        distance = request.json['distance']

        return sqlite.get_messages(location, distance)

    # USED TO POST MESSAGE
    else:

        message = request.json['message']

        return sqlite.post_message(username, location, message)



def start_server():
    app.run(host='0.0.0.0', port=5000, debug=True)


def signal_handler(sig, frame):
    sys.exit(0)


def sigint():
    signal.signal(signal.SIGINT, signal_handler)
    print('Press Ctrl+C')
    signal.pause()


if __name__ == '__main__':
    start_server()
    sigint_handler = multiprocessing.Process(target=sigint)
