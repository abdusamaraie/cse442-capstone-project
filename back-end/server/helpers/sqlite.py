from objects.user import User
from constants.constants import DATABASE_PATH
from helpers.radius_math import get_user_radius_bounds
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


def get_messages(location, distance):
    con = get_db()
    con.row_factory = sqlite3.Row
    cur = con.cursor()

    # get bounds for message query
    bounds = get_user_radius_bounds(location, distance)
    n_lat = bounds.lat_N
    s_lat = bounds.lat_S
    e_long = bounds.long_E
    w_long = bounds.long_W
    # print("N {}, S {}, E {}, W {}".format(n_lat, s_lat, e_long, w_long))

    try:
        # execute query
        query = cur.execute("SELECT * FROM Post WHERE (latitude BETWEEN {} AND {}) AND (longitude BETWEEN {} AND {})".format(s_lat, n_lat, w_long, e_long))  # square radius
        results = query.fetchall()

        # return messages in json
        results_json = json.dumps([dict(ix) for ix in results])
        return results_json
    except Exception as e:
        print(e)
        return None  # return None on error
    finally:
        cur.close()
        con.close()
