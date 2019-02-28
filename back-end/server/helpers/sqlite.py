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


def post_message(username, location, message, time):
    # connect to DB
    con = get_db()
    cur = con.cursor()

    # get lat and long
    lat = location['latitude']
    long = location['longitude']

    try:
        # add post to post table
        cur.execute("INSERT INTO post (uname, content, time, latitude, longitude) VALUES ('{}', '{}', '{}', {}, {})".format(username, message, time, lat, long))
        con.commit()
        print('committed')
        return True
    except Exception as e:
        print(e)
        return None  # return None if error
    finally:
        cur.close()
        con.close()
