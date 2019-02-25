from objects.user import User

import sqlite3 as sql

def add_user(user):

    con = sql.connect("database/users.db")
    cur = con.cursor()

    try:
        cur.execute("INSERT INTO Users (email,hashed_password) VALUES (?,?)", (user.username, user.password_hash))
        con.commit()
        return True
    except Exception as e:
        return None  # return None if error
    finally:
        cur.close()
        con.close()



def post_message(user, location, message):

    print('Add message to message table')

    # return None if error