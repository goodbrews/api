# api.goodbre.ws [![build status](https://travis-ci.org/goodbrews/api.png)][travis] [![Coverage Status](https://coveralls.io/repos/goodbrews/api/badge.png?branch=master)][coveralls]

This is the code that powers the API of the upcoming goodbre.ws rewrite.

## Requirements

* Ruby 2.1.0 with bundler installed
* PostgreSQL
* Redis

## Getting started

To set the API up for local development, first do the following:

```sh
bundle install
bundle exec rake db:setup
```

Then, to start the server:

```sh
bundle exec rackup
```

Try some requests:

```sh
curl --include '0.0.0.0:9292/breweries/'
```

## Running the tests

To run all of the tests (note that the API is automatically tested via [Travis CI][travis]):

```sh
rspec # Optionally specify a path: spec/models/
```

[travis]: https://travis-ci.org/goodbrews/api
[coveralls]: https://coveralls.io/r/goodbrews/api?branch=master
