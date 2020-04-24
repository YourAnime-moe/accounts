Rails.application.routes.draw do
  root 'home#index'
  post '/lookup' => 'home#lookup'
  post '/login' => 'sessions#create'
  delete '/logout' => 'sessions#delete'
  post '/change_email' => 'home#remove_email_hint'

  scope :me do
    get '/', to: 'accounts#index', as: :my_account
    patch '/', to: 'accounts#update'
  end

  namespace :connext do
    post "/graphql", to: "graphql#execute"

    if Rails.env.development?
      mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/connext/graphql"
    end
  end
end
