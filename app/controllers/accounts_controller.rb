class AccountsController < ApplicationController
  def index
    set_title(before: 'Account details')
  end

  def new
    @user = RegularUser.new(active: false, blocked: false)
  end

  def create
    @user = RegularUser.new(signup_params)
    if @user.valid?
      @user.save!
      set_email_hint(@user.email)
      flash[:notice] = 'Welcome. Your account has been created!'
    else
      flash[:danger] = "Uh oh... #{@user.errors_string}"
    end
    redirect_to(root_path)
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

  def user_params
    params.require(:user).permit(
      :username,
      :email,
      :first_name,
      :last_name,
    ).to_h.symbolize_keys
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
