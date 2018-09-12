class Song < ApplicationRecord
  has_many :moods
  has_many :users, through: :moods
  has_many :saved_playlists
  has_many :users, through: :saved_playlists
end
