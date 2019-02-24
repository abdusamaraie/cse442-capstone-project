DROP TABLE IF EXISTS Users;
Create table IF NOT EXISTS Users (
    userId integer primary key autoincrement,
    name text not null,
    email text not null,
    password text not null
);