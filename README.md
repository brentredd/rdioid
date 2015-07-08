# Rdioid

A simple Ruby Gem wrapper for the Rdio Web Services API with OAuth 2.0. Handles OAuth authentication and API calls.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rdioid'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rdioid

## Rdioid::Client

### Class methods
```
.authorization_url(options = {})
```

### Instance methods
```
#api_request(access_token, body = {})

#request_device_code(options = {})

#request_token_with_authorization_code(code, options = {})

#request_token_with_client_credentials(options = {})

#request_token_with_device_code(device_code, options = {})

#request_token_with_password(username, password, options = {})

#request_token_with_refresh_token(refresh_token, options = {})
```

## Usage

### Config
```ruby
Rdioid.configure do |config|
  config.client_id = 'your_client_id'
  config.client_secret = 'your_client_secret'
  config.redirect_uri = 'http://your_redirect_uri/'
end
```

### Oauth
```ruby
Rdioid::Client.authorization_url
# => "https://www.rdio.com/oauth2/authorize/?response_type=code&client_id=your_client_id&redirect_uri=http%3A%2F%2Fyour_redirect_uri%2F"

rdioid_client = Rdioid::Client.new
rdioid_client.request_token_with_authorization_code('a1b2c3')
# => { "access_token" => "AAbbCC", "token_type" => "bearer", "expires_in" => 43200, "refresh_token" => "DDeeFF", "scope" => "" }
```

### API Request
```ruby
rdioid_client = Rdioid::Client.new

body = {
  :method => 'searchSuggestions', # http://www.rdio.com/developers/docs/web-service/methods/
  :query => 'Run_Return',
  :types => 'Artist'
}

rdio_client.api_request('AAbbCC', body)
# => { "status" => "ok", "result" => [{ "name" => "Run_Return", "key" => "r400361" }] }
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/reddshack/rdioid.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
