DROP TABLE IF EXISTS Users;
CREATE TABLE IF NOT EXISTS Users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    fname TEXT,
    lname TEXT,
    username TEXT NOT NULL UNIQUE,
    hashed_password TEXT NOT NULL
);

DROP TABLE IF EXISTS post;
CREATE TABLE post (
    postId    INTEGER      PRIMARY KEY AUTOINCREMENT,
    latitude  DOUBLE,
    longitude DOUBLE,
    content   TEXT,
    time      DATETIME,
    likes     INTEGER      DEFAULT (0),
    dislikes  INTEGER      DEFAULT (0),
    uname     VARCHAR (30) REFERENCES user (username) ON DELETE CASCADE
);
