module Users
  class Authenticate < ApplicationOperation
    input :username, accepts: String, type: :keyword, required: true
    input :password, accepts: String, type: :keyword, required: true
    #input :fingerprint, type: :keyword, required: true
    #input :maintenance, type: :keyword, required: false

    before do
      raise Error.new('welcome.login.errors.no-credentials') if username.blank? && password.blank?
      raise Error.new('welcome.login.errors.no-username') if username.blank?
      raise Error.new('welcome.login.errors.no-password') if password.blank?
      #raise Error.new('fingerprint.missing') if fingerprint.blank?
    end

    def execute
      check_user_unknown!
      check_wrong_password!
      #check_if_maintenance_and_not_admin_user!
      check_user_allowed_to_login!

      #activate_session!
      user
    end

    succeeded do
      #Config.slack_client&.chat_postMessage(
      #  channel: '#sign-ins',
      #  text: "[SIGN IN] User #{output.username}-#{output.id} at #{Time.zone.now}!"
      #)
      Rails.logger.info("[SIGN IN] User #{output.username}-#{output.id} at #{Time.zone.now}!")
    end

    class Error < StandardError
      def initialize(i18n_key, *args, **options)
        super(I18n.t(i18n_key, *args, **options))
      end
    end

    private

    def user
      @user ||= User.where(
        username: username.downcase
      ).or(User.where(
        email: username.downcase
      )).first
    end

    def check_user_unknown!
      raise Error.new('welcome.login.errors.unknown-user', attempt: username) if user.nil?
    end

    def check_wrong_password!
      raise Error.new('welcome.login.errors.wrong-password', user: username) unless user.authenticate(password)
    end

    def check_if_maintenance_and_not_admin_user!
      raise Error.new('welcome.login.errors.maintenance') if maintenance && !user.admin?
    end

    def check_user_allowed_to_login!
      raise Error.new('welcome.login.errors.not_allowed_to_login') unless user.valid_user?
    end

    def activate_session!
      items = fingerprint[:items]
      fprint = fingerprint[:print]

      device_id = fprint
      device_name = items["0"]["value"]
      device_location = items["1"]["value"]
      device_os = items["2"]["value"]

      device_unknown = [device_id, device_name, device_location, device_os].compact.empty?
      user.sessions.create!(
        active_until: 1.week.from_now,
        device_id: device_id,
        device_name: device_name,
        device_location: device_location,
        device_os: device_os,
        device_unknown: device_unknown
      )
      user
    end
  end
end
