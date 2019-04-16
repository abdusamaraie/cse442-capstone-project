from constants.constants import PLACES_API_KEY, DEFAULT_PLACE_PHOTO, EARTH_RADIUS_METERS
from math import pi, cos, sqrt, sin, atan2
import requests
import json


# returns the places of interest near the user
def get_nearby_places(lat, lon):
    url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?'
    location = str(lat) + ',' + str(lon)

    # make http request to google places api
    payload = {'location': location, 'rankby': 'distance', 'key': PLACES_API_KEY}
    response = requests.get(url=url, params=payload)

    # form json of top 5 nearby places
    relevant_places = {'places': []}
    for place in response.json()['results'][:5]:
        ret = {'name': place['name'], 'place_id': place['place_id'], 'photo_reference': place['photo_reference']}
        relevant_places['places'].append(ret)

    print(relevant_places)
    return json.dumps(relevant_places)


def get_place_info(place_id):

    # make http request to google places api
    url = 'https://maps.googleapis.com/maps/api/place/details/json?'
    payload = {'place_id': place_id, 'fields': 'name,photo,geometry,type', 'key': PLACES_API_KEY}
    place_info = requests.get(url=url, params=payload).json()['result']

    # if the place has a photo
    if 'photos' in place_info:
        # get place photo
        ref = place_info['photos'][0]['photo_reference']
        url = 'https://maps.googleapis.com/maps/api/place/photo?'

        # make http request to google places photos api
        payload = {'photoreference': ref, 'maxheight': 600, 'key': PLACES_API_KEY}
        photo_url = requests.get(url=url, params=payload).url  # grab response url (photo url)
        place_info['photo_url'] = photo_url

    # if the place has no photo, use a default
    else:
        place_info['photo_url'] = DEFAULT_PLACE_PHOTO

    return place_info


def distance_from_place(place_id, lat1, lon1):

    # make http request to google places api
    url = 'https://maps.googleapis.com/maps/api/place/details/json?'
    payload = {'place_id': place_id, 'fields': 'geometry', 'key': PLACES_API_KEY}
    place_info = requests.get(url=url, params=payload).json()['result']

    # get place coordinates
    lat2 = place_info['geometry']['location']['lat']
    lon2 = place_info['geometry']['location']['lng']

    # haversine distance formula
    d_lat = (lat2-lat1) * pi / 180
    d_lng = (lon2-lon1) * pi / 180

    lat1 = lat1 * pi / 180
    lat2 = lat2 * pi / 180

    val = sin(d_lat/2) * sin(d_lat/2) + sin(d_lng/2) * sin(d_lng/2) * cos(lat1) * cos(lat2)
    ang = 2 * atan2(sqrt(val), sqrt(1-val))

    return str(EARTH_RADIUS_METERS * ang)