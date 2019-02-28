DROP TABLE IF EXISTS Users;
Create table IF NOT EXISTS Users (
    user_id integer primary key autoincrement,
    fullname text,
    username text not null unique,
    hashed_password text not null
);