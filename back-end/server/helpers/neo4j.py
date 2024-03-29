from py2neo import Graph, Node, Relationship, NodeMatcher, RelationshipMatcher
from constants.constants import NEO4J_CLUSTER_IP, OTHER_PHOTO_URL, DEFAULT_PROFILE_IMAGE
from passlib.hash import argon2
from datetime import datetime
import pytz
from pytz import timezone
import uuid
import json
from helpers import places
from helpers import cloud_storage

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
        time = get_time()

        # create user node
        user_node = Node("User",
                         username=user.username,
                         hashed_password=user.password_hash,
                         first_name=user.firstname,
                         last_name=user.lastname,
                         email=user.email,
                         profile_image=DEFAULT_PROFILE_IMAGE,
                         biography='',
                         birthday=user.birthday,
                         join_date=time,
                         hometown=user.hometown)
        GRAPH.create(user_node)

        # create settings node for the user
        settings_node = Node("Settings",
                             place_feed_radius=250,
                             map_feed_radius=50,
                             dark_mode=False)
        GRAPH.create(settings_node)

        # create relationship between user and post
        GRAPH.create(Relationship(user_node, "HAS_SETTINGS", settings_node))

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
                      "OPTIONAL MATCH (u)-[:HAS_SETTINGS]->(s:Settings) "
                      "DETACH DELETE u, p, r, ur, s".format(username))
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
                        "collect(p{{.*, username: u.username, profile_image: u.profile_image, "
                        "full_name: (u.first_name + ' ' + u.last_name),"
                        "likes: size((p)<-[:LIKED]-()), dislikes: size((p)<-[:DISLIKED]-())}}) as posts "
                        "RETURN pl as place, posts".format(lat, lon, radius_km, time))

        # loop through results and create json
        posts_json = json.dumps([dict(ix) for ix in res.data()])
        return posts_json

    except Exception as e:
        print(e)
        return str(False)


def rate_post(post_id, relation, username):

    # get current time for time of rating
    time = get_time()

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
            GRAPH.merge(Relationship(user_node, relation, post_node, rate_time=time), relation)
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
        results = GRAPH.run("MATCH(p:Post {{post_id: '{}'}})<-[:REPLY_TO]-(r:Reply)<-[:REPLIED]-(u:User) "
                            "RETURN r{{.*, username: u.username, profile_image: u.profile_image, "
                            "full_name: (u.first_name + ' ' + u.last_name)}} "
                            "ORDER BY r.post_time DESC".format(post_id))

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
        # delete a reply
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
                        "RETURN places{{.*, number_of_posts: count(p)}} "
                        "UNION MATCH (other:Place {{place_id: 'Other'}}) "
                        "CALL spatial.withinDistance('posts', {{latitude: {},longitude: {}}}, {}) "
                        "YIELD node AS p "
                        "MATCH (p)-[:LOCATED_AT]->(other) WHERE p.expire_time > '{}' " 
                        "RETURN other{{.*, number_of_posts: count(p)}} AS places".format(lat, lon, radius_km, time, lat, lon, radius_km, time,))

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
                           "ORDER BY p.post_time DESC "
                           "RETURN p{{.*, username: u.username, profile_image: u.profile_image, "
                           "full_name: (u.first_name + ' ' + u.last_name), likes: size((p)<-[:LIKED]-()), "
                           "dislikes: size((p)<-[:DISLIKED]-())}}".format(place_id, time))

        # loop through results and create json
        posts_json = json.dumps([dict(ix)['p'] for ix in result.data()])
        return posts_json

    except Exception as e:
        print(e)
        return str(False)


def get_posts_at_other(lat, lon, radius):
    time = get_time()

    # convert distance im meters to km
    radius_km = radius/1000

    try:
        result = GRAPH.run("CALL spatial.withinDistance('posts', {{latitude: {},longitude: {}}}, {}) "
                           "YIELD node AS p "
                           "MATCH(u:User)-[:POSTED]->(p)-[:LOCATED_AT]->(:Place {{place_id: 'Other'}}) "
                           "WHERE p.expire_time > '{}' "
                           "RETURN p{{.*, username: u.username, profile_image: u.profile_image, "
                           "full_name: (u.first_name + ' ' + u.last_name), likes: size((p)<-[:LIKED]-()), "
                           "dislikes: size((p)<-[:DISLIKED]-())}} as posts ORDER BY p.post_time DESC".format(lat, lon, radius_km, time))

        # loop through results and create json
        posts_json = json.dumps([dict(ix)['posts'] for ix in result.data()])
        return posts_json

    except Exception as e:
        print(e)
        return str(False)


def get_user_settings(username):
    try:
        result = GRAPH.run("MATCH (:User {{username: '{}'}})-[:HAS_SETTINGS]->(s) RETURN s{{.*}}".format(username))

        # print(result.data())
        settings = json.dumps([dict(ix)['s'] for ix in result.data()])

        return settings

    except Exception as e:
        print(e)
        return str(False)


