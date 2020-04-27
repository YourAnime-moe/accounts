module Connext
  module Types
    class Session < ::Types::BaseObject
      field :user_id, Integer, null: false
      field :user_type, String, null: false
      field :token, String, null: false
      field :active, GraphQL::Types::Boolean, null: false
      field :expires_on, GraphQL::Types::ISO8601DateTime, null: false

      def active
        @object.active?
      end
    end
  end
end
