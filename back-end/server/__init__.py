from server import app
from helpers.neo4j import GRAPH

# setup uniqueness constraints on database
GRAPH.schema.create_uniqueness_constraint("User", "username")
GRAPH.schema.create_uniqueness_constraint("User", "email")
GRAPH.schema.create_uniqueness_constraint("Reply", "reply_id")
GRAPH.schema.create_uniqueness_constraint("Post", "post_id")

GRAPH.run("CALL spatial.addPointLayer('posts')")
