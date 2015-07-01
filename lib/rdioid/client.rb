module Rdioid
  class Client
      ##
      # Class methods
      #
      def self.authorization_url(options = {})
        query = {
          :response_type => 'code', # use 'token' for Implicit Grant
          :client_id => Rdioid.config.client_id,
          :redirect_uri => Rdioid.config.redirect_uri
        }.merge(options)

        authorization_query = HTTP::Message.escape_query(query)

        "#{Rdioid::AUTHORIZATION_URL}?#{authorization_query}"
      end

      ##
      # Constructor
      #
      def initialize
        self.http_client = HTTPClient.new(:base_url => Rdioid::BASE_URL, :force_basic_auth => true)

        http_client.set_auth(Rdioid::OAUTH_TOKEN_ENDPOINT, Rdioid.config.client_id, Rdioid.config.client_secret)
      end

      ##
      # Instance Methods
      #
      def api_request(access_token, body = {})
        header = {
          :Authorization => "Bearer #{access_token}"
        }

        request(Rdioid::API_ENDPOINT, :header => header, :body => body)
      end

      def request_device_code(options = {})
        body = {
          :client_id => Rdioid.config.client_id,
        }.merge(options)

        request(Rdioid::OAUTH_DEVICE_CODE_ENDPOINT, :body => body)
      end

      def request_token_with_authorization_code(code, options = {})
        body = {
          :grant_type => 'authorization_code',
          :code => code,
          :redirect_uri => Rdioid.config.redirect_uri
        }.merge(options)

        request(Rdioid::OAUTH_TOKEN_ENDPOINT, :body => body)
      end

      def request_token_with_client_credentials(options = {})
        body = {
          :grant_type => 'client_credentials'
        }.merge(options)

        request(Rdioid::OAUTH_TOKEN_ENDPOINT, :body => body)
      end

      def request_token_with_device_code(device_code, options = {})
        body = {
          :grant_type => 'device_code',
          :device_code => device_code
        }.merge(options)

        request(Rdioid::OAUTH_TOKEN_ENDPOINT, :body => body)
      end

      def request_token_with_password(username, password, options = {})
        body = {
            :grant_type => 'password',
            :username => username,
            :password => password
        }.merge(options)

        request(Rdioid::OAUTH_TOKEN_ENDPOINT, :body => body)
      end

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