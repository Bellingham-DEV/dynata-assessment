Dynata Assessment

# The Solution

The solution is written in Ruby and has no dependencies outside the standard runtime.

A typical use of the `HttpSigner` class is:

```ruby
require_relative './http_signer'

http_frame = 'POST /resource/foobar ...'
access_key = 'XXX'
secret_key = 'YYY'
service = HttpSigner.new(access_key:, secret_key:)
signature = service.call(http_frame)
```

# Running the Tests

For convenience, this assessment project is setup to use a Docker runtime environment.

The following instructions assume that  you have a working Docker runtime and `docker-compose` is installed.

## Setup

`docker-compose build`

## Running

```bash
docker-compose up
# OR
docker-compose run test bundle exec rspec
```

## Examples

Assessment examples are found at `spec/examples/*.json`
