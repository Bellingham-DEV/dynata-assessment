# Dynata Assessment

Completed by Patrick Morgan on 9/16/23 in consideration for the position of Software Architect at Dynata.

See ASSESSMENT.md for background.

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

# Setup

For convenience, this assessment project is setup to use a Docker runtime environment.

Make sure you have Docker installed and running, with the `docker-compose` tool installed and working.

```bash
# Copy the example envvars
cp .env.example .env
```

# Demo

For ease of assessment, the solution is presented using a Sinatra web application which listens on port `3000`.

```bash
# Start the Web app and run automated tests
docker-compose up
```

Use your web browser to visit [http://localhost:3000](http://localhost:3000/).

Paste a sample http frame into the textarea and hit submit.

# Running Just the Tests

Tests are automatically run as a part of the Docker Compose application, but they can be run in isolation.

```bash
docker-compose run test bundle exec rspec
```

## Examples

Assessment examples are found at `spec/examples/*.json`
