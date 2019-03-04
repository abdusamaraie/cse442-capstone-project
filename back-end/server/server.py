# Local Helpers
from constants.constants import UPLOAD_PATH
from helpers import authenticate, sqlite
from objects.user import User
from objects.filestream import Filestream
# Flask
from flask import Flask, request,json

# Core Libaries
import multiprocessing
import signal
import sys,os,uuid

app = Flask(__name__)
 
app.config['UPLOAD_FOLDER'] = UPLOAD_PATH
app.wsgi_app = Filestream(app.wsgi_app)


@app.route('/', methods=['GET'])
def hello_world():
    return 'Hello, World!'


@app.route('/uploadPhoto', methods=['GET', 'POST'])
def uploadPhoto():
    if request.method == 'POST':
        file = request.files['file']
        extension = os.path.splitext(file.filename)[1]
        f_name = str(uuid.uuid4()) + extension
        file.save(os.path.join(app.config['UPLOAD_FOLDER'], f_name))
        return json.dumps({'filename':f_name})


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


@app.route('/message', methods=['GET', 'POST'])
def message():

    # THESE FIELDS ARE REQUIRED BY DEFAULT
    username = request.json['username']
    location = request.json['location']

    # USED FOR RETRIEVING MESSAGES
    if request.method == 'GET':
        distance = request.json['distance']

        return sqlite.get_messages(location, distance)

    # USED TO POST MESSAGES
    else:
        msg = request.json['message']
        time = request.json['time']

        return sqlite.post_message(username, location, msg, time)



def start_server():
    app.run(host='0.0.0.0', port=5000, debug=True)
    #app.run(host='127.0.0.1', port=5000, debug=True)


def signal_handler(sig, frame):
    sys.exit(0)


def sigint():
    signal.signal(signal.SIGINT, signal_handler)
    print('Press Ctrl+C')
    signal.pause()


if __name__ == '__main__':
    start_server()
    sigint_handler = multiprocessing.Process(target=sigint)
