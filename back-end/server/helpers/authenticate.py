import hashlib
import base64
import uuid
import sqlite3 as sql

def generate_hash(password):
    tf_out = open('database/user_hash_passwords.txt','wb')

    salt = base64.urlsafe_b64encode(uuid.uuid4().bytes)

    t_sha = hashlib.sha512()
    t_sha.update(password.encode('utf-8') + salt)

    hashed_password = base64.urlsafe_b64encode(t_sha.digest())
    tf_out.write(hashed_password)
    tf_out.close()

    return hashed_password


def verify_user(username, password_hash):

    con = sql.connect("database/users.db")
    cur = con.cursor()

    try:
        login = cur.execute('SELECT * from Users WHERE email = ? AND hashed_password = ?', (username, password_hash))
        if (len(login.fetchall()) > 0):
            return True
        else:
            return False
    except Exception as e:
        return str(e)
    finally:
        cur.close()
        con.close()