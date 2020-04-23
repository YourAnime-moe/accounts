module AuthenticationHelper
  def account_from_email_hint
    return if logged_in?

    @account_from_email_hint ||= User.find_by(email: session[:email_hint])
  end

  def set_email_hint(email)
    session[:email_hint] = email
  end

  def delete_email_hint
    session.delete(:email_hint)
    @account_from_email_hint = nil
  end

  def current_user
    current_auth_token = session[:auth_token]
    return nil unless current_auth_token.present?

    if @current_user.present?
      return @current_user unless @current_user.current_token.expired?

      Rails.logger.warn("#{@current_user.name}'s token has expired")
      log_out
      @current_user = nil
    else
      current_session = check_and_set_auth_token(current_auth_token)
      @current_user = current_session&.user
    end
  end

  def logged_in?
    current_user.present? && current_user.active?
  end

  def log_in(user, session_expiry: 1.week.from_now)
    return if logged_in?
    raise('This user is invalid') unless user.valid?

    user.sessions.create!(expires_on: session_expiry)
    session[:auth_token] = user.auth_token
    Rails.logger.info "User #{user.name} is now logged in"
  end

  def log_out
    current_user&.delete_auth_token!
    clean_session
    delete_email_hint
  end

  private

  def check_and_set_auth_token(current_auth_token)
    current_session = Users::Session.find_by(token: current_auth_token)
    return nil unless current_session.present?

    if current_session.expired?
      clean_session
      current_session = nil
    else
      session[:auth_token] = current_auth_token
    end
    current_session
  end

  def clean_session
    session.delete(:auth_token)
  end
end