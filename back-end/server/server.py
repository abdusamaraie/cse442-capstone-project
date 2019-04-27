# Local Helpers
from helpers import authenticate, neo4j
from objects.user import User

# Flask
from flask import Flask, request
from flask_socketio import SocketIO, emit, send
from flask_login import LoginManager, login_user, current_user, UserMixin

# Core Libraries
import multiprocessing
import signal
import sys

app = Flask(__name__)
app.config['SECRET_KEY'] = 'mykeyissecret'
socketio = SocketIO(app)
login = LoginManager(app)


class UserSession(UserMixin):
    def __init__(self, username):
        self.id = username


@login.user_loader
def user_loader(uid):
    return UserSession(uid)


@socketio.on('connect')
def on_connect():
    if current_user.is_anonymous:
        return False
    emit('welcome', {'username': current_user.id})


@app.route('/', methods=['GET'])
def hello_world():
    return 'Hello, Kubernetes!'


@app.route('/profile/image', methods=['POST', 'GET', 'DELETE'])
def upload():
    username = request.args.get('username')
    if request.method == 'GET':
        return neo4j.get_profile_image(username)

    # For uploading a new profile image
    elif request.method == 'POST':
        uploaded_file = request.files.get('file')

        if not uploaded_file:
            return str(False)

        return neo4j.update_profile_image(uploaded_file, username)

    # For deleting a profile image, returns to the default image
    else:
        return neo4j.delete_profile_image(username)


@app.route('/auth', methods=['GET', 'POST'])
def auth():

    # USED FOR SIGN IN
    if request.method == 'GET':
        username = request.args.get('username')
        password = request.args.get('password')
        if not authenticate.verify_user(username, password):
            return str(False)
        login_user(UserSession(username))
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
        dist = int(request.args.get('distance'))
        location_json = {"latitude": lat, "longitude": lon}
        return neo4j.get_posts(location_json, dist)

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
    # GET ALL THE PLACES WITH POSTS IN GIVEN RADIUS
    if request.method == 'GET':
        lat = request.args.get('lat')
        long = request.args.get('long')
        radius = request.args.get('radius', default=250, type=int)

        return neo4j.get_wide_place_nodes(lat, long, radius)
    else:
        return str(False)


@app.route('/place/message', methods=['GET'])
def place_message():
    # GET ALL THE MESSAGES LOCATED AT A PLACE
    if request.method == 'GET':
        place_id = request.args.get('placeId')
        return neo4j.get_posts_at_place(place_id)
    else:
        return str(False)


@app.route('/history/posts', methods=['GET'])
def post_history():
    username = request.args.get('username')
    return neo4j.get_user_post_history(username)


@app.route('/history/ratings', methods=['GET'])
def rating_history():
    username = request.args.get('username')
    return neo4j.get_user_rating_history(username)


@app.route('/history/replies', methods=['GET'])
def reply_history():
    username = request.args.get('username')
    return neo4j.get_user_reply_history(username)


'''
@app.route('/neo4j', methods=['DELETE'])
def wipe():
    return neo4j.wipe_database()
'''


@app.route('/didrate', methods=['GET'])
# Returns "LIKED", "DISLIKED", or "False"
def check():
    post_id = request.args.get('postId')
    username = request.args.get('username')
    return neo4j.check_if_user_rated_post(post_id, username)


'''
DEPRECATED
@app.route('/distance', methods=['GET'])
def distance():
    # RETURN THE DISTANCE BETWEEN A USER AND A PLACE
    if request.method == 'GET':
        place_id = request.args.get('placeId')
        lat = float(request.args.get('lat'))
        long = float(request.args.get('long'))
        return places.distance_from_place(place_id, lat, long)
    else:
        return str(False)


THIS IS DONE ON THE FRONT END NOW
@app.route('/nearby', methods=['GET'])
def nearby():
    # USED FOR RETRIEVING NEARBY PLACE SUGGESTIONS WHEN MAKING A POST
    if request.method == 'GET':
        lat = float(request.args.get('lat'))
        lon = float(request.args.get('long'))

        return places.get_nearby_places(lat, lon)
'''


# Handle auth
@socketio.on('my login')
def on_auth():
    if current_user.is_anonymous:
        return False
    socketio.emit('my response', {'username': current_user.id}, namespace='/auth')


# Handle message
@socketio.on('my message')
def on_message(data):
    if current_user.is_anonymous:
        return False
    print('received my event: ' + str(data))
    socketio.emit('my response', data, namespace='/message')


# Handle rating
@socketio.on('my rating')
def on_rating(data):
    socketio.emit('my response', data, callback=rating)
    pass


# Handle replies
@socketio.on('my replies')
def on_replies(data):
    socketio.emit('my response', data, callback=replies)
    pass


# Handle deactivate
@socketio.on('delete user')
def on_deactivate(data):
    socketio.emit('my response', data, callback=deactivate)
    pass


# Handle change password
@socketio.on('change password')
def on_change_password(data):
    socketio.emit('my response', data, callback=change_password)
    pass


# Handle place
@socketio.on('place')
def on_place(data):
    socketio.emit('my response', data, callback=place)
    pass


# Handle place
@socketio.on('place message')
def on_place_message(data):
    socketio.emit('my response', data, callback=place_message)
    pass


def start_server():
    # app.run(host='0.0.0.0', port=80, debug=True)
    socketio.run(app, host='127.0.0.1', port=5000, debug=True)
    # socketio.run(app, host='0.0.0.0', port=80, debug=True)


def signal_handler(sig, frame):
    sys.exit(0)


def sigint():
    signal.signal(signal.SIGINT, signal_handler)
    print('Press Ctrl+C')
    signal.pause()


if __name__ == '__main__':
    start_server()
    sigint_handler = multiprocessing.Process(target=sigint)
