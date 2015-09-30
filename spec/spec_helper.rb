require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rdioid'

def set_config_values
  Rdioid.configure do |config|
    config.client_id = 'test_id'
    config.client_secret = 'test_secrest'
    config.redirect_uri = 'http://test_redirect_uri/'
  end
end
