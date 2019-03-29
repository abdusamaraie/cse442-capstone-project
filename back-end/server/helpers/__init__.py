from helpers.neo4j import GRAPH

# setup uniqueness constraints and indexes on database
GRAPH.schema.create_uniqueness_constraint("User", "username")
GRAPH.schema.create_uniqueness_constraint("User", "email")
GRAPH.schema.create_uniqueness_constraint("Reply", "reply_id")
GRAPH.schema.create_uniqueness_constraint("Post", "post_id")
GRAPH.schema.create_uniqueness_constraint("Place", "place_id")
GRAPH.schema.create_index("Post", "expire_time")

# create spatial layer on first database run
try:  # will crash if layer already exists
    GRAPH.run("CALL spatial.addPointLayer('posts')")
except Exception as e:
    if "Cannot create existing layer" in str(e):
        print(" * Posts spatial layer already exists. Good")
    else:
        raise e
