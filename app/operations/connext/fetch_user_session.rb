module Connext
  class FetchUserSession < ApplicationOperation
    property! :application, accepts: Connext::Application
    property! :user_id, accepts: String
    property! :refresh_token, accepts: String

    def execute
      fetch_user_session!
    end

    private

    def fetch_user_session!
      token = application.tokens.find_by(refresh_token: refresh_token)
      unless token.present?
        raise "Invalid refresh token: #{refresh_token}"
      end

      user = fetch_user
      unless user.present?
        raise "Invalid user: #{user_id}"
      end

      user.active_sessions.first&.token
    end

    def fetch_user
      User.find_by(uuid: user_id)
    end
  end
end
