# Rdioid

A simple Ruby Gem wrapper for the Rdio Web Service API with OAuth 2.0. Handles OAuth requests and API requests.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rdioid'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rdioid

## Usage

### Config
```ruby
Rdioid.configure do |config|
  config.client_id = 'your_client_id'
  config.client_secret = 'your_client_secret'
  config.redirect_uri = 'http://your_redirect_uri/'
end
```

### OAuth
Use these methods to request an `access_token`.

#### Authorization Code
```ruby
Rdioid::Client.authorization_url
# => https://www.rdio.com/oauth2/authorize/?response_type=code&client_id=a1b2c3&redirect_uri=http%3A%2F%test.com%2F
#
# redirect User to this URL

# GET request to your "redirect_uri" after User has allowed access
# => http://test.com/?code=ImSLMoN02mqBkO

rdioid_client = Rdioid::Client.new
code = 'ImSLMoN02mqBkO'

rdioid_client.request_token_with_authorization_code(code)
# => { "access_token" => "manFxdW1-WuBd", "token_type" = >"bearer", "expires_in" => 43200, "refresh_token" = >"06l79UCO90G", "scope" => "" }
```

#### Client Credentials
```ruby
rdioid_client = Rdioid::Client.new

rdioid_client.request_token_with_client_credentials
# => { "access_token" => "AAAdmanFxdWxlayip", "token_type" => "bearer", "expires_in" => 43200, "scope" => "" }
```

#### Device Code
```ruby
rdioid_client = Rdioid::Client.new

rdioid_client.request_device_code
# => { "expires_in_s" => 1800, "device_code" => "2479RA", "interval_s" => 5, "verification_url" => "rdio.com/device" }
#
# redirect User to "verification_url"

code = '2479RA'

# poll this method at a rate of "interval_s", waiting for a response without an "error"
#
rdioid_client.request_token_with_device_code(code)
# => { "error_description" => "user has not approved this code yet", "error" => "pending_authorization" }

rdioid_client.request_token_with_device_code(code)
# => { "access_token" => "AAAA3lB6RbI3l8", "token_type" => "bearer", "expires_in" => 43200, "refresh_token" => "AAAFxdWxlbX1z", "scope" => "" }
```

#### Implicit Grant
```ruby
Rdioid::Client.authorization_url(:response_type => 'token')
# => https://www.rdio.com/oauth2/authorize/?response_type=token&client_id=a1b2c3&redirect_uri=http%3A%2F%test.com%2F
#
# redirect User to this URL

# GET request to your "redirect_uri" after User has allowed access
# => http://test.com/#access_token=AAAAWMgAAAIB-4ACc6qc&token_type=bearer&expires_in=43199
```

#### Resource Owner Credential
```ruby
rdioid_client = Rdioid::Client.new
username = 'rdioid@test.com'
password = 'ruby<3'

rdioid_client.request_token_with_password(username, password)
# => { "access_token" => "AAp2Y2dmWxlan", "token_type" => "bearer", "expires_in" => 43200, "refresh_token" => "AAAX1z4mNk84", "scope" => "" }
```

#### Refresh Token
After an `access_token` has expired, use the received `refresh_token` to request another one.

```ruby
rdioid_client = Rdioid::Client.new
refresh_token = 'AAxlayVmNkMzwlYY64TNB'

rdioid_client.request_token_with_refresh_token(refresh_token)
# => { "access_token" => "AAJ3bXHQWqh5ueD6", "token_type" => "bearer", "expires_in" => 43200, "refresh_token" => "AAAoyYWJ3beClfGsm", "scope" => "" }
```

### Web Service API Request
Use the `access_token` and provide a `:method` to send a Web Service API request.

Available methods: http://www.rdio.com/developers/docs/web-service/methods/

```ruby
rdioid_client = Rdioid::Client.new
access_token = 'AAWEAAVWMgAAAABVsG3t'

rdioid_client.api_request(access_token)
# => { "status" => "error", "message" => "You must pass a method name as an HTTP POST parameter named \"method\".", "code" => 400 }

rdioid_client.api_request(access_token, :method => 'getTopCharts', :type => 'Artist', :count => 3, :extras => '-*,name')
# => { "status" => "ok", "result" => [{ "name" => "Future" }, { "name" => "Tame Impala" }, { "name" => "Ratatat" }] }

rdioid_client.api_request(access_token, :method => 'searchSuggestions', :query => 'Mac', :types => 'Artist', :count => 3, :extras => '-*,name')
# => { "status" => "ok", "result" => [{ "name" => "Macklemore & Ryan Lewis" }, { "name" => "Mac Miller" }, { "name" => "Macy Gray" }] }

rdioid_client.api_request(access_token, :method => 'getAlbumsInCollection', :extras => '-*,name')
# => { "status" => "ok", "result" => [{ "name" => "Adore" }, { "name" => "Against The Grain (Reissue)" }, { "name" => "Agony & Irony" }] }

rdioid_client.api_request(access_token, :method => 'getFavorites')
# => { "error_description" => "Invalid or expired access token", "error" => "invalid_token" }
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/reddshack/rdioid.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
