module Connext
  class Mutation < ::Types::BaseObject
    description 'The root Graphql API Mutation for Connext'

    field :fetch_session, String, null: true do
      argument :user_id, String, required: true
      argument :refresh_token, String, required: true
    end
    def fetch_session(user_id:, refresh_token:)
      result = Connext::FetchUserSession.perform(
        application: context[:application],
        user_id: user_id,
        refresh_token: refresh_token,
      )
      result
    rescue => e
      Rails.logger.error("[Connext::Mutation] #{e}")
      nil
    end

    field :logout, GraphQL::Types::Boolean, null: false do
      argument :user_id, String, required: true
    end
    def logout(user_id:)
      user = User.find_by!(user_id)
      user.delete_all_auth_token!
      true
    rescue => e
      Rails.logger.error("[Connext::Mutation] #{e}")
      false
    end
  end
end
