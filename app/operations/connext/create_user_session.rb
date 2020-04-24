module Connext
  class CreateUserSession < ApplicationOperation
    property! :app_id, accepts: String
    property! :app_secret, accepts: String
    property! :user_id, accepts: String

    def execute
      create_user_session!
    end

    private

    def create_user_session!
      application = fetch_application
      unless application.present?
        raise "Invalid application or secret: #{app_id}"
      end

      user = fetch_user
      unless user.present?
        raise "Invalid user: #{auth_token}"
      end

      user.active_sessions.create(
        expires_on: 1.week.from_now,
        app_id: app_id,
      ).persisted?
    end

    def fetch_application
      application = Connext::Application.find_by!(uuid: app_id)
      (application.securely_check_secret(app_secret) && application).presence
    rescue ArgumentError => e
      Rails.logger.error(e)
      nil
    end

    def fetch_user
      User.find_by(uuid: user_id)
    end
  end
end
