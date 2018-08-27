Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :songs, only: [:index]
      resources :users, only: [:index]
      resources :song_users, only: [:index]
      
    end
  end
end
