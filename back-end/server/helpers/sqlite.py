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

def post_message(user, location, message):

    print('Add message to message table')

    # return None if error


def get_messages(location, distance):
    con = get_db()
    con.row_factory = sqlite3.Row
    cur = con.cursor()

    bounds = get_user_radius_bounds(location, distance)
    N_lat = bounds.lat_N
    S_lat = bounds.lat_S
    E_long = bounds.long_E
    W_long = bounds.long_W

    try:
        query = cur.execute("SELECT * FROM Post WHERE latitude < {} AND latitude > {} AND longitude < {} AND longitude > {}".format(N_lat, S_lat, E_long, W_long))  # square radius
        # return messages in json
        results = query.fetchall()
        results_json = json.dumps([dict(ix) for ix in results])
        return results_json
    except Exception as e:
        return None  # return None on error
    finally:
        cur.close()
        con.close()

    # print('Get messages within users defined distance')
