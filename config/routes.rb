Rails.application.routes.draw do
  root 'home#index'
  post '/lookup' => 'home#lookup'
  post '/login' => 'sessions#create'
  delete '/logout' => 'sessions#delete'
  post '/change_email' => 'home#remove_email_hint'
end
