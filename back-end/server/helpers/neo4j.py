from py2neo import Graph, Node, Relationship, NodeMatcher, RelationshipMatcher
from constants.constants import NEO4J_CLUSTER_IP, OTHER_PHOTO_URL
from passlib.hash import argon2
from datetime import datetime
import pytz
from pytz import timezone
import uuid
import json
from helpers import places

GRAPH = Graph(host=NEO4J_CLUSTER_IP, auth=("neo4j", "password"))


def get_time(time_zone="US/Eastern"):
    # get timezone object (passed in from client)
    timezone_of_post = timezone(time_zone)

    # get the current system time
    now = datetime.now()

    # check if system time is naive. GCP server time is naive utc
    if now.tzinfo is None:  # is naive
        now = pytz.utc.localize(now)

    # convert to poster's local time
    time = now.astimezone(timezone_of_post)
    return str(time)


def get_place_node(place_id):
    # if place id is blank, assign 'Other'
    if place_id == '':
        place_id = 'Other'

    # find place node in database
    matcher = NodeMatcher(GRAPH)
    place_node = matcher.match("Place", place_id=place_id).first()

    # if a place node with the given place ID doesnt exist, we create one
    if place_node is None:
        info = places.get_place_info(place_id)

        place_node = Node("Place",
                          name=info['name'],
                          place_id=place_id,
                          photo_url=info['photo_url'],
                          latitude=info['geometry']['location']['lat'],
                          longitude=info['geometry']['location']['lng'],
                          types=info['types'])
        GRAPH.create(place_node)

        # add place node to spatial layer for indexing
        GRAPH.run("MATCH (pl:Place {{place_id: '{}'}}) "
                  "WITH pl "
                  "CALL spatial.addNode('places', pl) "
                  "YIELD node RETURN node".format(place_id))

    return place_node


# add user to the database
def add_user(user):
    try:
        user_node = Node("User",
                         username=user.username,
                         hashed_password=user.password_hash,
                         first_name=user.firstname,
                         last_name=user.lastname,
                         email=user.email)
        GRAPH.create(user_node)
        return str(True)
    except Exception as e:
        print(e)
        return str(False)


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
            return str(False)

    except Exception as e:
        print(e)
        return str(False)


# delete a user from the database (unregister)
def delete_user(username, password):
    try:
        # find user node in database
        matcher = NodeMatcher(GRAPH)
        user_node = matcher.match("User", username=username, hashed_password=password).first()

        # if user is found, delete user
        if user_node is not None:
            # delete user, their posts, all replies to their posts, and all of their replies
            GRAPH.run("MATCH (u:User {{username: '{}'}}) "
                      "OPTIONAL MATCH (u)-[:POSTED]->(p:Post) "
                      "OPTIONAL MATCH (p)<-[:REPLY_TO]-(r:Reply) "
                      "OPTIONAL MATCH (u)-[:REPLIED]->(ur:Reply) "
                      "DETACH DELETE u, p, r, ur".format(username))
            return str(True)
        else:
            print("Couldn't find user")
            return str(False)

    except Exception as e:
        print(e)
        return str(False)


def add_photo(username, photo_url):
    try:
        # find user node in database
        matcher = NodeMatcher(GRAPH)
        user_node = matcher.match("User", username=username).first()

        # if user is found, delete user
        if user_node is not None:
            GRAPH.run("MATCH (u:User {{username: '{}'}}) "
                      "SET u.photo_url = '{}' "
                      "RETURN u".format(username, photo_url))
            return str(True)
        else:
            print("Couldn't find user")
            return str(False)

    except Exception as e:
        print(e)
        return str(False)


def get_photo(username):
    try:
        # find user node in database
        matcher = NodeMatcher(GRAPH)
        user_node = matcher.match("User", username=username).first()

        # if user is found, delete user
        if user_node is not None:
            result = GRAPH.run("MATCH (u:User {{username: '{}'}}) "
                               "RETURN u.photo_url as photo_url".format(username))
            url = result.data()[0]['photo_url']

            return url
        else:
            print("Couldn't find user")
            return str(False)

    except Exception as e:
        print(e)
        return str(False)


