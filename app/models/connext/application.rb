module Connext
  class Application < ApplicationRecord
    before_validation :ensure_uuid
    has_many :tokens, class_name: 'Connext::ApplicationToken'

    def securely_check_secret(secret)
      ActiveSupport::SecurityUtils.fixed_length_secure_compare(
        self.secret,
        secret,
      )
    end

    private

    def ensure_uuid
      return if self.persisted? || self[:uuid].present?

      self[:uuid] = SecureRandom.uuid
    end
  end
end
