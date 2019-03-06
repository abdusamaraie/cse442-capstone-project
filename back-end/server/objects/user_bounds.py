class UserBounds:
    def __init__(self, user_lat, user_long, lat_dec, long_dec):

        # the four points around the user we will check within for messages
        self.lat_N = user_lat + lat_dec
        self.lat_S = user_lat - lat_dec
        self.long_E = user_long + long_dec
        self.long_W = user_long - long_dec
