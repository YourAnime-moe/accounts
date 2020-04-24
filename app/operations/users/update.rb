module Users
  class Update < ApplicationOperation
    attr_reader :update_error

    property! :user, accepts: User
    property :email, accepts: String
    property :username, accepts: String
    property :first_name, accepts: String
    property :last_name, accepts: String

    def execute
      update_user
    end

    private

    def update_user
      set_attributes
      notify_changes

      user.save
    end

    def set_attributes
      user.assign_attributes(
        email: email,
        username: username,
        first_name: first_name,
        last_name: last_name,
      )
    end

    def notify_changes
      return unless user.changed?

      Rails.logger.info("User##{user.id} has changed their attributes: #{user.changed_attributes}")
    end
  end
end
