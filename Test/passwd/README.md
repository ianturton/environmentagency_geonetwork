# Selenium IDE Tests

## Assumptions

* Working GeoNetwork instance with
    * EA password enhancements applied
    * An `admin` user who is a GeoNetwork Administrator
    * GeoNetwork is available at `/geonetwork/`

## Setup

Requires Firefox with Selenium IDE Extension.

## Running

Open the test case `test_passwd.html` in Selenium IDE, set the `Base URL` to the root of a server (for instance `http://localhost:8080/`) and run the test case.

**NOTE:** You will be prompted for a username and password of a test user when the test case runs, providing all steps in the test case complete this user will be deleted at the end of the run.

## Tests

The test case `test_passwd.html` incorporates the following tests:

* New user (admin)
    * Login as `admin`
    * Create test user with password and test password validation
* Reset password (admin)
    * Reset password for test user and test password validation
* Change password (user)
    * Login as test user
    * Reset password and test password validation
* Forgotten password (user)
    * Logout
    * Visit reset password page and test password validation
