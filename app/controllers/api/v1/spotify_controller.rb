class Api::V1::SpotifyController < ApplicationController
  before_action :set_user, only: [:search]


  def search

    search_mood = search_params["mood"]

    case search_mood
    when 'sad'
      valence_min = 0.00
      valence_max = 0.10
      seed_genres = "emo, sad, soul, folk, rainy-day"
    when 'content'
      valence_min = 0.40
      valence_max = 0.60
      seed_genres = "acoustic, edm, electronic, indie, pop"
    when 'ecstatic'
      valence_min = 0.85
      valence_max = 1.00
      seed_genres = "edm, dance, electro, pop, party"
    end


    url = 'https://api.spotify.com/v1/recommendations'

    header = {
      Authorization: "Bearer #{@@current_user["access_token"]}"
    }

    query_params = {
      max_valence: valence_max,
      min_valence: valence_min,
      limit: 30,
      seed_genres: seed_genres
    }

    fetchUrl ="#{url}?#{query_params.to_query}"

    search_get_response = RestClient.get(fetchUrl, header)

    search_data = JSON.parse(search_get_response.body)

    ENV["CURRENT_PLAYLIST"] = ""

    search_data["tracks"].each do |track|

      if ENV["CURRENT_PLAYLIST"].length === 0
        ENV["CURRENT_PLAYLIST"] += track["uri"]
      elsif ENV["CURRENT_PLAYLIST"].length > 0
        ENV["CURRENT_PLAYLIST"] += ", " + track["uri"]
      end

      currentSong = Song.find_or_create_by(artist: track["artists"][0]["name"], title: track["name"], album_cover: track["album"]["images"][1]["url"], spotify_id: track["id"], uri: track["uri"])

      SongUser.find_or_create_by(user_id: @@current_user.id, song_id: currentSong.id)

    end

    redirect_to "http://localhost:3001"

  end

  private

  def set_user
    @@current_user = User.find(ENV["CURRENT_USER_ID"].to_i)
  end

  def search_params
    params.permit(:mood)
  end

end
