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

def post_message(user, location, message, time):
    # connect to DB
    con = get_db()
    cur = con.cursor()

    try:
        cur.execute("INSERT INTO Post (Content, Time, Location) VALUES (?,?)", (message, time, location))
        con.commit()
        return True
    except Exception as e:
        return None  # return None if error
    finally:
        cur.close()
        con.close()

    # print('Add message to message table')