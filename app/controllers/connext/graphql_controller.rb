module Connext
  class GraphqlController < ApplicationController
    include GraphqlConcern

    protect_from_forgery with: :null_session
  
    def execute
      result = Connext::Schema.execute(
        params[:query],
        variables: ensure_hash(params[:variables]),
        operation_name: params[:operationName],
        context: { app_id: app_id, app_secret: app_secret },
      )
      render json: result
    end

    private

    def app_id
      request.headers['Connext-App-Id']
    end

    def app_secret
      request.headers['Connext-App-Secret']
    end
  end  
end