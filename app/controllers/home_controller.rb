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
      Users::Lookup.perform(username_or_email: params[:email])
    end
    uses_email = user.email == params[:email]

    redirect_url = if user.present?
      set_email_hint(user.email, uses_email)
      root_path(next: params[:next])
    end
    render json: { found: user.present?, redirect_url: redirect_url }
  end

  def remove_email_hint
    delete_email_hint
    redirect_to(root_path(next: params[:next]))
  end
end
