from objects.user import User
from constants.constants import DATABASE_PATH
import sqlite3 as sql


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


def post_message(user, location, message):

    print('Add message to message table')

    # return None if error