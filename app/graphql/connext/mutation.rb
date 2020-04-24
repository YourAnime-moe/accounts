module Connext
  class Mutation < Types::BaseObject
    description 'The root Graphql API Mutation for Connext'

    field :create_session, String, null: true
    def create_session
      "Hello World"
    end
  end
end
