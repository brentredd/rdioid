module Rdioid
  # Once *Rdioid* is configured with all required values, *Rdioid::Client* is
  # able to make requests to the <b>Web Service API</b>.
  class Client
    ##
    # Provides the redirect URL for <b>Authorization Code</b> and <b>Implicit Grant</b>.
    #
    # @param options [Hash] additional query string values
    # @option options [String] :response_type ('code') for <b>Authorization Code</b>, or use +'token'+ for <b>Implicit Grant</b>
    # @option options [String] :scope the desired scope you wish to have access to
    # @option options [String] :state a string you provide that will be returned back to you
    #
    # @return [String] escaped URL used for redirection
    #
    # @example Authorization Code
    #   Rdioid::Client.authorization_url
    #   # => https://www.rdio.com/oauth2/authorize/?response_type=code&client_id=a1b2c3&redirect_uri=http%3A%2F%test.com%2F
    #
    #   # GET request to your +redirect_uri+ after User has allowed access
    #   # => http://test.com/?code=ImSLMoN02mqBkO
    #
    #   # GET request to your +redirect_uri+ after User has denied access
    #   # => http://test.com/?error=access_denied
    #
    # @example
    #   Rdioid::Client.authorization_url(:state => 'new_user')
    #   # => https://www.rdio.com/oauth2/authorize/?response_type=code&client_id=a1b2c3&redirect_uri=http%3A%2F%test.com%2F&state=new_user
    #
    #   # GET request to your +redirect_uri+ after User has allowed access
    #   # => http://test.com/?state=new_user&code=ImSLMoN02mqBkO
    #
    #   # GET request to your +redirect_uri+ after User has denied access
    #   # => http://test.com/?state=new_user&error=access_denied
    #
    # @example Implicit Grant
    #   Rdioid::Client.authorization_url(:response_type => 'token')
    #   # => https://www.rdio.com/oauth2/authorize/?response_type=token&client_id=a1b2c3&redirect_uri=http%3A%2F%test.com%2F
    #
    #   # GET request to your +redirect_uri+ after User has allowed access
    #   # => http://test.com/#access_token=AAAAWMgAAAIB-4ACc6qc&token_type=bearer&expires_in=43199
    #
    #   # GET request to your +redirect_uri+ after User has denied access
    #   # => http://test.com/#error=access_denied
    #
    # @example
    #   Rdioid::Client.authorization_url(:response_type => 'token', :state => 'new_user')
    #   # => https://www.rdio.com/oauth2/authorize/?response_type=token&client_id=a1b2c3&redirect_uri=http%3A%2F%test.com%2F&state=new_user
    #
    #   # GET request to your +redirect_uri+ after User has allowed access
    #   # => http://test.com/#access_token=AAAAWMgAAAIB-4ACc6qc&token_type=bearer&state=new_user&expires_in=43199
    #
    #   # GET request to your +redirect_uri+ after User has denied access
    #   # => http://test.com/#state=new_user&error=access_denied
    #
    def self.authorization_url(options = {})
      query = {
        :response_type => 'code',
        :client_id => Rdioid.config.client_id,
        :redirect_uri => Rdioid.config.redirect_uri
      }.merge(options)

      authorization_query = HTTP::Message.escape_query(query)

      "#{Rdioid::AUTHORIZATION_URL}?#{authorization_query}"
    end

    ##
    # Initializes a new Client for making OAuth and Web Service API requests.
    #
    def initialize
      self.http_client = HTTPClient.new(:base_url => Rdioid::BASE_URL, :force_basic_auth => true)

      http_client.set_auth(Rdioid::OAUTH_TOKEN_ENDPOINT, Rdioid.config.client_id, Rdioid.config.client_secret)
    end

    ##
    # Sends a request to the Web Service API.
    #
    # @param access_token [String] OAuth token required for sending requests to the Web Service API
    # @param body [Hash] values to send in the body of the request
    # @option body [String] :method method for the request: http://www.rdio.com/developers/docs/web-service/methods/
    # @option body [Hash] :* additional *Arguments* unique to each +method+
    #
    # @return [Hash] response from the Web Service API
    #
    # @example
    #   rdioid_client = Rdioid::Client.new
    #   access_token = 'AAWEAAVWMgAAAABVsG3t'
    #
    #   rdioid_client.api_request(access_token)
    #   # => { "status" => "error", "message" => "You must pass a method name as an HTTP POST parameter named \"method\".", "code" => 400 }
    #
    #   rdioid_client.api_request(access_token, :method => 'getTopCharts', :type => 'Artist', :count => 3, :extras => '-*,name')
    #   # => { "status" => "ok", "result" => [{ "name" => "Future" }, { "name" => "Tame Impala" }, { "name" => "Ratatat" }] }
    #
    #   rdioid_client.api_request(access_token, :method => 'searchSuggestions', :query => 'Mac', :types => 'Artist', :count => 3, :extras => '-*,name')
    #   # => { "status" => "ok", "result" => [{ "name" => "Macklemore & Ryan Lewis" }, { "name" => "Mac Miller" }, { "name" => "Macy Gray" }] }
    #
    #   rdioid_client.api_request(access_token, :method => 'getAlbumsInCollection', :extras => '-*,name')
    #   # => { "status" => "ok", "result" => [{ "name" => "Adore" }, { "name" => "Against The Grain (Reissue)" }, { "name" => "Agony & Irony" }] }
    #
    #   rdioid_client.api_request(access_token, :method => 'getFavorites')
    #   # => { "error_description" => "Invalid or expired access token", "error" => "invalid_token" }
    #
    def api_request(access_token, body = {})
      header = {
        :Authorization => "Bearer #{access_token}"
      }

      request(Rdioid::API_ENDPOINT, :header => header, :body => body)
    end

    ##
    # Requests an OAuth +device_code+ for the <b>Device Code Grant</b>.
    #
    # @param options [Hash] additional request values
    # @option options [String] :scope the desired scope you wish to have access to
    #
    # @return [Hash] response from the Web Service API
    #
    # @example
    #   rdioid_client = Rdioid::Client.new
    #
    #   rdioid_client.request_device_code
    #   # => { "expires_in_s" => 1800, "device_code" => "2479RA", "interval_s" => 5, "verification_url" => "rdio.com/device" }
    #
    def request_device_code(options = {})
      body = {
        :client_id => Rdioid.config.client_id,
      }.merge(options)

      request(Rdioid::OAUTH_DEVICE_CODE_ENDPOINT, :body => body)
    end

    ##
    # Requests an OAuth +access_token+ using the <b>Authorization Code Grant</b>.
    #
    # @param code [String] OAuth code received from the +.authorization_url+ redirect
    # @param options [Hash] additional request values
    # @option options [String] :scope the desired scope you wish to have access to
    #
    # @return [Hash] response from the Web Service API
    #
    # @example
    #   rdioid_client = Rdioid::Client.new
    #   code = 'ImSLMoN02mqBkO'
    #
    #   rdioid_client.request_token_with_authorization_code(code)
    #   # => { "access_token" => "manFxdW1-WuBd", "token_type" = >"bearer", "expires_in" => 43200, "refresh_token" = >"06l79UCO90G", "scope" => "" }
    #
    #   rdioid_client.request_token_with_authorization_code(code)
    #   # => { "error_description" => "unknown authorization code ImSLMoN02mqBkO", "error" => "invalid_grant" }
    #
    def request_token_with_authorization_code(code, options = {})
      body = {
        :grant_type => 'authorization_code',
        :code => code,
        :redirect_uri => Rdioid.config.redirect_uri
      }.merge(options)

      request(Rdioid::OAUTH_TOKEN_ENDPOINT, :body => body)
    end

    ##
    # Requests an OAuth +access_token+ using the <b>Client Credentials</b>.
    #
    # @param options [Hash] additional request values
    # @option options [String] :scope the desired scope you wish to have access to
    #
    # @return [Hash] response from the Web Service API
    #
    # @example
    #   rdioid_client = Rdioid::Client.new
    #
    #   rdioid_client.request_token_with_client_credentials
    #   # => { "access_token" => "AAAdmanFxdWxlayip", "token_type" => "bearer", "expires_in" => 43200, "scope" => "" }
    #
    def request_token_with_client_credentials(options = {})
      body = {
        :grant_type => 'client_credentials'
      }.merge(options)

      request(Rdioid::OAUTH_TOKEN_ENDPOINT, :body => body)
    end

    ##
    # Requests an OAuth +access_token+ using the <b>Device Code Grant</b>.
    #
    # @param device_code [String] +device_code+ received from calling +#request_device_code+
    # @param options [Hash] additional request values
    # @option options [String] :scope the desired scope you wish to have access to
    #
    # @return [Hash] response from the Web Service API
    #
    # @example
    #   rdioid_client = Rdioid::Client.new
    #   device_code = 'BX55E2'
    #
    #   rdioid_client.request_token_with_device_code(device_code)
    #   # => { "error_description" => "user has not approved this code yet", "error" => "pending_authorization" }
    #
    #   rdioid_client.request_token_with_device_code(device_code)
    #   # => { "access_token" => "AAAA3lB6RbI3l8", "token_type" => "bearer", "expires_in" => 43200, "refresh_token" => "AAAFxdWxlbX1z", "scope" => "" }
    #
    #   rdioid_client.request_token_with_device_code(device_code)
    #   # => { "error_description" => "no entry found for given device_code", "error" => "invalid_request" }
    #
    def request_token_with_device_code(device_code, options = {})
      body = {
        :grant_type => 'device_code',
        :device_code => device_code
      }.merge(options)

      request(Rdioid::OAUTH_TOKEN_ENDPOINT, :body => body)
    end

    ##
    # Requests an OAuth +access_token+ using the <b>Resource Owner Credential</b>.
    #
    # @param username [String] email address for the User
    # @param password [String] password for the User
    # @param options [Hash] additional request values
    # @option options [String] :scope the desired scope you wish to have access to
    #
    # @return [Hash] response from the Web Service API
    #
    # @example
    #   rdioid_client = Rdioid::Client.new
    #   username = 'rdioid@test.com'
    #   password = 'ruby<3'
    #
    #   rdioid_client.request_token_with_password(username, password)
    #   # => { "access_token" => "AAp2Y2dmWxlan", "token_type" => "bearer", "expires_in" => 43200, "refresh_token" => "AAAX1z4mNk84", "scope" => "" }
    #
    #   rdioid_client.request_token_with_password(username, password)
    #   # => { "error_description" => "This client is not authorized to use the password grant", "error" => "unauthorized_client" }
    #
    def request_token_with_password(username, password, options = {})
      body = {
          :grant_type => 'password',
          :username => username,
          :password => password
      }.merge(options)

      request(Rdioid::OAUTH_TOKEN_ENDPOINT, :body => body)
    end

    ##
    # Requests an OAuth +access_token+ using the <b>Refresh Token</b>.
    #
    # @param refresh_token [String] refresh token previously issued during an +access_token+ request
    # @param options [Hash] additional request values
    # @option options [String] :scope the desired scope you wish to have access to
    #
    # @return [Hash] response from the Web Service API
    #
    # @example
    #    rdioid_client = Rdioid::Client.new
    #    refresh_token = 'AAxlayVmNkMzwlYY64TNB'
    #
    #    rdioid_client.request_token_with_refresh_token(refresh_token)
    #    # => { "access_token" => "AAJ3bXHQWqh5ueD6", "token_type" => "bearer", "expires_in" => 43200, "refresh_token" => "AAAoyYWJ3beClfGsm", "scope" => "" }
    #
    #    rdioid_client.request_token_with_refresh_token(refresh_token)
    #    # => { "error_description" =>  "invalid refresh token", "error" => "invalid_grant" }
    #
    def request_token_with_refresh_token(refresh_token, options = {})
      body = {
        :grant_type => 'refresh_token',
        :refresh_token => refresh_token
      }.merge(options)

      request(Rdioid::OAUTH_TOKEN_ENDPOINT, :body => body)
    end

  private
    attr_accessor :http_client

    def request(endpoint, options = {})
      response = http_client.post(endpoint, options)

      JSON.parse(response.body)
    end
  end
end