class ExternalOauthGrant < ApplicationRecord
  belongs_to :user

  scope :active, -> do
    where(is_not_deleted: true).where("expires_on > '#{DateTime.now.utc}'")
  end

  scope :expired, -> { where("expires_on <= '#{DateTime.now.utc}'") }

  REFRESH_WHEN_TIME_LEFT = 1.hour

  def refresh_if_necessary!
    return unless persisted?
    return if refresh_token.blank?

    return self unless about_to_expire?

    uri = URI::HTTPS.build(
      host: 'discord.com',
      path: '/api/v10/oauth2/token',
    )

    credentials = Rails.application.credentials.discord[Rails.env.to_sym]
    payload = {
      client_id: credentials[:client_id],
      client_secret: credentials[:client_secret],
      grant_type: 'refresh_token',
      refresh_token: refresh_token,
    }

    headers = {
      "Content-Type": "application/x-www-form-urlencoded",
    }

    response = RestClient.post(uri.to_s, payload, headers)
    data = JSON.parse(response)
    update(
      access_token: data['access_token'],
      expires_on: Time.current + data['expires_in'],
      refresh_token: data['refresh_token'],
      scope: data['scope'],
    )
    self
  end

  def revoke!
    return true if deleted?

    credentials = Rails.application.credentials.discord[Rails.env.to_sym]
    uri = URI::HTTPS.build(
      host: 'discord.com',
      path: '/api/oauth2/token/revoke',
    )

    payload = {
      token: refresh_token,
      token_type_hint: "refresh_token",
      client_id: credentials[:client_id],
      client_secret: credentials[:client_secret],
    }

    response = RestClient.post(
      uri.to_s,
      payload,
      {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Bearer #{access_token}"
      }
    )

    update(
      access_token: nil,
      refresh_token: nil,
      is_not_deleted: false,
    )
  end
  
  def deleted?
    !is_not_deleted?
  end

  def about_to_expire?
    return unless expires_on

    expires_on < REFRESH_WHEN_TIME_LEFT.from_now
  end

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
