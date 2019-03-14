import hashlib
import base64
import uuid
from constants.constants import HASH_PASSWORD_PATH
from py2neo import NodeMatcher
from helpers.neo4j import GRAPH


def generate_hash(username, password):
    tf_out = open(HASH_PASSWORD_PATH, 'wb')

    # find user node in database
    matcher = NodeMatcher(GRAPH)
    user_node = matcher.match("User", username=username).first()

    # if the user already exists, we get their salt from the db
    if user_node is None:
        salt = base64.urlsafe_b64encode(uuid.uuid4().bytes)
    else:
        salt = user_node['salt']

    t_sha = hashlib.sha512()
    t_sha.update(password.encode('utf-8') + salt)

    hashed_password = base64.urlsafe_b64encode(t_sha.digest())
    tf_out.write(hashed_password)
    tf_out.close()

    return {'salt': salt, 'hash': hashed_password}


def verify_user(username, password_hash):
    try:
        # find user node in database
        matcher = NodeMatcher(GRAPH)
        user_node = matcher.match("User", username=username, hashed_password=password_hash).first()

        # if user is found, return user
        if user_node is not None:
            return True
        else:
            return False

    except Exception as e:
        print(e)
        return False
