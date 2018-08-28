class Song < ApplicationRecord
  has_many :moods
  has_many :users, through: :moods
end
