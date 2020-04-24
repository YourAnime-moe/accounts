class AuthenticatedController < ApplicationController
  include AuthenticationHelper

  before_action :authenticated!
end
