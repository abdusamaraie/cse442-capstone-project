import unittest
from datetime import datetime
from helpers import sqlite


class TestPostingReply(unittest.TestCase):
    def test_posting_replies(self):

        # get msg, username, and post_id from client
        username = "daru1"
        msg = "this is a test reply"
        time = datetime.now()
        post_id = 0  # assuming there is at least one post in the database

        self.assertTrue(sqlite.reply_to_post(msg, post_id, username))


if __name__ == '__main__':
        unittest.main()
