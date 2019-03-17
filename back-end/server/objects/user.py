from helpers import authenticate


class User:
    def __init__(self, username, firstname, lastname, email, password_hash, salt):

        # if not password_hash:
        #     self.password_hash = ''

        self.username = username
        self.password_hash = password_hash
        self.salt = salt
        self.firstname = firstname
        self.lastname = lastname
        self.email = email
        self.photo = ''

    def setUser(self, firstname, lastname, photourl, username, password=None):
        self.firstname = firstname
        self.lastname = lastname
        self.photo = photourl
        self.username = username
        self.password_hash = authenticate.generate_hash(password)

