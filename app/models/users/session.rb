module Users
  class Session < ApplicationRecord
    include IsSoftDeletable

    before_destroy :prevent_destroy!
    before_validation :ensure_token

    validate :user_present
    validates :token, presence: true, uniqueness: { case_sensitive: true }
    validates :expires_on, presence: true

    scope :active, -> { where(is_not_deleted: true).where("expires_on > '#{DateTime.now.utc}'") }
    scope :expired, -> { where("expires_on <= '#{DateTime.now.utc}'") }

    class InactiveError < StandardError; end

    def user
      User.find_by(id: user_id)
    end

    def user=(user)
      self.user_type = user.type
      self.user_id = user.id
      user
    end

    def expires?
      expires_on.present?
    end

    def expired?
      (expires_on.presence && expires_on <= Time.now.utc) || !is_not_deleted?
    end

    def delete!
      return if expired?

      User.transaction do
        update!(
          is_not_deleted: false,
          deleted_on: Time.now.utc,
          expires_on: Time.now.utc
        )
      end
    end

    private

    def prevent_destroy!
      throw :abort
    end

    def ensure_token
      return if self.token.present?

      self.token = generate_token
      until self.class.default_scoped.where(token: self.token)
        self.token = generate_token
      end
    end

    def generate_token
      SecureRandom.hex
    end

    def user_present
      unless user.present?
        errors.add(:user, 'is missing')
      end
    end
  end
end
