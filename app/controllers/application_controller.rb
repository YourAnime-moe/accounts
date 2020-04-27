class ApplicationController < ActionController::Base
  include ApplicationHelper
  include AuthenticationHelper

  protected

  def redirect_to_url
    params[:next].present? ? params[:next] : root_path
  end

  def redirect_back_to_app
    return unless current_application.present? && current_user.present?

    token = current_application.tokens.create!(
      refresh_token: SecureRandom.hex(32),
      expires_in: 1.week.from_now,
    )
    uri = Pathname.new(current_application.redirect_uri).join(
      "auth?refresh_token=#{token.refresh_token}&user_id=#{current_user.uuid}"
    ).to_s
    redirect_to(uri)
  end
end
