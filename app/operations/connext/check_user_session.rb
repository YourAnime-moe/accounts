module Connext
  class CheckUserSession < ApplicationOperation
    property! :app_id, accepts: String
    property! :app_secret, accepts: String
    property! :auth_token, accepts: String

    def execute
      check_user_session!
    end

    private

    def check_user_session!
      application = fetch_application
      unless application.present?
        raise "Invalid application or secret: #{app_id}"
      end

      session = fetch_session
      unless session.present?
        raise "Invalid session: #{auth_token}"
      end

      session.correct_application?(application)
    end

    def fetch_application
      application = Connext::Application.find_by!(uuid: app_id)
      (application.securely_check_secret(app_secret) && application).presence
    rescue ArgumentError => e
      Rails.logger.error(e)
      nil
    end

    def fetch_session
      Users::Session.find_by(token: auth_token)
    end
  end
end
