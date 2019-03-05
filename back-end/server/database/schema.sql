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
    postId    INTEGER      PRIMARY KEY AUTOINCREMENT,
    latitude  DOUBLE,
    longitude DOUBLE,
    content   TEXT,
    time      DATETIME,
    likes     INTEGER      DEFAULT (0),
    dislikes  INTEGER      DEFAULT (0),
    uname     VARCHAR (30) REFERENCES Users (username) ON DELETE CASCADE
);
