from objects.user import User
from helpers.radius_math import get_user_radius_bounds
from datetime import datetime
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
        cur.execute("INSERT INTO Users (username,hashed_password) VALUES (?, ?)", (user.username, user.password_hash))
        con.commit()
        return True

    except Exception as e:
        print(e)
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
        curs = cur.execute("SELECT * from Users WHERE username = '{}'".format(username))
        user_info = curs.fetchall()
        if (len(user_info) > 0):
            user.setUser(user_info[0][1],user_info[0][2],user_info[0][3],user_info[0][4],user_info[0][5])
            #return user object
            return user
        else:
            return False

    except Exception as e:
        print(e)
        return None  # return None if error
    finally:
        cur.close()
        con.close() #close connection



def add_photo(username,photoURL):
    # setup database connection
    con = get_db()
    cur = con.cursor()
    user = User(username)

    # do database query
    try:
        cur.execute("UPDATE Users SET photo_url = '{}' WHERE username = '{}' ".format(photoURL,username))
        con.commit()
        return True
    except Exception as e:
        print(e)
        return None  # return None if error
    finally:
        cur.close()
        con.close()  # close connection

def get_photo(username):
    con = get_db()
    cur = con.cursor()

    # do database query
    try:
        curs = cur.execute("SELECT photo_url FROM Users WHERE username = '{}' ".format(username))
        photo = curs.fetchall()
        if (len(photo) > 0):
            # return json format
            return json.dumps({'filename': photo[0][0]})
        else:
            return False

    except Exception as e:
        print(e)
        return None  # return None if error
    finally:
        cur.close()
        con.close()  # close connection


def post_message(username, location, message, exp_time):
    # connect to DB
    con = get_db()
    con.row_factory = sql.Row
    cur = con.cursor()

    # get lat and long
    lat = location['latitude']
    long = location['longitude']

    # get current time for time of post
    time = datetime.now()

    try:
        # add post to post table
        cur.execute("INSERT INTO Posts(uname, content, post_time, expire_time, latitude, longitude) VALUES ('{}', '{}', '{}', '{}', {}, {})".format(username, message, time, exp_time, lat, long))
        con.commit()

        # retrieve the item we just inserted
        inserted_row_id = cur.lastrowid
        inserted_post = cur.execute("SELECT * FROM Posts WHERE ROWID = {}".format(inserted_row_id)).fetchone()

        # get and return post_id of inserted item
        post_id = dict(inserted_post)['post_id']
        return post_id
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

    # get current time to exclude posts that are passed their expiration dates
    time = datetime.now()
    
    try:
        # execute query
        query = cur.execute("SELECT * FROM Posts WHERE '{}' < expire_time AND (latitude BETWEEN {} AND {}) AND (longitude BETWEEN {} AND {})".format(time, s_lat, n_lat, w_long, e_long))  # square radius
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


def rate_message(post_id, table):
    # connect to database
    con = get_db()
    cur = con.cursor()

    try:
        # increment post's likes or dislikes field
        cur.execute("UPDATE Posts SET {} = {} + 1 WHERE post_id = {}".format(table, table, post_id))
        con.commit()
        return True
    except Exception as e:
        print(e)
        return None
    finally:
        cur.close()
        con.close()


def reply_to_post(reply_text, post_id, username):
    # connect to database
    con = get_db()
    cur = con.cursor()

    # get current time for time of reply
    time = datetime.now()

    try:
        # insert reply in database
        cur.execute("INSERT INTO Replies(content, post_time, uname, post_id) VALUES ('{}', '{}', '{}', {})".format(reply_text, time, username, post_id))
        con.commit()
        return True
    except Exception as e:
        print(e)
        return None
    finally:
        cur.close()
        con.close()


def get_post_replies(post_id):
    # connect to database
    con = get_db()
    con.row_factory = sql.Row
    cur = con.cursor()

    try:
        # get all replies to the post
        query = cur.execute("SELECT * FROM Replies WHERE post_id = {}".format(post_id))
        results = query.fetchall()

        # return replies in json
        results_json = json.dumps([dict(ix) for ix in results])
        return results_json
    except Exception as e:
        print(e)
        return None
    finally:
        cur.close()
        con.close()