def post_message(username, location, message, exp_time, place_id):
    # get lat and long
    lat = location['latitude']
    lon = location['longitude']

    # get current time for time of post
    time = get_time()

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
        # get corresponding place node, create if doesn't exist yet
        place_node = get_place_node(place_id)

        # create relationship between user and post
        GRAPH.create(Relationship(user_node, "POSTED", post_node))
        # create relationship between post and place
        GRAPH.create(Relationship(post_node, "LOCATED_AT", place_node))

        # add post node to spatial layer for indexing
        GRAPH.run("MATCH (p:Post {{post_id: '{}'}}) "
                  "WITH p "
                  "CALL spatial.addNode('posts', p) "
                  "YIELD node RETURN node".format(pid))
        return pid

    except Exception as e:
        print(e)
        return str(False)


def get_posts(location, distance):
    # get lat and long
    lat = location['latitude']
    lon = location['longitude']

    # convert distance im meters to km
    radius_km = distance * 0.001

    # get current time for time of post
    time = get_time()

    try:
        # run spatial query

        res = GRAPH.run("CALL spatial.withinDistance('posts', {{latitude: {},longitude: {}}}, {}) "
                        "YIELD node AS p "
                        "WITH p "
                        "WHERE p.expire_time > '{}' "
                        "MATCH(u:User)-[:POSTED]->(p)-[:LOCATED_AT]->(pl:Place) "
                        "WITH pl, u,"
                        "collect(p{{.*, username: u.username, likes: size((p)<-[:LIKED]-()), dislikes: size((p)<-[:DISLIKED]-())}}) as posts "
                        "RETURN pl as place, posts".format(lat, lon, radius_km, time))

        # loop through results and create json
        posts_json = json.dumps([dict(ix) for ix in res.data()])
        return posts_json

    except Exception as e:
        print(e)
        return str(False)


def rate_post(post_id, relation, username):
    try:
        # get user node
        matcher = NodeMatcher(GRAPH)
        user_node = matcher.match("User", username=username).first()

        # get post node
        post_node = matcher.match("Post", post_id=post_id).first()

        if user_node is not None and post_node is not None:
            # get relationship matcher
            rel_matcher = RelationshipMatcher(GRAPH)

            # check if the user has already liked/disliked the post
            already_liked = rel_matcher.match([user_node, post_node], 'LIKED').first()
            already_disliked = rel_matcher.match([user_node, post_node], 'DISLIKED').first()

            # if the user is trying to rate a post the same way twice, their rating is removed
            if already_liked is not None and relation == "LIKED":
                GRAPH.separate(already_liked)
                return str(True)
            elif already_disliked is not None and relation == "DISLIKED":
                GRAPH.separate(already_disliked)
                return str(True)
            # if the user is switching their rating, we delete to old one, and create a new one
            elif already_liked is not None and relation == "DISLIKED":
                GRAPH.separate(already_liked)
            elif already_disliked is not None and relation == "LIKED":
                GRAPH.separate(already_disliked)

            # create relationship between user and post
            GRAPH.merge(Relationship(user_node, relation, post_node), relation, '')
            return str(True)

        else:
            print("Either the user or the post couldn't be found")
            return str(False)

    except Exception as e:
        print(e)
        return str(False)


def reply_to_post(reply_text, post_id, username):
    # get current time for time of post
    time = get_time()

    # generate reply id
    rid = str(uuid.uuid4())

    try:
        # get original post node
        matcher = NodeMatcher(GRAPH)
        post_node = matcher.match("Post", post_id=post_id).first()

        if post_node is not None:
            # create reply node
            reply_node = Node("Reply",
                              content=reply_text,
                              post_time=time,
                              reply_id=rid)
            GRAPH.create(reply_node)

            # get node of user making reply
            matcher = NodeMatcher(GRAPH)
            user_node = matcher.match("User", username=username).first()

            # create relationship between user and reply
            GRAPH.create(Relationship(user_node, "REPLIED", reply_node))
            # create relationship between reply and original post
            GRAPH.create(Relationship(reply_node, "REPLY_TO", post_node))

            return rid
        else:
            print('Could not find post to reply to')
            return str(False)

    except Exception as e:
        print(e)
        return str(False)


