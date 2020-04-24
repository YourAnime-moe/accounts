Rails.application.routes.draw do
  root 'home#index'
  post '/lookup' => 'home#lookup'
  post '/login' => 'sessions#create'
  delete '/logout' => 'sessions#delete'
  post '/change_email' => 'home#remove_email_hint'

  post "/graphql", to: "graphql#execute"

  namespace :admin do
    if Rails.env.development?
      mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
    end
  end
end
