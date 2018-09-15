class Mood < ApplicationRecord
  default_scope { order('id ASC') }
  belongs_to :user
  belongs_to :song
end
