class AccountsController < ApplicationController
  include ActiveStorage::SetCurrent

  before_action :authenticated!, unless: :api_request?
  before_action :doorkeeper_authorize!, if: :api_request?

  def index
    respond_to do |format|
      format.html { set_title(before: 'Account details') }
      format.json {
        render json: current_resource_owner
      }
    end
  end

  def update
    if Users::Update.perform(user: current_user, **user_params)
      flash[:notice] = 'Your account was successfully updated.'
    else
      flash[:danger] = "We weren't able to update your account: #{current_user.errors_string}"
    end

    redirect_to(my_account_path)
  end

  private

  def api_request?
    #byebug
    request.format.json?
  end

  def user_params
    params.require(:user).permit(
      :email,
      :first_name,
      :last_name,
      :avatar,
    ).to_h.symbolize_keys
  end
end
