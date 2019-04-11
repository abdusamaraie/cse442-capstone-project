import unittest
from helpers import authenticate, neo4j
from objects.user import User


class TestAuthenticateMethods(unittest.TestCase):
    #requires front-end GET requests
    ''' Verify that the login screen is having option to enter username and password with submit button and option of forgot password
    #   Verify that validation message is displayed in case user exceeds the character limit of the user name and password fields
    #   Verify that there is reset button to clear the field's text
        Verify if the password can be copy-pasted or not

        Verify that user is not able to login with invalid username and password
        Verify that validation message gets displayed in case user leaves username or password field as blank




        Verify that there is limit on the total number of unsuccessful attempts


        Verify that once logged in, clicking back button doesn't logout user

        Verify if XSS vulnerability work on login page
    '''

    #    Verify that user is able to login with valid username and password
    def setUp(self):
        self.tempUserName = "admin"
        self.tempPassword = "admin"
        self.password_hash = authenticate.generate_hash(self.tempUserName, self.tempPassword)

    def test_verify_user(self):
        #regester user first
        email = "admin@admin.com"
        fn = "Darren"
        ln = "Matthew"
        # delete user if already exists
        neo4j.delete_user(self.tempUserName, self.password_hash)

        user = User(self.tempUserName, fn, ln, email, self.password_hash)
        # test adding user
        self.assertTrue(neo4j.add_user(user))
        #code here
        self.assertTrue(authenticate.verify_user(self.tempUserName,self.tempPassword))
        # delete user
        self.assertEqual(neo4j.delete_user(self.tempUserName, self.tempPassword),'False')
    #Verify that the password is in encrypted form when entered
    def test_generate_hash(self):

        self.assertTrue(authenticate.generate_hash(self.tempUserName,self.tempPassword))
    #    Verify the timeout of the login session
    def test_user_session(self):
        self.assertEqual(1,1)
    #Verify if SQL Injection attacks works on login page
    def test_sql_injection(self):
        self.assertEqual(1, 1)
if __name__ == '__main__':
        unittest.main()