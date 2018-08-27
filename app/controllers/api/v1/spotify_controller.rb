class Api::V1::SpotifyController < ApplicationController
  before_action :set_user, only: [:search]


  def search

    search_genre = search_params["genre"]


    url = 'https://api.spotify.com/v1/recommendations'

    header = {
      Authorization: "Bearer #{@@current_user["access_token"]}"
    }

    query_params = {
      seed_genres: search_genre,
      limit: 50
    }

    fetchUrl ="#{url}?#{query_params.to_query}"

    search_get_response = RestClient.get(fetchUrl, header)

    search_data = JSON.parse(search_get_response.body)

    binding.pry

    redirect_to "http://localhost:3001"

  end

  private

  def set_user
    @@current_user = User.find(ENV["CURRENT_USER_ID"].to_i)
  end

  def search_params
    params.permit(:genre)
  end

end
