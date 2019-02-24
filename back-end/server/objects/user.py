class User:
    def __init__(self, username, password_hash=None):

        if not password_hash:
            password_hash = ''

        self.username = username
        self.password_hash = password_hash