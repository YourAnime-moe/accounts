class ApplicationController < ActionController::Base
  include ApplicationHelper
  include AuthenticationHelper

  after_action :allow_iframes

  before_action :redirect_to_oauth_flow_if_logged_in!

  def new_account
    @user = RegularUser.new(active: false, blocked: false)
  end

  def signup
    @user = RegularUser.new(signup_params)
    if @user.valid?
      @user.save!
      set_email_hint(@user.email, true)
      flash[:notice] = 'Welcome. Your account has been created!'
    else
      flash[:danger] = "Uh oh... #{@user.errors_string}"
    end
    redirect_to(root_path(app_id: current_application&.uuid))
  end

  def cancel_oauth_request
    session.delete(:redirect_to)

    redirect_to(root_path)
  end

  def login
    if logged_in? && params[:uno].present?
      if requested_account == current_user
        redirect_to(root_path)
      else
        @from_picker = true
        render 'home/login'
      end
    elsif logged_in?
      render 'account_picker'
    elsif params[:uno].present?
      set_email_hint(requested_account.email, false)
      @from_picker = true
      render 'home/login'
    end
  end

  def account_picker
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

  def redirect_to_oauth_flow_if_logged_in!
    return unless logged_in?

    if session[:redirect_to].present?
      redirect_to_url = session[:redirect_to]
      session.delete(:redirect_to)

      redirect_to(redirect_to_url)
    end
  end

  private

  def allow_iframes
    response.headers.except! 'X-Frame-Options'
  end

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
