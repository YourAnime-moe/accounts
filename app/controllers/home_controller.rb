class HomeController < ApplicationController
  before_action :redirect_back_to_app, only: :index

  def index
    if logged_in?
      set_title(before: 'Your Profile')
      render 'profile'
    else
      set_title(before: 'Login')
      render 'login'
    end
  end

  def lookup
    user = if params[:email].present?
      User.find_by(email: params[:email])
    end
    if user.present?
      set_email_hint(user.email)
    end
    render json: { found: user.present? }
  end

  def remove_email_hint
    delete_email_hint
    redirect_to(root_path(app_id: current_application&.uuid))
  end
end
