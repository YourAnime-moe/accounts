class SessionsController < ApplicationController
  rescue_from(Users::Authenticate::Error, with: :invalid_login_info)

  def create
    user = Users::Authenticate.perform(
      username: account_from_email_hint.email,
      password: login_params[:password].strip,
    )
    go_to = if current_application.present?
      log_in_with_app(user, current_application)
      token = current_application.tokens.create!(
        refresh_token: SecureRandom.hex(32),
        expires_in: 1.week.from_now,
      )
      Pathname.new(current_application.redirect_uri).join(
        "auth?refresh_token=#{token.refresh_token}&user_id=#{user.uuid}"
      ).to_s
    else
      log_in(user)
      redirect_to_url
    end
    respond_to do |format|
      format.json do
        render json: { success: current_user.present?, redirect_to: go_to }, status: 200
      end
    end
  rescue Users::Authenticate::Error => e
    Rails.logger.error(e)
    raise e
  end

  def delete
    log_out

    redirect_to root_path
  end

  def delete_for_app
    Users::Session.active.where(app_id: current_application.uuid).each do |session|
      session.delete!
    end
    redirect_to current_application.redirect_uri
  end

  private

  def invalid_login_info(error)
    respond_to do |format|
      format.json do
        render json: { success: false, message: error.message }, status: 401
      end
    end
  end

  def login_params
    params.require(:sessions).permit(
      :password,
    )
  end
end
