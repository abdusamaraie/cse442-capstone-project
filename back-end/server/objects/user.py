from helpers import authenticate
class User:
    def __init__(self, username, password_hash=None):

        if not password_hash:
            self.password_hash = ''

        self.username = username
        self.password_hash = password_hash
        self.fullname = ''
        self.email = ''

    def setUser(self,fullname, email, username,password=None):
        self.fullname = fullname
        self.email = email
        self.username = username
        self.password_hash = authenticate.generate_hash(password)

