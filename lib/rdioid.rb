require "httpclient"
require "json"

require "rdioid/client"
require "rdioid/config"
require "rdioid/version"

module Rdioid
  AUTHORIZATION_URL = 'https://www.rdio.com/oauth2/authorize/'
  BASE_URL = 'https://services.rdio.com/'
  API_ENDPOINT = 'api/1/'
  OAUTH_TOKEN_ENDPOINT = 'oauth2/token/'
  OAUTH_DEVICE_CODE_ENDPOINT = 'oauth2/device/code/generate/'

  class << self
    attr_accessor :config
  end

  def self.configure
    self.config ||= Rdioid::Config.new
    yield(config)
  end
end
