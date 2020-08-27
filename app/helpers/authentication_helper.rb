module AuthenticationHelper
  def account_from_email_hint
    return if logged_in?

    @account_from_email_hint ||= User.find_by(email: session[:email_hint])
  end

  def show_account_hint
    return unless account_from_email_hint.present?

    session[:show_email] ? session[:email_hint] : account_from_email_hint.username
  end

  def set_email_hint(email, show_email)
    session[:show_email] = show_email
    session[:email_hint] = email
  end

  def delete_email_hint
    session.delete(:email_hint)
    session.delete(:show_email)
    @account_from_email_hint = nil
  end

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  def current_user
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

  def requested_account_number
    return 0 unless params[:uno].present?

    # uno = User Number, defaults to 0 unless valid
    uno = params[:uno].to_i
    return uno if session[:user_info].blank?

    uno > session[:user_info].length ? 0 : uno
  end

  def requested_account
    return unless params[:uno].present?

    saved_accounts[requested_account_number]
  end

  def logged_in?
    current_user.present?
  end

  def log_in(user, app_id=nil, session_expiry:)
    return if logged_in?
    raise('This user is invalid') unless user.valid?

    user.sessions.create!(expires_on: session_expiry, app_id: app_id)
    add_account_to_session(user)
    Rails.logger.info "User #{user.name} is now logged in"
  end

  def log_out
    current_user&.delete_all_auth_token!
    clean_session
    delete_email_hint
  end

  def authenticated!
    return unless api_request?

    current_user.sessions.create(
      expires_on: Rails.configuration.x.access_token_expires_in
    ) if logged_in? && current_user.auth_token.nil?

    return if logged_in?

    redirect_to_current_path_in_mind
  end

  def saved_accounts
    return [] if session[:saved_accounts].blank? || session[:user_info]

    currently_logged_in_accounts + not_logged_in_accounts
  end

  private

  def currently_logged_in_accounts
    saved_auth_tokens.map(&:user)
  end

  def not_logged_in_accounts
    (session[:saved_accounts] || []).map { |user_id| User.find_by(id: user_id) }.compact
  end

  def saved_auth_tokens
    session_user_info.map { |user_info| Users::Session.find_by(token: user_info[:auth_token]) }.compact
  end

  def session_user_info
    return [] unless session[:user_info].present?

    session[:user_info].map{ |user_info| user_info.with_indifferent_access }
  end

  def add_account_to_session(user)
    if session[:user_info].blank?
      session[:user_info] = []
    end
    session[:user_info].push({
      uuid: user.uuid,
      auth_token: user.auth_token,
    })
  end

  def current_account_id
    session[:account_id] ||= requested_account_number
  end

  def current_auth_token
    return if session[:user_info].blank?

    token_info = session_user_info[current_account_id] || session_user_info[0]
    token_info[:auth_token]
  end

  def check_and_set_auth_token(current_auth_token)
    current_session = Users::Session.find_by(token: current_auth_token)
    return nil unless current_session.present?

    # This logic will log everyone out if one session is expired.... not good
    if current_session.expired?
      clean_session
      current_session = nil
    else
      session[:auth_token] = current_auth_token
    end
    current_session
  end

  def clean_session
    session[:saved_accounts] = saved_accounts.map(&:id)

    session.delete(:auth_token)
    session.delete(:user_info)
  end

  def redirect_to_current_path_in_mind
    next_url = NextLinkFinder.perform(path: request.fullpath)
    redirect_to(root_path(next: CGI.escape(next_url)))
  end
end
