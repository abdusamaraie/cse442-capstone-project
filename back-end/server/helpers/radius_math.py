from objects.user_radius import UserRadius

def get_user_radius(location, distance):

    lat = location['longitude']
    long = location['latitude']

    # converts the user's defined radius from meters to decimal degrees