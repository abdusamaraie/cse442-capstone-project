from helpers.neo4j import GRAPH

# setup uniqueness constraints on database
GRAPH.schema.create_uniqueness_constraint("User", "username")
GRAPH.schema.create_uniqueness_constraint("User", "email")
GRAPH.schema.create_uniqueness_constraint("Reply", "reply_id")
GRAPH.schema.create_uniqueness_constraint("Post", "post_id")

# create spatial layer on first database run
try:  # will crash if layer already exists
    GRAPH.run("CALL spatial.addPointLayer('posts')")
except Exception as e:
    print("'posts' spatial layer already exists. Thank god")
