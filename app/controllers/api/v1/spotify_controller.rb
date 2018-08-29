class Api::V1::SpotifyController < ApplicationController
  before_action :set_user, only: [:search, :create_playlist]
  before_action :refresh_token, only: [:search]


  def search

    ENV["SEARCH_MOOD"] = search_params["mood"]

    case ENV["SEARCH_MOOD"]
    when 'sad'
      valence_min = 0.00
      valence_max = 0.10
      seed_genres = "emo, sad, soul, folk, rainy-day"
    when 'content'
      valence_min = 0.40
      valence_max = 0.60
      seed_genres = "acoustic, electronic, indie, pop"
    when 'ecstatic'
      valence_min = 0.6
      valence_max = 1.0
      seed_genres = "pop, electronic, dance"
    end


    url = 'https://api.spotify.com/v1/recommendations'

    header = {
      Authorization: "Bearer #{@@current_user["access_token"]}"
    }

    query_params = {
      min_valence: valence_min,
      max_valence: valence_max,
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

      Mood.find_or_create_by(name: @@current_user.username + " " + ENV["SEARCH_MOOD"], user_id: @@current_user.id, song_id: currentSong.id)

    end

    case ENV["SEARCH_MOOD"]
      when 'sad'
        redirect_to "http://localhost:3001/create-sad-vibelist"
      when 'content'
        redirect_to "http://localhost:3001/create-content-vibelist"
      when 'ecstatic'
        redirect_to "http://localhost:3001/create-ecstatic-vibelist"
    end

  end

  def create_playlist

    @@spotify_user_id = ENV["SPOTIFY_USER_ID"]

    url = "https://api.spotify.com/v1/users/#{@@spotify_user_id}/playlists"

    header = {
      Authorization: "Bearer #{@@current_user["access_token"]}",
      "Content-Type": "application/json"
    }

    body = {
      name: "My #{ENV["SEARCH_MOOD"]} vibelist",
      description: "A playlist of #{ENV["SEARCH_MOOD"]} songs made with the vibeList app."
    }

    create_playlist_response = RestClient.post(url, body.to_json, header)

    playlist_data = JSON.parse(create_playlist_response.body)

    ENV["PLAYLIST_URI"] = playlist_data["uri"]

    case ENV["SEARCH_MOOD"]
      when 'sad'
        @@current_user.update(sadlist_uri: playlist_data["uri"])
      when 'content'
        @@current_user.update(contentlist_uri: playlist_data["uri"])
      when 'ecstaticlist_uri'
        @@current_user.update(ecstaticlist_uri: playlist_data["uri"])
    end

    ENV["PLAYLIST_ID"] = playlist_data["id"]

    add_songs_url = "https://api.spotify.com/v1/playlists/" +ENV["PLAYLIST_ID"] +"/tracks"

    playlist_uri_array = ENV["CURRENT_PLAYLIST"].split(/\s*,\s*/)

    add_songs_body = {
      uris: playlist_uri_array
    }

    add_songs_to_playlist_response = RestClient.post(add_songs_url, add_songs_body.to_json, header)

    playlist_data = JSON.parse(add_songs_to_playlist_response.body)


    redirect_to "http://localhost:3001/"

  end

  def refresh_token

    @@current_user = User.find(ENV["CURRENT_USER_ID"].to_i)

    if @@current_user.access_token_expired?
    #Request a new access token using refresh token
    #Create body of request
    body = {
      grant_type: "refresh_token",
      refresh_token: @@current_user.refresh_token,
      client_id: 'c4b56144ef3d453581292c34d556ce35',
      client_secret: 'e486d8b9155149b1a8cae370b5091849'
    }

    auth_response = RestClient.post('https://accounts.spotify.com/api/token', body)

    auth_params = JSON.parse(auth_response)
    @@current_user.update(access_token: auth_params["access_token"])
    else
      puts "Current user's access token has not expired"
    end
  end

  private

  def set_user
    @@current_user = User.find(ENV["CURRENT_USER_ID"].to_i)
  end

  def search_params
    params.permit(:mood)
  end

end
