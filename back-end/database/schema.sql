DROP TABLE IF EXISTS Users;
Create table IF NOT EXISTS Users (
    user_id integer primary key autoincrement,
    name text not null,
    email text not null,
    hashed_password text not null
);