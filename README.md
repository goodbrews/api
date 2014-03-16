# api.goodbre.ws

[![Build status][travis-badge]][travis] [![Coverage][coveralls-badge]][coveralls] [![Code Climate][code-climate-badge]][code-climate] [![Dependency Status][gemnasium-badge]][gemnasium] [![Tips][gittip-badge]][gittip]

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
[travis-badge]: http://img.shields.io/travis/goodbrews/api/master.svg
[coveralls]: https://coveralls.io/r/goodbrews/api
[coveralls-badge]: http://img.shields.io/coveralls/goodbrews/api/master.svg
[code-climate]: https://codeclimate.com/github/goodbrews/api
[code-climate-badge]: http://img.shields.io/codeclimate/github/goodbrews/api.svg
[gemnasium]: http://gemnasium.com/goodbrews/api
[gemnasium-badge]: http://img.shields.io/gemnasium/goodbrews/api.svg
[gittip]: https://gittip.com/davidcelis
[gittip-badge]: http://img.shields.io/gittip/davidcelis.svg
