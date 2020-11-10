# frozen_string_literal: true

require 'raven'

module Services
  class Log
    def self.error(message)
      p message
      Raven.capture_message(message)
    end
  end
end
