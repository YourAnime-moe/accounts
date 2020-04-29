class ApplicationController < ActionController::Base
  include ApplicationHelper
  include AuthenticationHelper

  def new_account
    @user = RegularUser.new(active: false, blocked: false)
  end

  def signup
    @user = RegularUser.new(signup_params)
    if @user.valid?
      @user.save!
      set_email_hint(@user.email)
      flash[:notice] = 'Welcome. Your account has been created!'
    else
      flash[:danger] = "Uh oh... #{@user.errors_string}"
    end
    redirect_to(root_path(app_id: current_application&.uuid))
  end

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

  private

  def signup_params
    params.require(:user).permit(
      :username,
      :email,
      :first_name,
      :last_name,
      :password,
    )
  end
end
