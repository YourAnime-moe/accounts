Rails.application.routes.draw do
  use_doorkeeper
  root 'home#index'
  post '/lookup' => 'home#lookup'
  get '/signup' => 'application#new_account'
  post '/signup' => 'application#signup'
  post '/login' => 'sessions#create'
  get '/logout/:app_id' => 'sessions#delete_for_app'
  delete '/logout' => 'sessions#delete'
  post '/change_email' => 'home#remove_email_hint'

  get '/oauth/cancel' => 'application#cancel_oauth_request'
  get '/login' => 'application#login'
  get '/pick' => 'application#account_picker'

  scope :me do
    get '/', to: 'accounts#index', as: :my_account
    patch '/', to: 'accounts#update'
  end

  # namespace :connext do
  #   post "/graphql", to: "graphql#execute"

  #   if Rails.env.development?
  #     mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/connext/graphql"
  #   end
  # end
end
