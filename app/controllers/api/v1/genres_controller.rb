class Api::V1::GenresController < ApplicationController
  before_action :set_user, only: [:create]

  def index
    @genres = Genre.all
    render json: @genres
  end

  def create

    url = 'https://api.spotify.com/v1/recommendations/available-genre-seeds'

    header = {
      Authorization: "Bearer #{@@current_user["access_token"]}"
    }

    genre_seed_response = RestClient.get(url, header)

    genre_seed_data = JSON.parse(genre_seed_response)

    genre_seed_data["genres"].each do |genre|
      Genre.find_or_create_by(name: genre)
    end

    redirect_to "http://localhost:3001"

  end

  private

  def set_user
    @@current_user = User.find(ENV["CURRENT_USER_ID"].to_i)
  end

end
