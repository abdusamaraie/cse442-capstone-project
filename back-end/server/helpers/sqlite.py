from objects.user import User
from helpers.radius_math import get_user_radius_bounds

from constants.constants import DATABASE_PATH
import sqlite3 as sql
import json


# connect to database
def get_db():
    con = sql.connect(DATABASE_PATH)
    return con


def add_user(user):
    #setup database connection
    con = get_db()
    cur = con.cursor()
    #do database query
    try:
        cur.execute("INSERT INTO Users (username,hashed_password) VALUES (?,?)", (user.username, user.password_hash))
        con.commit()
        return True

    except Exception as e:
        return None  # return None if error
    finally:
        cur.close()
        con.close() #close connection

#get user data from database by username
def get_user(username):
    # setup database connection
    con = get_db()
    cur = con.cursor()
    user = User(username)

    # do database query
    try:
        curs = cur.execute("SELECT * from Users WHERE username = ? ", (username,))
        user_info = curs.fetchall()
        if (len(user_info) > 0):
            user.setUser(user_info[0][1],user_info[0][2],user_info[0][3])
            #return user object
            return user
        else:
            return False

    except Exception as e:
        return False  # return None if error
    finally:
        cur.close()
        con.close() #close connection



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
    con.row_factory = sql.Row
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
