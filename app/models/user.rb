class User < ApplicationRecord
  EMAIL_REGEX = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

  before_validation :ensure_uuid
  before_validation :ensure_color_hex

  has_secure_password

  with_options presence: true do
    validates :uuid, uniqueness: true
    validates :email
  end

  validates :email, format: EMAIL_REGEX, uniqueness: true, if: :email?
  validates :color_hex, uniqueness: { scope: :uuid }

  def as_json(*)
    {
      id: id,
      first_name: first_name,
      last_name: last_name,
      name: name,
      username: username,
      email: email,
    }
  end

  def name
    "#{first_name} #{last_name}"
  end

  def sessions
    @sessions ||= Users::Session.unscoped.where(user_id: id, user_type: type)
  end

  def active_sessions
    sessions.active.order('created_at desc')
  end

  def current_token
    active_sessions.first
  end

  def auth_token
    @auth_token ||= current_token&.token
  end

  def delete_auth_token!
    current_token&.delete!
  end

  def delete_all_auth_token!
    active_sessions.each { |session| session.delete! }
  end

  private

  def ensure_uuid
    self[:uuid] = SecureRandom.uuid unless self.persisted?
  end

  def ensure_color_hex
    return if color_hex && color_hex != self.class.new.color_hex
    return unless username.present?

    hash_code = 0
    username.each_char do |char|
      hash_code = char.ord + ((hash_code << 5) - hash_code)
    end

    code = hash_code & 0x00FFFFFF
    code = code.to_s(16).upcase

    self[:color_hex] = '00000'[0, 6 - code.size] + code
  end
end
