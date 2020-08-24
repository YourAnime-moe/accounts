module Users
  class Lookup < ApplicationOperation
    property! :username_or_email, accepts: String

    def execute
      lookup_user
    end

    private

    def lookup_user
      User.where(
        username: username_or_email.downcase
      ).or(User.where(
        email: username_or_email.downcase
      )).first
    end
  end
end
