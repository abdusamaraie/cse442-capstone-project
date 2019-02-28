DROP TABLE IF EXISTS Users;
Create table IF NOT EXISTS Users (
    user_id integer primary key autoincrement,
    fname text,
    lname text,
    username text not null unique,
    hashed_password text not null
);

DROP TABLE IF EXISTS post;
CREATE TABLE post (
    postId    INTEGER      PRIMARY KEY AUTOINCREMENT,
    latitude  DOUBLE,
    longitude DOUBLE,
    content   TEXT,
    time      DATETIME,
    uname     VARCHAR (30) REFERENCES user (username) ON DELETE CASCADE
);
