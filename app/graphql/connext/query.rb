module Connext
  class Query < Types::BaseObject
    description 'The root Graphql API Query for Connext'

    field :session_for, GraphQL::Types::Boolean, null: true do
      argument :auth_token, ID, required: true
    end
    def session_for(auth_token:)
      Connext::CheckUserSession.perform(
        app_id: context[:app_id],
        app_secret: context[:app_secret],
        auth_token: auth_token,
      )
    rescue => e
      Rails.logger.error("[Connext::Query] #{e}")
      nil
    end
  end
end
