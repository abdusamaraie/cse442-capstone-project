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
                         hashed_password=str(user.password_hash),
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
        if user_node is not None:
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
        if user_node is not None:
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
        if user_node is not None:
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
        if user_node is not None:
            result = GRAPH.run("MATCH (u:User {{username: '{}'}}) RETURN u.photo_url as photo_url".format(username))
            url = result.data()[0]['photo_url']

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


def get_posts(location, distance):
    # get lat and long
    lat = location['latitude']
    lon = location['longitude']

    # convert distance im meters to km
    radius = distance * 0.001

    # get current time to check if posts are expired
    es = timezone("US/Eastern")
    time = str(datetime.now().astimezone(es))

    try:
        # run spatial query
        results = GRAPH.run("CALL spatial.withinDistance('posts', {{latitude: {},longitude: {}}}, {}) YIELD node AS p WITH p WHERE p.expire_time > '{}' RETURN p".format(lat, lon, radius, time))

        # loop through results and create json
        messages_json = json.dumps([dict(ix) for ix in results.data()])
        return messages_json

    except Exception as e:
        print(e)
        return False


def rate_post(post_id, relation, username):
    try:
        # get user node
        matcher = NodeMatcher(GRAPH)
        user_node = matcher.match("User", username=username).first()

        # get post node
        post_node = matcher.match("Post", post_id=post_id).first()

        print(post_node)
        print(user_node)

        if user_node is not None and post_node is not None:
            # get relationship matcher
            rel_matcher = RelationshipMatcher(GRAPH)

            # check if the user has already liked/disliked the post
            already_liked = rel_matcher.match([user_node, post_node], 'LIKED').first()
            already_disliked = rel_matcher.match([user_node, post_node], 'DISLIKED').first()

            # if the user is trying to rate a post the same way twice, their rating is removed
            if already_liked is not None and relation == "LIKED":
                GRAPH.delete(already_liked)
                return True
            elif already_disliked is not None and relation == "DISLIKED":
                GRAPH.delete(already_disliked)
                return True
            # if the user is switching their rating, we delete to old one, and create a new one
            elif already_liked is not None and relation == "DISLIKED":
                GRAPH.delete(already_liked)
            elif already_disliked is not None and relation == "LIKED":
                GRAPH.delete(already_disliked)

            # create relationship between user and post
            GRAPH.merge(Relationship(user_node, relation, post_node), relation, '')
            return True

        else:
            print("Either the user or the post couldn't be found")
            return False

    except Exception as e:
        print(e)
        return False


def reply_to_post(reply_text, post_id, username):
    # setup database connection
    # do database query
    return None


def get_post_replies(post_id):
    # setup database connection
    # do database query
    return None


def delete_post(post_id):
    try:
        # delete post node
        GRAPH.run("MATCH (p:Post {{post_id: '{}'}}) DETACH DELETE p".format(post_id))
        return True
    except Exception as e:
        print(e)
        return False


def get_user_post_history(username):
    # setup database connection
    # do database query
    return None


def get_ratings(post_id):
    try:
        # delete post node
        result = GRAPH.run("MATCH(p:Post {{post_id: '{}'}})<-[likes:LIKED]-() MATCH(p)<-[dislikes:DISLIKED]-() RETURN count(likes) as likes, count(dislikes) as dislikes".format(post_id))
        ratings = json.dumps(dict(result.data()))
        return ratings
    except Exception as e:
        print(e)
        return False
