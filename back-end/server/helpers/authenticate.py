import hashlib
import base64
import uuid
import sqlite3 as sql
from constants.constants import HASH_PASSWORD_PATH,DATABASE_PATH


def generate_hash(password):
    tf_out = open(HASH_PASSWORD_PATH, 'wb')

    salt = base64.urlsafe_b64encode(uuid.uuid4().bytes)

    t_sha = hashlib.sha512()
    t_sha.update(password.encode('utf-8') + salt)

    hashed_password = base64.urlsafe_b64encode(t_sha.digest())
    tf_out.write(hashed_password)
    tf_out.close()

    return hashed_password


def verify_user(username, password_hash):

    con = sql.connect(DATABASE_PATH)
    cur = con.cursor()

    try:
        login = cur.execute("SELECT * from Users WHERE username = ? AND hashed_password = ? ", (username, password_hash))
        if len(login.fetchall()) > 0:
            return True
        else:
            return False
    except Exception as e:
        return str(e)
    finally:
        cur.close()
        con.close()
