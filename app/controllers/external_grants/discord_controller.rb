module ExternalGrants
  class DiscordController < ApplicationController
    def new
      query = {
        client_id: credentials[:client_id],
        redirect_uri: credentials[:redirect_uri],
        scope: ['identify'].join(' '),
        response_type: "code",
      }

      uri = URI::HTTPS.build(
        host: 'discord.com',
        path: '/api/oauth2/authorize',
        query: query.to_query,
      )

      redirect_to(uri.to_s)
    end

    def create
      payload = {
        code: params[:code],
        client_id: credentials[:client_id],
        client_secret: credentials[:client_secret],
        grant_type: "authorization_code",
        redirect_uri: credentials[:redirect_uri],
      }

      uri = URI::HTTPS.build(
        host: 'discord.com',
        path: '/api/v10/oauth2/token'
      )
      response = RestClient.post(uri.to_s, payload, {"Content-Type": "application/x-www-form-urlencoded"})
      data = JSON.parse(response)

      access_token = data['access_token']
      expires_on = Time.current + data['expires_in']

      uri = URI::HTTPS.build(
        host: 'discord.com',
        path: '/api/v10/oauth2/@me',
      )
      token_introspection_response = RestClient.get(uri.to_s, {"Authorization": "Bearer #{access_token}"})
      token_introspection = JSON.parse(token_introspection_response)
      user = token_introspection["user"]

      external_oauth_grant = current_user.external_oauth_grants.find_or_initialize_by(
        grant_name: "discord",
        grant_user_id: user["id"],
      )

      external_oauth_grant.assign_attributes(
        access_token: access_token,
        refresh_token: data['refresh_token'],
        expires_on: expires_on,
        scope: data['scope'],
        grant_type: payload[:grant_type],
      )

      if external_oauth_grant.save
        redirect_to(oauth_authorized_applications_path)
      else
        render(json: external_oauth_grant.errors.to_a)
      end
    end

    def delete
      external_oauth_grant = ExternalOauthGrant.where(user: current_user).find_by(id: params[:id])
      if external_oauth_grant
        external_oauth_grant.revoke!
      end

      redirect_to(oauth_authorized_applications_path)
    end

    private

    def credentials
      Rails.application.credentials.discord[Rails.env.to_sym]
    end
  end
end
