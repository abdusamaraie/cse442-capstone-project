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

    username = request.args.get('username')

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

        return str(sqlite.add_user(user))


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
        (lat,long) = location
        location_ = {"latitude": lat, "longitude": long}

        return sqlite.get_messages(location_, distance)

    # USED TO POST MESSAGES
    else:
        msg = request.json['message']
        expire_time = request.json['expireTime']

        return str(sqlite.post_message(username, location, msg, expire_time))


@app.route('/rate', methods=['POST'])
def rate():
    # GET RATING
    rating = request.args.get('rating')

    # PARSE RATING (true is a like, false is a dislike)
    if rating:
        table = "likes"
    else:
        table = "dislikes"

    # GET POST ID
    post_id = request.args.get('postId')

    return str(sqlite.rate_message(post_id, table))


@app.route('/replies', methods=['GET', 'POST'])
def replies():

    # REQUIRED BY DEFAULT
    post_id = request.args.get('postId')

    # USED FOR REPLYING TO A POST
    if request.method == 'POST':
        username = request.json['username']
        reply_text = request.json['replyText']
        return str(sqlite.reply_to_post(reply_text, post_id, username))

    # USED FOR RETRIEVING A POST'S REPLIES
    else:
        return sqlite.get_post_replies(post_id)

@app.route('/deactivate', methods=['POST'])
def deactivate():
    #retrive user info
    username = request.args.get('username')
    password = request.args.get('password')

    if request.method == 'POST':
        return str(sqlite.delete_user(username,password))

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
