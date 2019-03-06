DROP TABLE IF EXISTS Users;
CREATE TABLE Users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    fname TEXT,
    lname TEXT,
    photo_url TEXT,
    username TEXT NOT NULL UNIQUE,
    hashed_password TEXT NOT NULL
);

DROP TABLE IF EXISTS Posts;
CREATE TABLE Posts (
    post_id    INTEGER      PRIMARY KEY AUTOINCREMENT,
    latitude  DOUBLE,
    longitude DOUBLE,
    content   TEXT,
    post_time      DATETIME,
    expire_time DATETIME,
    likes     INTEGER      DEFAULT (0),
    dislikes  INTEGER      DEFAULT (0),
    uname     VARCHAR (30) REFERENCES Users (username) ON DELETE CASCADE
);

DROP TABLE IF EXISTS Replies;
CREATE TABLE Replies (
    reply_id   INTEGER      PRIMARY KEY AUTOINCREMENT,
    content   TEXT,
    post_time      DATETIME,
    uname     VARCHAR (30) REFERENCES Users (username) ON DELETE CASCADE,
    post_id    INTEGER REFERENCES Posts (post_id) ON DELETE CASCADE
);