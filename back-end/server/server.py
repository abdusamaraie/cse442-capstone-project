# Local Helpers
from constants.constants import UPLOAD_PATH
from helpers import authenticate, neo4j
from objects.user import User
from objects.filestream import Filestream
# Flask
from flask import Flask, request, json

# Core Libaries
import multiprocessing
import signal
import sys, os, uuid

app = Flask(__name__)


# app.config['UPLOAD_FOLDER'] = UPLOAD_PATH
# app.wsgi_app = Filestream(app.wsgi_app)


@app.route('/', methods=['GET'])
def hello_world():
    return 'Hello, World!'


@app.route('/uploadPhoto', methods=['GET', 'POST'])
def uploadPhoto():
    username = request.args.get('username')

    if request.method == 'POST':
        file = request.json['file']  # if request in json format from frontend clint
        ''' 
        #will implement from front end side where swift will ask user to upload a photo 
        from file explorer and return a file path
        file = request.files['file'] # open file browser to choose an image from user system
        extension = os.path.splitext(file.filename)[1]
        f_name = str(uuid.uuid4()) + extension
        file.save(os.path.join(app.config['UPLOAD_FOLDER'], f_name))'''
        # add photo path to database
        return str(neo4j.add_photo(username, file))

    else:

        return str(neo4j.get_photo(username))


@app.route('/auth', methods=['GET', 'POST'])
def auth():
    username = request.args.get('username')
    password = request.args.get('password')

    # USED FOR SIGN IN
    if request.method == 'GET':

        password_hash = authenticate.generate_hash(password)

        # check if username and password exist
        return authenticate.verify_user(username, password_hash)

    # USED FOR SIGN UP
    else:

        password_hash = authenticate.generate_hash(password)

        user = User(username, password_hash=password_hash)

        return str(neo4j.add_user(user))


@app.route('/message', methods=['GET', 'POST'])
def message():
    # THESE FIELDS ARE REQUIRED BY DEFAULT
    username = request.args.get('username')
    location = request.args.get('location')

    # (lat, long)
    # {"latitude": __, "longitude": __}

    # USED FOR RETRIEVING MESSAGES
    if request.method == 'GET':
        distance = request.args.get('distance')
        (lat, long) = location
        location_ = {"latitude": lat, "longitude": long}

        return neo4j.get_messages(location_, distance)

    # USED TO POST MESSAGES
    else:
        location = request.json['location']
        msg = request.json['message']
        expire_time = request.json['expireTime']
        return str(neo4j.post_message(username, location, msg, expire_time))


@app.route('/rating', methods=['POST', 'GET'])
def rating():
    # GET POST ID
    post_id = request.args.get('postId')

    # FOR LIKING OR DISLIKING A POST
    if request.method == 'POST':
        # GET RATING
        rating = request.args.get('rating')
        username = request.args.get('username')

        # PARSE RATING (true is a like, false is a dislike)
        if rating:
            relation = "LIKED"
        else:
            relation = "DISLIKED"

        return str(neo4j.rate_post(post_id, relation, username))

    # USED TO RETRIEVE THE LIKES/DISLIKES ON A POST
    if request.method == 'GET':
        return neo4j.get_ratings


@app.route('/replies', methods=['GET', 'POST'])
def replies():
    # REQUIRED BY DEFAULT
    post_id = request.args.get('postId')

    # USED FOR REPLYING TO A POST
    if request.method == 'POST':
        username = request.json['username']
        reply_text = request.json['replyText']
        return str(neo4j.reply_to_post(reply_text, post_id, username))

    # USED FOR RETRIEVING A POST'S REPLIES
    else:
        return neo4j.get_post_replies(post_id)


@app.route('/deactivate', methods=['POST'])
def deactivate():
    # retrieve user info
    username = request.args.get('username')
    password = request.args.get('password')
    password_hash = authenticate.generate_hash(password)

    if request.method == 'POST':
        return str(neo4j.delete_user(username, password_hash))


@app.route('/deletemessage', methods=['POST'])
def replies():
    # REQUIRED BY DEFAULT
    post_id = request.json['postId']

    # USED FOR DELETING A POST
    if request.method == 'POST':
        return neo4j.delete_post(post_id)


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