def update_user_settings(username, settings):
    try:
        # get node of user updating their settings
        matcher = NodeMatcher(GRAPH)
        user_node = matcher.match("User", username=username).first()

        # get relationship matcher
        rel_matcher = RelationshipMatcher(GRAPH)

        # find user's settings node
        rel = rel_matcher.match([user_node, None], 'HAS_SETTINGS').first()
        settings_node = rel.end_node

        for setting in settings:
            settings_node[setting] = settings[setting]

        GRAPH.push(settings_node)
        return str(True)

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


def get_user_post_history(username):
    try:
        # delete post node and all replies
        results = GRAPH.run("MATCH (u:User {{username: '{}'}})-[:POSTED]->(p:Post) "
                            "RETURN p ORDER BY p.post_time DESC".format(username))

        # loop through results and create json
        post_history_json = json.dumps([dict(ix)['p'] for ix in results.data()])
        return post_history_json

    except Exception as e:
        print(e)
        return str(False)


def get_user_reply_history(username):
    try:
        # delete post node and all replies
        results = GRAPH.run("MATCH (u:User {{username: '{}'}})-[:REPLIED]->(r:Reply)-[:REPLY_TO]->(p:Post) "
                            "RETURN r{{.*, parent_post_id: p.post_id}} ORDER BY r.post_time DESC".format(username))

        # loop through results and create json
        post_history_json = json.dumps([dict(ix)['r'] for ix in results.data()])
        return post_history_json

    except Exception as e:
        print(e)
        return str(False)


def get_user_rating_history(username):
    try:
        # delete post node and all replies
        likes_result = GRAPH.run("MATCH (u:User {{username: '{}'}})-[l:LIKED]->(likes:Post) "
                                 "RETURN likes{{.*, rate_time: l.rate_time}} ORDER BY l.rate_time DESC".format(username))
        dislikes_result = GRAPH.run("MATCH (u:User {{username: '{}'}})-[d:DISLIKED]->(dislikes:Post) "
                                    "RETURN dislikes{{.*, rate_time: d.rate_time}} ORDER BY d.rate_time DESC".format(username))

        # loop through results and create json
        likes = json.dumps([dict(ix)['likes'] for ix in likes_result.data()])
        dislikes = json.dumps([dict(ix)['dislikes'] for ix in dislikes_result.data()])

        return json.dumps({"likes": likes, "dislikes": dislikes})

    except Exception as e:
        print(e)
        return str(False)


def check_if_user_rated_post(post_id, username):
    try:
        result = GRAPH.run("MATCH (:User {{username: '{}'}})-[r:LIKED|DISLIKED]->(:Post {{post_id: '{}'}}) RETURN type(r) as result".format(username, post_id)).data()

        if len(result) == 0:
            return str(False)
        else:
            return result[0]['result']

    except Exception as e:
        print(e)
        return str(False)


def update_profile_image(image_file, username):
    try:
        # upload file to google cloud storage and get the url
        photo_url = cloud_storage.upload_profile_image(image_file, username)

        # get node of user changing their profile pic
        matcher = NodeMatcher(GRAPH)
        user_node = matcher.match("User", username=username).first()

        # update user's hashed password in database
        user_node['profile_image'] = photo_url

        # push updated node to graph
        GRAPH.push(user_node)
        return str(True)

    except Exception as e:
        print(e)
        return str(False)


def get_profile_image(username):
    try:
        # get node of user changing their password
        matcher = NodeMatcher(GRAPH)
        user_node = matcher.match("User", username=username).first()

        if user_node is None:
            return str(False)

        return user_node['profile_image']

    except Exception as e:
        print(e)
        return str(False)


def delete_profile_image(username):
    try:
        # get node of user changing their password
        matcher = NodeMatcher(GRAPH)
        user_node = matcher.match("User", username=username).first()

        if user_node is None:
            return str(False)

        # if the user's photo is already the default, do nothing
        if user_node['profile_image'] == DEFAULT_PROFILE_IMAGE:
            return str(True)
        else:
            cloud_storage.delete_profile_image(user_node['profile_image'])
            user_node['profile_image'] = DEFAULT_PROFILE_IMAGE
            GRAPH.push(user_node)

        return str(True)

    except Exception as e:
        print(e)
        return str(False)


def get_profile_info(username):
    try:
        # get node of user who's profile we want to view
        matcher = NodeMatcher(GRAPH)
        user_node = matcher.match("User", username=username).first()

        # create dictionary from node properties
        profile_info = dict(user_node)

        # remove hashed_password and email from response
        del profile_info['hashed_password'], profile_info['email']

        return json.dumps(profile_info)

    except Exception as e:
        print(e)
        return str(False)
