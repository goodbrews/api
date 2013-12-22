# api.goodbre.ws ![build status](https://travis-ci.org/goodbrews/api.png)

This is the code that powers the API of the upcoming goodbre.ws rewrite.

## Requirements

* Ruby 2.0.0-p353 with bundler installed
* PostgreSQL
* Redis

## Getting started

To set the API up for local development, first do the following:

```sh
cp config/database.yml.sample config/database.yml
cp config/redis.yml.sample config/redis.yml
bundle exec rake db:setup
```

Then, to start the server:

```sh
rackup
```

Try some requests:

```sh
curl --include '0.0.0.0:9292/breweries/'
```

## Running the tests

To run all of the tests (note that the API is automatically tested via Travis CI):

```sh
rspec # Optionally specify a path: spec/models/
```
