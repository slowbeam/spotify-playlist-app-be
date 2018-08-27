Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :songs, only: [:index]
      resources :users, only: [:index]
      resources :song_users, only: [:index]
      resources :login, only: [:index]
      get 'logging-in', :to => 'users#create'
    end
  end
end
