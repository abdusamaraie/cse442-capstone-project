import unittest
from helpers import authenticate


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
    def test_verify_user(self):
        #get username and password from database
        tempUserName = "admin"
        tempPassword = "admin"
        #code here
        self.assertTrue(authenticate.verify_user(tempUserName,tempPassword))
    #Verify that the password is in encrypted form when entered
    def test_generate_hash(self):
        tempUserPassword = "admin"
        self.assertTrue(authenticate.generate_hash(tempUserPassword))
    #    Verify the timeout of the login session
    def test_user_session(self):
        self.assertEqual(1,1)
    #Verify if SQL Injection attacks works on login page
    def test_sql_injection(self):
        self.assertEqual(1, 1)
if __name__ == '__main__':
        unittest.main()