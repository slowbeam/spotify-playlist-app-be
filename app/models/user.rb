class User < ApplicationRecord
  has_many :moods
  has_many :songs, through: :moods
end
