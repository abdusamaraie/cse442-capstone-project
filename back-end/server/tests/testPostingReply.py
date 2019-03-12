import unittest
from datetime import datetime
from helpers import sqlite


class TestPostingReply(unittest.TestCase):
    def test_posting_replies(self):

        # get msg, username, and post_id from client
        location = {'latitude': 43.0100431, 'longitude': -78.8012356}
        username = "daru"
        msg = "this is a test reply"
        time = datetime.now()

        # create a test post to reply to
        post_id = sqlite.post_message(username, location, msg, time)
        print(post_id)



        self.assertTrue(sqlite.reply_to_post(msg, post_id, username))

        # delete test post
        sqlite.delete_message(post_id)

if __name__ == '__main__':
        unittest.main()
