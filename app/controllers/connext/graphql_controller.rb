module Connext
  class GraphqlController < ApplicationController
    include GraphqlConcern

    protect_from_forgery with: :null_session
  
    def execute
      result = Connext::Schema.execute(
        params[:query],
        variables: ensure_hash(params[:variables]),
        operation_name: params[:operationName],
        context: { application: fetch_application },
      )
      render json: result
    end

    private

    def fetch_application
      application = Connext::Application.find_by!(uuid: app_id)
      (application.securely_check_secret(app_secret) && application).presence
    rescue ArgumentError => e
      Rails.logger.error(e)
      nil
    end

    def app_id
      request.headers['Connext-App-Id']
    end

    def app_secret
      request.headers['Connext-App-Secret']
    end
  end  
end