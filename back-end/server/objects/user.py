from helpers import authenticate
class User:
    def __init__(self, username, password_hash=None):

        if not password_hash:
            self.password_hash = ''

        self.username = username
        self.password_hash = password_hash
        self.firstname = ''
        self.lastname = ''


    def setUser(self,firstname, lastname, username,password=None):
        self.firstname = firstname
        self.lastname = lastname
        self.username = username
        self.password_hash = authenticate.generate_hash(password)

