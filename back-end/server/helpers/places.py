from constants.constants import PLACES_API_KEY
import requests
import json


# returns the places of interest near the user
def get_nearby_places(lat, lon):
    url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?'
    location = str(lat) + ',' + str(lon)

    # make http request to google places api
    payload = {'location': location, 'rankby': 'distance', 'key': PLACES_API_KEY}
    response = requests.get(url=url, params=payload)

    relevant_places = {'places': []}
    for place in response.json()['results'][:5]:
        ret = {'name': place['name'], 'place_id': place['place_id']}
        relevant_places['places'].append(ret)

    print(relevant_places)
    return json.dumps(relevant_places)
