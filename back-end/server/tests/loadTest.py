import requests
import json
from pytz import timezone
from datetime import datetime
from datetime import timedelta
import random

lat = 43.0100431
lon = -78.8012356

location = {"latitude": lat, "longitude": lon}

es = timezone("US/Eastern")
exp_time = str(datetime.now().astimezone(es) + timedelta(days=7))

ip = "http://34.73.109.229:80"
# ip = "http://127.0.0.1:5000"

numUsers = range(200)
post_ids = []

# MAKE USERS AND POSTS
for i in numUsers:
    uname = 'user' + str(i)
    print(uname)

    # SIGN UP
    fname = 'First' + str(i)
    lname = 'Last' + str(i)
    payload = {'username': uname, 'firstname': fname, 'lastname': lname, 'password': 'pass', 'email': uname + '@test.com'}
    r = requests.post(ip + '/auth', json=payload)
    print(r.text)

    # MAKE 2 POSTS
    location = {"latitude": random.uniform(43.008, 43.012), "longitude": random.uniform(-78.799, -78.803)}
    payload = {"username": uname, "location": location, "message": "This is a " + uname + " post.", "expireTime": exp_time, "placeId": "Other"}
    r = requests.post(ip + '/message', json=payload)
    post_ids.append(r.text)
    print("    PostId:" + r.text)

    location = {"latitude": random.uniform(43.008, 43.012), "longitude": random.uniform(-78.799, -78.803)}
    payload = {"username": uname, "location": location, "message": "This is the second " + uname + " post.", "expireTime": exp_time, "placeId": "Other"}
    r = requests.post(ip + '/message', json=payload)
    post_ids.append(r.text)
    print("    PostId:" + r.text)


# MAKE RATINGS AND RELIES
for i in numUsers:
    uname = 'user' + str(i)
    # EACH USER MAKES 20 RATINGS ON RANDOM POSTS
    for j in range(20):
        rating = bool(random.getrandbits(1))
        payload = {"username": uname, "rating": rating, "postId": random.choice(post_ids)}
        r = requests.post(ip + '/rating', json = payload)
        print(r.text)

    # MAKE 1 REPLY TO A RANDOM POST
    payload = {"postId": random.choice(post_ids), "username": uname, "replyText": uname + " test reply"}
    r = requests.post(ip + '/replies', json=payload)
    print(r.text)


'''
for i in range(200):
    # DEACTIVATE ALL USERS
    uname = 'user' + str(i)
    payload = {'username': uname, 'password': 'pass'}
    r = requests.delete(ip + '/deactivate', json=payload)
    print(r.text)
'''