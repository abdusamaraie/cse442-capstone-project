from objects.user import User
from constants.constants import DATABASE_PATH
import sqlite3
import json

# connect to database
def get_db():
    db_con = sqlite3.connect(DATABASE_PATH)
    return db_con


def add_user(user):
    print('Add user to sqlite')

    # return None if error

def post_message(user, location, message):

    print('Add message to message table')

    # return None if error


def get_messages(location, distance):
    con = get_db()
    cur = con.cursor()

    try:
        query = cur.execute("SELECT * FROM Post")  # currently grabbing all messages
        # return messages in json
        rv = query.fetchall()
        ret_json = json.dumps(rv)
        return ret_json
    except Exception as e:
        return None  # return None on error
    finally:
        cur.close()
        con.close()

    # print('Get messages within users defined distance')
