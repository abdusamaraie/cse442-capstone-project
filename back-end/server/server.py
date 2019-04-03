# Local Helpers
from constants.constants import UPLOAD_PATH
from helpers import authenticate, neo4j, places
from objects.user import User
from objects.filestream import Filestream
# Flask
from flask import Flask, request, json

# Core Libraries
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

    if request.method == 'GET':
        username = request.args.get('username')
        return str(neo4j.get_photo(username))

    else:
        username = request.json['username']
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


@app.route('/auth', methods=['GET', 'POST'])
def auth():

    # USED FOR SIGN IN
    if request.method == 'GET':
        username = request.args.get('username')
        password = request.args.get('password')

        # check if username and password exist
        return str(authenticate.verify_user(username, password))

    # USED FOR SIGN UP
    else:  # POST
        # get information from client
        username = request.json['username']
        password = request.json['password']
        first_name = request.json['firstname']
        last_name = request.json['lastname']
        email = request.json['email']

        # generate new hash
        password_hash = authenticate.generate_hash(username, password)

        user = User(username, first_name, last_name, email, password_hash)

        return str(neo4j.add_user(user))


@app.route('/message', methods=['GET', 'POST', 'DELETE'])
def message():
    # USED FOR RETRIEVING MESSAGES
    if request.method == 'GET':

        lat = float(request.args.get('lat'))
        lon = float(request.args.get('long'))
        distance = int(request.args.get('distance'))
        location_json = {"latitude": lat, "longitude": lon}
        return neo4j.get_posts(location_json, distance)

    # USED TO POST MESSAGES
    elif request.method == 'POST':
        username = request.json['username']
        location = request.json['location']
        msg = request.json['message']
        expire_time = request.json['expireTime']
        place_id = request.json['placeId']
        return str(neo4j.post_message(username, location, msg, expire_time, place_id))

    # USED TO DELETE MESSAGES
    else:
        post_id = request.json['postId']
        return str(neo4j.delete_post(post_id))


@app.route('/rating', methods=['POST', 'GET'])
def rating():
    # USED TO RETRIEVE THE LIKES/DISLIKES ON A POST
    if request.method == 'GET':
        post_id = request.args.get('postId')

        return neo4j.get_ratings(post_id)

    # USED FOR LIKING OR DISLIKING A POST
    else:
        post_id = request.json['postId']
        p_rating = request.json['rating']
        username = request.json['username']

        # PARSE RATING (true is a like, false is a dislike)
        if p_rating:
            relation = "LIKED"
        else:
            relation = "DISLIKED"

        return str(neo4j.rate_post(post_id, relation, username))


@app.route('/replies', methods=['GET', 'POST', 'DELETE'])
def replies():
    # USED FOR RETRIEVING A POST'S REPLIES
    if request.method == 'GET':
        post_id = request.args.get('postId')
        return neo4j.get_post_replies(post_id)

    # USED FOR REPLYING TO A POST
    elif request.method == 'POST':
        post_id = request.json['postId']
        username = request.json['username']
        reply_text = request.json['replyText']
        return str(neo4j.reply_to_post(reply_text, post_id, username))

    # USED FOR DELETING A REPLY
    else:
        reply_id = request.json['replyId']
        return str(neo4j.delete_reply(reply_id))


@app.route('/deactivate', methods=['DELETE'])
def deactivate():
    if request.method == 'DELETE':
        # retrieve user info
        username = request.json['username']
        password = request.json['password']

        # get hashed password
        password_hash = authenticate.generate_hash(username, password)

        return str(neo4j.delete_user(username, password_hash))


@app.route('/password', methods=['PATCH'])
def change_password():
    if request.method == 'PATCH':
        # retrieve user info
        username = request.json['username']
        old_password = request.json['oldPassword']
        new_password = request.json['newPassword']
        verify_new_password = request.json['verifyNewPassword']

        if authenticate.verify_user(username, old_password) and new_password == verify_new_password:
            return str(neo4j.change_user_password(username, new_password))
        else:
            return str(False)


@app.route('/place', methods=['GET'])
def place():
    if request.method == 'GET':
        lat = request.args.get('lat')
        long = request.args.get('long')
        return neo4j.get_wide_place_nodes(lat, long)
    else:
        return str(False)


@app.route('/place/message', methods=['GET'])
def place():
    if request.method == 'GET':
        place_id = request.args.get('placeId')
        return neo4j.get_posts_at_place(place_id)
    else:
        return str(False)


'''
THIS IS DONE ON THE FRONT END NOW
@app.route('/nearby', methods=['GET'])
def nearby():
    # USED FOR RETRIEVING NEARBY PLACE SUGGESTIONS WHEN MAKING A POST
    if request.method == 'GET':
        lat = float(request.args.get('lat'))
        lon = float(request.args.get('long'))

        return places.get_nearby_places(lat, lon)
'''


def start_server():
    # app.run(host='0.0.0.0', port=80, debug=True)
    app.run(host='127.0.0.1', port=5000, debug=True)


def signal_handler(sig, frame):
    sys.exit(0)


def sigint():
    signal.signal(signal.SIGINT, signal_handler)
    print('Press Ctrl+C')
    signal.pause()


if __name__ == '__main__':
    start_server()
    sigint_handler = multiprocessing.Process(target=sigint)
