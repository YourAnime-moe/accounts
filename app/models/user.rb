class User < ApplicationRecord
  before_validation :ensure_uuid
  before_validation :ensure_color_hex

  has_secure_password

  with_options presence: true do
    with_options uniqueness: { case_sensitive: true } do
      validates :uuid
      validates :username
    end
    validates :email
  end
  validates :email, format: Rails.configuration.email_regex, uniqueness: { case_sensitive: false }, if: :email?
  validates :color_hex, uniqueness: { scope: :uuid, case_sensitive: true }

  has_one_attached :avatar
  has_one_attached :banner

  has_many :access_grants,
           class_name: 'Doorkeeper::AccessGrant',
           foreign_key: :resource_owner_id,
           dependent: :destroy

  has_many :access_tokens,
           class_name: 'Doorkeeper::AccessToken',
           foreign_key: :resource_owner_id,
           dependent: :destroy

  def as_json(*)
    {
      id: id,
      uuid: uuid,
      first_name: first_name,
      last_name: last_name,
      name: name,
      username: username,
      email: email,
      image: profile_url,
      color_hex: color_hex,
      active: active,
      blocked: blocked,
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

  def type
    return self[:type] if self[:type].present?

    'User'
  end

  def valid_user?
    false
  end

  def admin?
    false
  end

  def profile_url
    if avatar.attached?
      avatar.variant(resize_to_limit: [300, 300]).service_url
    else
      "https://api.hello-avatar.com/adorables/300/#{username}.png"
    end
  rescue
    "https://api.hello-avatar.com/adorables/300/#{username}.png"
  end

  def self.make(type, *args, **kwargs)
    type = type.constantize if type.is_a?(String)
    raise ArgumentError, "Expected User-like type, got: #{type.class}" unless type < User

    result = type.new(*args, **kwargs)
    raise ArgumentError, "Expected valid user type, got: #{type.class}" unless result.valid_user?

    result
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
