module Rdioid
  class Config
    attr_accessor :client_id, :client_secret, :redirect_uri

    def initialize
      self.client_id = nil
      self.client_secret = nil
      self.redirect_uri = nil
    end
  end
end
