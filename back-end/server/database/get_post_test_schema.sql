DROP TABLE IF EXISTS post;

CREATE TABLE post (
    postId    INTEGER      PRIMARY KEY AUTOINCREMENT,
    latitude  DOUBLE,
    longitude DOUBLE,
    content   TEXT,
    time      DATETIME,
    uname     VARCHAR (30) REFERENCES user (uname) ON DELETE CASCADE
);


DROP TABLE IF EXISTS user;

CREATE TABLE user (
    uname    VARCHAR (30) PRIMARY KEY,
    password VARCHAR      NOT NULL
);
