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
      get 'search', :to => 'spotify#search'
      get 'create-playlist', :to => 'spotify#create_playlist'
      post 'create-playlist-two', :to => 'spotify#create_playlist_two'
      get 'logout', :to => "users#logout"
      post 'logged-in-user', :to => "users#logged_in_user"
      get 'search', :to => 'spotify#search'
    end
  end
end
