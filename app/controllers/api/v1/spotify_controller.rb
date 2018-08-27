class Api::V1::SpotifyController < ApplicationController
  before_action :set_user, only: [:recommend]

  def recommend

    search_genre = search_params["genre"]

    url = 'https://api.spotify.com/v1/recommendations'

    header = {
      Authorization: "Bearer #{@@current_user["access_token"]}"
    }

    query_params = {
      q: 'year:' + search_year,
      type: 'track',
      limit: 30
    }

    fetchUrl ="#{url}?#{query_params.to_query}"

    search_get_response = RestClient.get(fetchUrl, header)

    search_data = JSON.parse(search_get_response.body)

  end

  private

  def set_user
    @@current_user = User.find(ENV["CURRENT_USER_ID"].to_i)
  end
end
