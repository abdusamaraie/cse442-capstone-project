from py2neo import Graph, Node, Relationship, NodeMatcher, RelationshipMatcher
from datetime import datetime
from pytz import timezone
import uuid
from objects.user import User
from helpers.radius_math import get_user_radius_bounds
import json

GRAPH = Graph("bolt://localhost:7687", auth=("neo4j", " "))  # assumes neo4j is running locally on port 7474 (default)

'''
# connect to database
def get_db():
    graph = Graph()      return graph
'''


# add user to the database
def add_user(user):
    try:
        user_node = Node("User",
                         username=user.username,
                         hashed_password=user.password_hash,
                         first_name=user.firstname,
                         last_name=user.lastname)
        GRAPH.create(user_node)
        return True
    except Exception as e:
        print(e)
        return False


# get user data from database by username
def get_user(username):
    try:
        # find user node in database
        matcher = NodeMatcher(GRAPH)
        user_node = matcher.match("User", username=username).first()

        # if user is found, return user
        if user_node:
            return dict(user_node)
        else:
            return False

    except Exception as e:
        print(e)
        return False


# delete a user from the database (unregister)
def delete_user(username, password):
    try:
        # find user node in database
        matcher = NodeMatcher(GRAPH)
        user_node = matcher.match("User", username=username, hashed_password=password).first()

        # if user is found, delete user
        if user_node:
            GRAPH.delete(user_node)
            return True
        else:
            return False

    except Exception as e:
        print(e)
        return False


def add_photo(username, photo_url):
    try:
        # find user node in database
        matcher = NodeMatcher(GRAPH)
        user_node = matcher.match("User", username=username).first()

        # if user is found, delete user
        if user_node:
            GRAPH.run("MATCH (u:User {{username: '{}'}}) SET u.photo_url = '{}' RETURN u".format(username, photo_url))
            return True
        else:
            print("Couldn't find user")
            return False

    except Exception as e:
        print(e)
        return False


def get_photo(username):
    try:
        # find user node in database
        matcher = NodeMatcher(GRAPH)
        user_node = matcher.match("User", username=username).first()

        # if user is found, delete user
        if user_node:
            result = GRAPH.run("MATCH (u:User {{username: '{}'}}) RETURN u.photo_url".format(username))
            url = result.data()[0]['u.photo_url']

            return url
        else:
            print("Couldn't find user")
            return False

    except Exception as e:
        print(e)
        return False


def post_message(username, location, message, exp_time):
    # get lat and long
    lat = location['latitude']
    lon = location['longitude']

    # get current time for time of post
    es = timezone("US/Eastern")
    time = str(datetime.now().astimezone(es))

    # generate post id
    pid = str(uuid.uuid4())

    try:
        # create post node
        post_node = Node("Post",
                         content=message,
                         post_time=time,
                         expire_time=exp_time,
                         latitude=lat,
                         longitude=lon,
                         post_id=pid)
        GRAPH.create(post_node)

        # get corresponding user node
        matcher = NodeMatcher(GRAPH)
        user_node = matcher.match("User", username=username).first()

        # create relationship between user and post
        GRAPH.create(Relationship(user_node, "POSTED", post_node))

        # add node to spatial layer for indexing
        GRAPH.run("MATCH (p:Post {{post_id: '{}'}}) WITH p CALL spatial.addNode('posts', p) YIELD node RETURN node".format(pid))

        return dict(post_node)['post_id']

    except Exception as e:
        print(e)
        return False



def get_messages(location, distance):
    # setup database connection
    # do database query
    return None


def rate_message(post_id, table):
    # setup database connection
    # do database query
    return None


def reply_to_post(reply_text, post_id, username):
    # setup database connection
    # do database query
    return None


def get_post_replies(post_id):
    # setup database connection
    # do database query
    return None


def delete_message(post_id):
    # setup database connection
    # do database query
    return None


def get_user_message_history(username):
    # setup database connection
    # do database query
    return None
