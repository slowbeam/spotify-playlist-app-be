Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :songs, only: [:index]
      resources :users, only: [:index]
      resources :song_users, only: [:index]
      resources :login, only: [:index]
      resources :genres, only: [:index]
      resources :moods, only: [:index]
      get 'logging-in', :to => 'users#create'
      get 'load-genres', :to => 'genres#create'
      get 'search', :to => 'spotify#search'
      get 'create-playlist', :to => 'spotify#create_playlist'
      get 'logout', :to => "users#logout"
      get 'logged-in-user', :to => "users#logged_in_user"
    end
  end
end
