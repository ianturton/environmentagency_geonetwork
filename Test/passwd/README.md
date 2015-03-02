# Selenium IDE Tests

## Assumptions

* Working GeoNetwork instance with
    * EA password enhancements applied
    * An `admin` user who is a GeoNetwork Administrator

## Setup

Requires Firefox with Selenium IDE Extension.

## Running

Open the suite in Selenium IDE, set the `Base URL` to the root of a server (for instance `http://ec2-54-154-62-171.eu-west-1.compute.amazonaws.com:8080/`) and run the suite.

**NOTE:** The testcase `admin-create-and-reset` creates a test user which is subsiquently used by `user-reset` and `user-forgotten`. The `cleanup` testcase tidies up by removing the test user.

## Tests

### `admin-create-and-reset`

* New user (admin)
    * Login as `admin`
    * Create user `auto_test_user` with password and test password validation
* Reset password (admin)
    * Reset password for user `auto_test_user` and test password validation

### `user-reset`

* Change password (user)
    * Login as `auto_test_user`
    * Reset password and test password validation

### `user-forgotten`

* Forgotten password (user)
    * Logout
    * Visit `/geonetwork/srv/en/password.change.form?username=auto_test_user&changeKey=635d6c84ddda782a9b6ca9dda0f568b011bb7733` and test password validation
