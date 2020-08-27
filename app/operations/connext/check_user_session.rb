module Connext
  class CheckUserSession < ApplicationOperation
    property! :application, accepts: Connext::Application
    property! :auth_token, accepts: String

    def execute
      check_user_session!
    end

    private

    def check_user_session!
      session = Users::Session.active.find_by(token: auth_token)
      unless session.present?
        raise "Invalid session: #{auth_token}"
      end

      #session.correct_application?(application)
    end
  end
end
