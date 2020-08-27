class SessionsController < ApplicationController
  rescue_from(Users::Authenticate::Error, with: :invalid_login_info)

  def create
    user = Users::Authenticate.perform(
      username: account_from_email_hint.email,
      password: login_params[:password].strip,
    )
    log_in(user, session_expiry: Rails.configuration.x.access_token_expires_in.from_now)
    next_path = params[:next].present? ? CGI.unescape(params[:next]) : root_path

    respond_to do |format|
      format.json do
        render json: { success: current_user.present?, redirect_to: next_path }, status: (current_user.present? ? 200 : 401)
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
