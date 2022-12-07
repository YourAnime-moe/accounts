class UsersController < ApplicationController
  before_action :verify_valid_bot_request!, only: :check_links

  def check_links
    # TODO verify request coming from bot

    grant_name = params[:grant_name] # TODO validate if name exists!
    grant_user_id = params[:grant_user_id]

    respond_to do |format|
      format.json {
        render json: {
          uuid: User.find_by_grant(grant_name, grant_user_id)&.uuid
        }
      }
    end
  end

  private

  def verify_valid_bot_request!
  end
end
