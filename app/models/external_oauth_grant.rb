class ExternalOauthGrant < ApplicationRecord
  belongs_to :user

  scope :active, -> do
    where(is_not_deleted: true).where("expires_on > '#{DateTime.now.utc}'")
  end

  scope :expired, -> { where("expires_on <= '#{DateTime.now.utc}'") }

  def as_json(*)
    {
      grant_name: grant_name,
      grant_user_id: grant_user_id,
      grant_type: grant_type,
      access_token: access_token,
      refresh_token: refresh_token,
      expires_on: expires_on,
    }
  end
end
