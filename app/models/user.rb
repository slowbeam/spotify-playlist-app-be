class User < ApplicationRecord
  has_many :moods
  has_many :songs, through: :moods

  def access_token_expired?
    (Time.now - self.updated_at) > 3300
  end
  
end
