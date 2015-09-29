require 'spec_helper'

describe Rdioid::Client do
  let(:rdioid_client) { Rdioid::Client.new }
  let(:options) { { :scope => 'test_scope' } }

  before { set_config_values }

  describe '.authorization_url' do
    it 'includes the response type when escaping the query string' do
      expect(HTTP::Message).to receive(:escape_query).with(hash_including(:response_type => 'code'))

      Rdioid::Client.authorization_url
    end

    it 'overrides the response type with "options"' do
      url_options = { :response_type => 'token' }

      expect(HTTP::Message).to receive(:escape_query).with(hash_including(url_options))

      Rdioid::Client.authorization_url(url_options)
    end

    it 'adds additional "options" to the query string' do
      url_options = { :state => 'new_user' }

      expect(HTTP::Message).to receive(:escape_query).with(hash_including(url_options))

      Rdioid::Client.authorization_url(url_options)
    end

    it 'includes the client id when escaping the query string' do
      expect(HTTP::Message).to receive(:escape_query).with(hash_including(:client_id => Rdioid.config.client_id))

      Rdioid::Client.authorization_url
    end

    it 'includes the redirect uri when escaping the query string' do
      expect(HTTP::Message).to receive(:escape_query).with(hash_including(:redirect_uri => Rdioid.config.redirect_uri))

      Rdioid::Client.authorization_url
    end

    it 'returns an AUTHORIZATION_URL' do
      expect(Rdioid::Client.authorization_url).to start_with(Rdioid::AUTHORIZATION_URL)
    end

    it 'returns a query string appended to the url' do
      expect(Rdioid::Client.authorization_url).to match(/\?\w+/)
    end
  end

  describe '.new' do
    it 'initializes a new HTTPClient with Basic Auth' do
      http_client = HTTPClient.new(:base_url => Rdioid::BASE_URL, :force_basic_auth => true)

      expect(HTTPClient).to receive(:new).and_return(http_client)
      expect(http_client).to receive(:set_auth)

      Rdioid::Client.new
    end
  end

  describe '#api_request' do
    let(:access_token) { 'oauth_access_token' }

    it 'sends a request to API_ENDPOINT' do
      expect(rdioid_client).to receive(:request).with(Rdioid::API_ENDPOINT, anything)

      rdioid_client.api_request(access_token)
    end

    it 'includes authorization with access token in the header' do
      expect(rdioid_client).to receive(:request).with(
        anything,
        hash_including(:header => { :Authorization => "Bearer #{access_token}" })
      )

      rdioid_client.api_request(access_token)
    end

    it 'includes "body" arg in the body' do
      body = { :method => 'getAlbumsInCollection', :extras => '-*,name' }

      expect(rdioid_client).to receive(:request).with(
        anything,
        hash_including(:body => body)
      )

      rdioid_client.api_request(access_token, body)
    end
  end

  describe '#request_device_code' do
    it 'sends a request to OAUTH_DEVICE_CODE_ENDPOINT' do
      expect(rdioid_client).to receive(:request).with(Rdioid::OAUTH_DEVICE_CODE_ENDPOINT, anything)

      rdioid_client.request_device_code
    end

    it 'includes the client id in the body' do
      expect(rdioid_client).to receive(:request).with(
        anything,
        :body => hash_including(:client_id => Rdioid.config.client_id)
      )

      rdioid_client.request_device_code
    end

    it 'adds additional "options" to the body' do
      expect(rdioid_client).to receive(:request).with(
        anything,
        :body => hash_including(options)
      )

      rdioid_client.request_device_code(options)
    end
  end

  describe '#request_token_with_authorization_code' do
    let(:code) { 'oauth_code' }

    it 'sends a request to OAUTH_TOKEN_ENDPOINT' do
      expect(rdioid_client).to receive(:request).with(Rdioid::OAUTH_TOKEN_ENDPOINT, anything)

      rdioid_client.request_token_with_authorization_code(code)
    end

    it 'includes the correct grant type in the body' do
      expect(rdioid_client).to receive(:request).with(
        anything,
        :body => hash_including(:grant_type => 'authorization_code')
      )

      rdioid_client.request_token_with_authorization_code(code)
    end

    it 'includes the oauth code in the body' do
      expect(rdioid_client).to receive(:request).with(
        anything,
        :body => hash_including(:code => code)
      )

      rdioid_client.request_token_with_authorization_code(code)
    end

    it 'includes the redirect uri in the body' do
      expect(rdioid_client).to receive(:request).with(
        anything,
        :body => hash_including(:redirect_uri => Rdioid.config.redirect_uri)
      )

      rdioid_client.request_token_with_authorization_code(code)
    end

    it 'adds additional "options" to the body' do
      expect(rdioid_client).to receive(:request).with(
        anything,
        :body => hash_including(options)
      )

      rdioid_client.request_token_with_authorization_code(code, options)
    end
  end

  describe '#request_token_with_client_credentials' do
    it 'sends a request to OAUTH_TOKEN_ENDPOINT' do
      expect(rdioid_client).to receive(:request).with(Rdioid::OAUTH_TOKEN_ENDPOINT, anything)

      rdioid_client.request_token_with_client_credentials
    end

    it 'includes the correct grant type in the body' do
      expect(rdioid_client).to receive(:request).with(
        anything,
        :body => hash_including(:grant_type => 'client_credentials')
      )

      rdioid_client.request_token_with_client_credentials
    end

    it 'adds additional "options" to the body' do
      expect(rdioid_client).to receive(:request).with(
        anything,
        :body => hash_including(options)
      )

      rdioid_client.request_token_with_client_credentials(options)
    end
  end

  describe '#request_token_with_device_code' do
    let(:device_code) { 'requested_device_code' }

    it 'sends a request to OAUTH_TOKEN_ENDPOINT' do
      expect(rdioid_client).to receive(:request).with(Rdioid::OAUTH_TOKEN_ENDPOINT, anything)

      rdioid_client.request_token_with_device_code(device_code)
    end

    it 'includes the correct grant type in the body' do
      expect(rdioid_client).to receive(:request).with(
        anything,
        :body => hash_including(:grant_type => 'device_code')
      )

      rdioid_client.request_token_with_device_code(device_code)
    end

    it 'includes the device code in the body' do
      expect(rdioid_client).to receive(:request).with(
        anything,
        :body => hash_including(:device_code => device_code)
      )

      rdioid_client.request_token_with_device_code(device_code)
    end

    it 'adds additional "options" to the body' do
      expect(rdioid_client).to receive(:request).with(
        anything,
        :body => hash_including(options)
      )

      rdioid_client.request_token_with_device_code(device_code, options)
    end
  end

  describe '#request_token_with_password' do
    let(:username) { 'rdio_username' }
    let(:password) { 'rdio_password' }

    it 'sends a request to OAUTH_TOKEN_ENDPOINT' do
      expect(rdioid_client).to receive(:request).with(Rdioid::OAUTH_TOKEN_ENDPOINT, anything)

      rdioid_client.request_token_with_password(username, password)
    end

    it 'includes the correct grant type in the body' do
      expect(rdioid_client).to receive(:request).with(
        anything,
        :body => hash_including(:grant_type => 'password')
      )

      rdioid_client.request_token_with_password(username, password)
    end

    it 'includes the username in the body' do
      expect(rdioid_client).to receive(:request).with(
        anything,
        :body => hash_including(:username => username)
      )

      rdioid_client.request_token_with_password(username, password)
    end

    it 'includes the password in the body' do
      expect(rdioid_client).to receive(:request).with(
        anything,
        :body => hash_including(:password => password)
      )

      rdioid_client.request_token_with_password(username, password)
    end

    it 'adds additional "options" to the body' do
      expect(rdioid_client).to receive(:request).with(
        anything,
        :body => hash_including(options)
      )

      rdioid_client.request_token_with_password(username, password, options)
    end
  end

  describe '#request_token_with_refresh_token' do
    let(:refresh_token) { 'access_refresh_token' }

    it 'sends a request to OAUTH_TOKEN_ENDPOINT' do
      expect(rdioid_client).to receive(:request).with(Rdioid::OAUTH_TOKEN_ENDPOINT, anything)

      rdioid_client.request_token_with_refresh_token(refresh_token)
    end

    it 'includes the correct grant type in the body' do
      expect(rdioid_client).to receive(:request).with(
        anything,
        :body => hash_including(:grant_type => 'refresh_token')
      )

      rdioid_client.request_token_with_refresh_token(refresh_token)
    end

    it 'includes the device code in the body' do
      expect(rdioid_client).to receive(:request).with(
        anything,
        :body => hash_including(:refresh_token => refresh_token)
      )

      rdioid_client.request_token_with_refresh_token(refresh_token)
    end

    it 'adds additional "options" to the body' do
      expect(rdioid_client).to receive(:request).with(
        anything,
        :body => hash_including(options)
      )

      rdioid_client.request_token_with_refresh_token(refresh_token, options)
    end
  end
end
