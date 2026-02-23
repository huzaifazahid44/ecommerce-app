# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :session

    def connect
      self.session = find_verified_session
    end

    private

    # Expose the session hash in ActionCable
    def find_verified_session
      env["rack.session"] || {}
    end
  end
end
