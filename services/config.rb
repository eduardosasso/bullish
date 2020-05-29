# frozen_string_literal: true

require 'dotenv/load'

module Services
  class Config
    def self.futures_api_uri
      URI(ENV['MARKET_API'])
    end
  end
end
