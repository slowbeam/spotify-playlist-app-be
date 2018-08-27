class Api::V1::SpotifyController < ApplicationController
  before_action :set_user, only: [:recommendation]

  def recommendation

  end

  private

  def set_user
    @@current_user = User.find(ENV["CURRENT_USER_ID"].to_i)
  end
end
