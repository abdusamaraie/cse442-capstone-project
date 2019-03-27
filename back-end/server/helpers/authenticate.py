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


def verify_user(password, password_hash):
    return argon2.verify(password, password_hash)
