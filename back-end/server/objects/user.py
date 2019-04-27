from helpers import authenticate


class User:
    def __init__(self, username, firstname, lastname, email, password_hash, birthday):

        self.username = username
        self.password_hash = password_hash
        self.firstname = firstname
        self.lastname = lastname
        self.email = email
        self.birthday = birthday
