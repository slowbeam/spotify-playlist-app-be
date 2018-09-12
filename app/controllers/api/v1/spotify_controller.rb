class Api::V1::SpotifyController < ApplicationController
  before_action :set_user, only: [:search, :create_playlist, :refresh_token]
  before_action :refresh_token, only: [:search, :create_playlist]
  skip_before_action :authorized, only: [:search, :create_playlist]

  def search

    ENV["SEARCH_MOOD"] = search_params["mood"]

    @genre_one = search_params["genreone"]
    @genre_two = search_params["genretwo"]
    @genre_three = search_params["genrethree"]



    case ENV["SEARCH_MOOD"]
    when 'sad'
      valence_min = 0.00
      valence_max = 0.10
      if @genre_one != nil && @genre_two != nil && @genre_three != nil
        seed_genres = "#{@genre_one}, #{@genre_two}, #{@genre_three}"
      elsif @genre_one != nil && @genre_two != nil && @genre_three == nil
        seed_genres = "#{@genre_one}, #{@genre_two}"
      elsif @genre_one != nil && @genre_two == nil && @genre_three == nil
        seed_genres = "#{@genre_one}"
      elsif @genre_one !=  nil && @genre_two == nil && @genre_three != nil
        seed_genres = "#{@genre_one}, #{@genre_three}"
      elsif @genre_one ==  nil && @genre_two != nil && @genre_three != nil
        seed_genres = "#{@genre_two}, #{@genre_three}"
      elsif @genre_one == nil && @genre_two != nil && @genre_three == nil
        seed_genres = "#{@genre_two}"
      elsif @genre_one == nil && @genre_two == nil && @genre_three != nil
        seed_genres = "#{@genre_three}"
      else
        seed_genres = "emo, sad, soul, folk, rainy-day"
      end
    when 'content'
      valence_min = 0.40
      valence_max = 0.60
      if @genre_one != nil && @genre_two != nil && @genre_three != nil
        seed_genres = "#{@genre_one}, #{@genre_two}, #{@genre_three}"
      elsif @genre_one != nil && @genre_two != nil && @genre_three == nil
        seed_genres = "#{@genre_one}, #{@genre_two}"
      elsif @genre_one != nil && @genre_two == nil && @genre_three == nil
        seed_genres = "#{@genre_one}"
      elsif @genre_one !=  nil && @genre_two == nil && @genre_three != nil
        seed_genres = "#{@genre_one}, #{@genre_three}"
      elsif @genre_one ==  nil && @genre_two != nil && @genre_three != nil
        seed_genres = "#{@genre_two}, #{@genre_three}"
      elsif @genre_one == nil && @genre_two != nil && @genre_three == nil
        seed_genres = "#{@genre_two}"
      elsif @genre_one == nil && @genre_two == nil && @genre_three != nil
        seed_genres = "#{@genre_three}"
      else
        seed_genres = "acoustic, electronic, indie, pop"
      end
    when 'ecstatic'
      valence_min = 0.6
      valence_max = 1.0
      if @genre_one != nil && @genre_two != nil && @genre_three != nil
        seed_genres = "#{@genre_one}, #{@genre_two}, #{@genre_three}"
      elsif @genre_one != nil && @genre_two != nil && @genre_three == nil
        seed_genres = "#{@genre_one}, #{@genre_two}"
      elsif @genre_one != nil && @genre_two == nil && @genre_three == nil
        seed_genres = "#{@genre_one}"
      elsif @genre_one !=  nil && @genre_two == nil && @genre_three != nil
        seed_genres = "#{@genre_one}, #{@genre_three}"
      elsif @genre_one ==  nil && @genre_two != nil && @genre_three != nil
        seed_genres = "#{@genre_two}, #{@genre_three}"
      elsif @genre_one == nil && @genre_two != nil && @genre_three == nil
        seed_genres = "#{@genre_two}"
      elsif @genre_one == nil && @genre_two == nil && @genre_three != nil
        seed_genres = "#{@genre_three}"
      else
      seed_genres = "pop, electronic, dance"
      end
    end


    url = 'https://api.spotify.com/v1/recommendations'

    header = {
      Authorization: "Bearer #{@current_user["access_token"]}"
    }

    query_params = {
      min_valence: valence_min,
      max_valence: valence_max,
      limit: 30,
      seed_genres: seed_genres,
      market: 'from_token'
    }

    fetchUrl ="#{url}?#{query_params.to_query}"

    search_get_response = RestClient.get(fetchUrl, header)

    search_data = JSON.parse(search_get_response.body)

    ENV["CURRENT_PLAYLIST"] = ""

    if @current_user.moods.last
    mood_list_id = @current_user.moods.last.mood_list_id + 1
    else
      mood_list_id = 0
    end

    search_data["tracks"].each do |track|

      if ENV["CURRENT_PLAYLIST"].length === 0
        ENV["CURRENT_PLAYLIST"] += track["uri"]
      elsif ENV["CURRENT_PLAYLIST"].length > 0
        ENV["CURRENT_PLAYLIST"] += ", " + track["uri"]
      end

      currentSong = Song.find_or_create_by(artist: track["artists"][0]["name"], title: track["name"], album_cover: track["album"]["images"][1]["url"], spotify_id: track["id"], uri: track["uri"])

      Mood.find_or_create_by(name: @current_user.username + " " + ENV["SEARCH_MOOD"], user_id: @current_user.id, song_id: currentSong.id, mood_list_id: mood_list_id, saved: false)

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
    @@spotify_user_id = @current_user["username"]

    url = "https://api.spotify.com/v1/users/#{@@spotify_user_id}/playlists"

    header = {
      Authorization: "Bearer #{@current_user["access_token"]}",
      "Content-Type": "application/json"
    }

    body = {
      name: "My #{ENV["SEARCH_MOOD"]} vibelist",
      description: "A playlist of #{ENV["SEARCH_MOOD"]} songs made with the vibeList app."
    }

    create_playlist_response = RestClient.post(url, body.to_json, header)

    playlist_data = JSON.parse(create_playlist_response.body)

    ENV["PLAYLIST_URI"] = playlist_data["uri"]

    mood_list_id = @current_user.moods.last.mood_list_id
    moodNow = @current_user.moods.last
    Mood.where(mood_list_id: mood_list_id).update_all("playlist_uri = '#{playlist_data["uri"]}'")
    Mood.where(mood_list_id: mood_list_id).update_all("saved = true")

    case ENV["SEARCH_MOOD"]
      when 'sad'
        @current_user.update(sadlist_uri: playlist_data["uri"])
      when 'content'
        @current_user.update(contentlist_uri: playlist_data["uri"])
      when 'ecstatic'
        @current_user.update(ecstaticlist_uri: playlist_data["uri"])
    end

    ENV["PLAYLIST_ID"] = playlist_data["id"]

    add_songs_url = "https://api.spotify.com/v1/playlists/" +ENV["PLAYLIST_ID"] +"/tracks"

    playlist_uri_array = ENV["CURRENT_PLAYLIST"].split(/\s*,\s*/)

    add_songs_body = {
      uris: playlist_uri_array
    }

    add_songs_to_playlist_response = RestClient.post(add_songs_url, add_songs_body.to_json, header)

    playlist_data = JSON.parse(add_songs_to_playlist_response.body)


    case ENV["SEARCH_MOOD"]
      when 'sad'
        redirect_to "http://localhost:3001/create-sad-vibelist?uri=" + @current_user.sadlist_uri
      when 'content'
        redirect_to "http://localhost:3001/create-content-vibelist?uri=" + @current_user.contentlist_uri
      when 'ecstatic'
        redirect_to "http://localhost:3001/create-ecstatic-vibelist?uri=" + @current_user.ecstaticlist_uri
    end

  end

  def refresh_token

    url = "https://accounts.spotify.com/api/token"

    if @current_user.access_token_expired?
    #Request a new access token using refresh token
    #Create body of request

    enc =
    Base64.encode64('c4b56144ef3d453581292c34d556ce35:e486d8b9155149b1a8cae370b5091849')

    header = {
      Authorization: "Basic #{enc}"
    }

    body = { grant_type: "refresh_token", refresh_token: "#{@current_user["refresh_token"]}"}

    auth_response = RestClient.post(url, body.to_json, header)

    auth_params = JSON.parse(auth_response)
    @current_user.update(access_token: auth_params["access_token"])
    else
      puts "Current user's access token has not expired"
    end
  end

  private

  def set_user
    token = search_params["jwt"]
    begin
      tokenObj = JWT.decode(token, ENV['SECRET'], true, algorithm: 'HS256')
    rescue JWT::DecodeError
      [{}]
    end

    user_id = tokenObj[0]["user_id"]

    @current_user = User.find(user_id)
  end

  def search_params
    params.permit(:mood, :jwt, :genreone, :genretwo, :genrethree )
  end

end
