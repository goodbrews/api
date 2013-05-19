# api.goodbre.ws [![Build Status](https://travis-ci.org/goodbrews/api.png?branch=master)](https://travis-ci.org/goodbrews/api)

This is the backend API for [goodbre.ws][goodbrews]. More documentation coming soon as the API is written.

[goodbrews]: https://goodbre.ws/

## Running tests [![Coverage Status](https://coveralls.io/repos/goodbrews/api/badge.png?branch=master)](https://coveralls.io/r/goodbrews/api?branch=master)

The goodbre.ws API is extensively tested using MiniTest and some Mocha assertions. To run tests, run the following commands after having cloned the git repository:

1. `cd api`
2. `cp config/database.yml.sample config/database.yml`
3. `cp config/auth.yml.sample config/auth.yml`
4. `cp config/initializers/secret_token.rb.sample config/initializers/secret_token.rb`
5. Update the above files as necessary
6. `bundle exec rake db:setup`
7. `bundle exec rake`
