module Connext
  class Query < ::Types::BaseObject
    description 'The root Graphql API Query for Connext'

    field :session_for, GraphQL::Types::Boolean, null: true do
      argument :auth_token, ID, required: true
    end
    def session_for(auth_token:)
      Connext::CheckUserSession.perform(
        application: context[:application],
        auth_token: auth_token,
      )
    rescue => e
      Rails.logger.error("[Connext::Query] #{e}")
      nil
    end

    field :user_info, Connext::Types::User, null: true do
      argument :auth_token, String, required: true
    end
    def user_info(auth_token:)
      Users::Session.find_by(token: auth_token)&.user
    end
  end
end
