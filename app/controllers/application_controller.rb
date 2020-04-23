class ApplicationController < ActionController::Base
  include ApplicationHelper
  include AuthenticationHelper

  protected

  def redirect_to_url
    params[:next].present? ? params[:next] : root_path
  end
end
