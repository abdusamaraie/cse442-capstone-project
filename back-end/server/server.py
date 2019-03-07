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
 
#app.config['UPLOAD_FOLDER'] = UPLOAD_PATH
#app.wsgi_app = Filestream(app.wsgi_app)


@app.route('/', methods=['GET'])
def hello_world():
    return 'Hello, World!'


@app.route('/uploadPhoto', methods=['GET', 'POST'])
def uploadPhoto():

    username = request.json['username']

    if request.method == 'POST':
        file = request.json['file'] #if request in json format from frontend clint
        ''' 
        #will implement from front end side where swift will ask user to upload a photo 
        from file explorer and return a file path
        file = request.files['file'] # open file browser to choose an image from user system
        extension = os.path.splitext(file.filename)[1]
        f_name = str(uuid.uuid4()) + extension
        file.save(os.path.join(app.config['UPLOAD_FOLDER'], f_name))'''
          # add photo path to database
        return str(sqlite.add_photo(username, file))

    else:

        return str(sqlite.get_photo(username))


@app.route('/authenticate', methods=['GET', 'POST'])
def auth():

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

        return str(sqlite.add_user(user))


@app.route('/message', methods=['GET', 'POST'])
def message():

    # THESE FIELDS ARE REQUIRED BY DEFAULT
    username = request.json['username']

    # USED FOR RETRIEVING MESSAGES
    if request.method == 'GET':
        # if location isn't given, get all messages from given username
        if not ('location' in request.json or 'distance' in request.json):
            # get all messages for the given user (10 at a time)
            return sqlite.get_user_message_history(username)

        else:
            # if location and
            location = request.json['location']
            distance = request.json['distance']
            return sqlite.get_messages(location, distance)

    # USED TO POST MESSAGES
    else:
        location = request.json['location']
        msg = request.json['message']
        expire_time = request.json['expireTime']
        return str(sqlite.post_message(username, location, msg, expire_time))


@app.route('/rate', methods=['POST'])
def rate():
    # GET RATING
    rating = request.json['rating']

    # PARSE RATING (true is a like, false is a dislike)
    if rating:
        table = "likes"
    else:
        table = "dislikes"

    # GET POST ID
    post_id = request.json['postId']

    return str(sqlite.rate_message(post_id, table))


@app.route('/replies', methods=['GET', 'POST'])
def replies():

    # REQUIRED BY DEFAULT
    post_id = request.json['postId']

    # USED FOR REPLYING TO A POST
    if request.method == 'POST':
        username = request.json['username']
        reply_text = request.json['replyText']
        return str(sqlite.reply_to_post(reply_text, post_id, username))

    # USED FOR RETRIEVING A POST'S REPLIES
    else:
        return sqlite.get_post_replies(post_id)


@app.route('/deletemessage', methods=['POST'])
def replies():

    # REQUIRED BY DEFAULT
    post_id = request.json['postId']

    # USED FOR REPLYING TO A POST
    if request.method == 'POST':
        return sqlite.delete_message(post_id)



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
