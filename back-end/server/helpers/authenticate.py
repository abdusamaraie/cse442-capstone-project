from passlib.hash import argon2
from py2neo import NodeMatcher
from helpers.neo4j import GRAPH


def generate_hash(username, password):

    # find user node in database
    matcher = NodeMatcher(GRAPH)
    user_node = matcher.match("User", username=username).first()

    # if the user already exists, we get their salt from the db
    if user_node is None:
        hashed = argon2.encrypt(password)
    else:
        hashed = user_node['hashed_password']

    return hashed


def verify_user(username, password):
    try:
        # find user node in database
        matcher = NodeMatcher(GRAPH)
        user_node = matcher.match("User", username=username).first()

        # print(user_node['hashed_password'])

        # if user is found, return user
        if user_node is not None:
            password_hash = user_node['hashed_password']
            return argon2.verify(password, password_hash)
        else:
            print("Couldn't find user")
            return False

    except Exception as e:
        print(e)
        return False
