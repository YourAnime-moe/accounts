class SessionsController < ApplicationController
  rescue_from(Users::Authenticate::Error, with: :invalid_login_info)

  def create
    user = Users::Authenticate.perform(
      username: account_from_email_hint.email,
      password: login_params[:password].strip,
    )
    log_in(user)

    respond_to do |format|
      format.json do
        render json: { success: current_user.present?, redirect_to: redirect_to_url }, status: 200
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
