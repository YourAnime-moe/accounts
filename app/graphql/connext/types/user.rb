module Connext
  module Types
    class User < ::Types::BaseObject
      field :uuid, ID, null: false
      field :email, String, null: false
      field :username, String, null: false
      field :name, String, null: false
      field :first_name, String, null: false
      field :last_name, String, null: false
      field :color_hex, String, null: false
      field :type, String, null: false
      field :active, GraphQL::Types::Boolean, null: false
      field :blocked, GraphQL::Types::Boolean, null: false

      field :session, Connext::Types::Session, null: true
      field :profile_url, String, null: false

      def session
        @object.active_sessions.find_by(
          app_id: context[:application].uuid,
        )
      end
    end
  end
end