def get_post_replies(post_id):
    try:
        # get replies under a post
        results = GRAPH.run("MATCH(p:Post {{post_id: '{}'}})<-[:REPLY_TO]-(r:Reply) "
                            "RETURN r".format(post_id))

        # loop through results and create json
        replies_json = json.dumps([dict(ix)['r'] for ix in results.data()])
        return replies_json

    except Exception as e:
        print(e)
        return str(False)


def delete_post(post_id):
    try:
        # delete post node and all replies
        GRAPH.run("MATCH (p:Post {{post_id: '{}'}}) "
                  "OPTIONAL MATCH (p)<-[:REPLY_TO]-(r:Reply) "
                  "DETACH DELETE r, p".format(post_id))
        return str(True)
    except Exception as e:
        print(e)
        return str(False)


def get_user_post_history(username):
    try:
        # delete post node and all replies
        results = GRAPH.run("MATCH (u:User {{username: '{}'}})-[:POSTED]->(p:Post) "
                            "RETURN p".format(username))

        # loop through results and create json
        post_history_json = json.dumps([dict(ix)['p'] for ix in results.data()])
        return post_history_json

    except Exception as e:
        print(e)
        return str(False)


def get_ratings(post_id):
    try:
        # get likes and dislikes from post
        result = GRAPH.run("MATCH (p:Post {{post_id: '{}'}}) "
                           "RETURN size((p)<-[:LIKED]-()) as likes, "
                           "size((p)<-[:DISLIKED]-()) as dislikes".format(post_id))
        return json.dumps(result.data()[0])
    except Exception as e:
        print(e)
        return str(False)


def delete_reply(reply_id):
    try:
        # delete post node and all replies
        GRAPH.run("MATCH (r:Reply {{reply_id: '{}'}}) "
                  "DETACH DELETE r".format(reply_id))
        return str(True)
    except Exception as e:
        print(e)
        return str(False)


def change_user_password(username, new_password):
    # hash the password before storage
    hashed_pass = argon2.encrypt(new_password)

    try:
        # get node of user changing their password
        matcher = NodeMatcher(GRAPH)
        user_node = matcher.match("User", username=username).first()

        # update user's hashed password in database
        user_node['hashed_password'] = hashed_pass

        # push updated node to graph
        GRAPH.push(user_node)
        return str(True)

    except Exception as e:
        print(e)
        return str(False)


def get_wide_place_nodes(lat, lon, radius):

    # convert distance im meters to km
    radius_km = radius/1000

    # get current time for time of post
    time = get_time()

    try:
        # run spatial query

        res = GRAPH.run("CALL spatial.withinDistance('places', {{latitude: {},longitude: {}}}, {}) "
                        "YIELD node AS places "
                        "MATCH (p:Post)-[:LOCATED_AT]->(places) WHERE p.expire_time > '{}' "
                        "RETURN places{{.*, number_of_posts: count(p)}} LIMIT 10".format(lat, lon, radius_km, time))

        # loop through results and create json
        places_json = json.dumps([dict(ix)['places'] for ix in res.data()])
        return places_json

    except Exception as e:
        print(e)
        return str(False)


def get_posts_at_place(place_id):
    time = get_time()

    try:
        result = GRAPH.run("MATCH (u:User)-[:POSTED]->(p:Post)-[:LOCATED_AT]->(pl:Place {{place_id: '{}'}})"
                           "WHERE p.expire_time > '{}' "
                           "WITH u, p "
                           "RETURN p{{.*, username: u.username, likes: size((p)<-[:LIKED]-()), dislikes: size((p)<-[:DISLIKED]-())}}".format(place_id, time))

        # loop through results and create json
        posts_json = json.dumps([dict(ix)['p'] for ix in result.data()])
        return posts_json

    except Exception as e:
        print(e)
        return str(False)


def wipe_database():

    try:
        # Wipe database of all nodes and relationships
        GRAPH.run("MATCH (n) DETACH DELETE n")

        # Recreate spatial layers
        GRAPH.run("CALL spatial.addPointLayer('posts')")
        GRAPH.run("CALL spatial.addPointLayer('places')")

        # create 'Other' Place node if doesn't exist
        GRAPH.merge(Node("Place", place_id='Other', name='Other', photo_url=OTHER_PHOTO_URL), 'Place', 'place_id')

        return str(True)

    except Exception as e:
        print(e)
        return str(False)
