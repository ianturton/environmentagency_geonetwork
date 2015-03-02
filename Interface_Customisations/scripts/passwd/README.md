# Password Enhancements for GeoNetwork

## Password Complexity

GeoNetwork 2.10 implements basic check on password complexity when an admin or user sets a password via JavaScript. The script passwd.js enforces the following checks:

* must be a minimum 8 characters
* must have a minimum of one upper case, one lower case and one numeric character
* must prohibit obvious sequences or repeated characters, for example 111 or abc

### Test

First ensure the dependencies are loaded by running `npm install` from this directory.

#### Browser

Open `test/index.html` in a browser to run the tests.

#### Node

When in this directory run `npm run test` to run the tests.
