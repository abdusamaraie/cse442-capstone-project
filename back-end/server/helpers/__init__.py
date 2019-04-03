from helpers.neo4j import GRAPH
from py2neo import Node
from constants.constants import OTHER_PHOTO_URL

# setup uniqueness constraints and indexes on database
GRAPH.schema.create_uniqueness_constraint("User", "username")
GRAPH.schema.create_uniqueness_constraint("User", "email")
GRAPH.schema.create_uniqueness_constraint("Reply", "reply_id")
GRAPH.schema.create_uniqueness_constraint("Post", "post_id")
GRAPH.schema.create_uniqueness_constraint("Place", "place_id")
GRAPH.schema.create_index("Post", "expire_time")

# create 'Other' Place node if doesn't exist
GRAPH.merge(Node("Place", place_id='Other', name='Other', photo_url=OTHER_PHOTO_URL), 'Place', 'place_id')

# create 'posts' spatial layer on first database run
try:  # will crash if layer already exists
    GRAPH.run("CALL spatial.addPointLayer('posts')")
except Exception as e:
    if "Cannot create existing layer" in str(e):
        print(" * Posts spatial layer already exists. Good")
    else:
        raise e

# create 'places' spatial layer on first database run
try:  # will crash if layer already exists
    GRAPH.run("CALL spatial.addPointLayer('places')")
except Exception as e:
    if "Cannot create existing layer" in str(e):
        print(" * Places spatial layer already exists. Also good")
    else:
        raise e
