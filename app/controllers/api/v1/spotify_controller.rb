class Api::V1::SpotifyController < ApplicationController
  before_action :set_user, only: [:search, :create_playlist, :refresh_token]
  before_action :refresh_token, only: [:search, :create_playlist]
  skip_before_action :authorized, only: [:search, :create_playlist]

  def search

    @mood = search_params["mood"]

    @genre_one = search_params["genreone"]
    @genre_two = search_params["genretwo"]
    @genre_three = search_params["genrethree"]



    case @mood
    when 'sad'
      valence_min = 0.00
      valence_max = 0.20
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

    @current_playlist = ""

    if @current_user.moods.last
    mood_list_id = @current_user.moods.last.mood_list_id + 1
    else
      mood_list_id = 0
    end

    search_data["tracks"].each do |track|

      if @current_playlist.length === 0
        @current_playlist += track["uri"]
      elsif @current_playlist.length > 0
        @current_playlist += ", " + track["uri"]
      end

      currentSong = Song.find_or_create_by(artist: track["artists"][0]["name"], title: track["name"], album_cover: track["album"]["images"][1]["url"], spotify_id: track["id"], uri: track["uri"])

      Mood.find_or_create_by(name: @current_user.username + " " + @mood, user_id: @current_user.id, song_id: currentSong.id, mood_list_id: mood_list_id, saved: false)

    end

    response_query_data = {
      mood: @mood,
      playlist_uris_string: @current_playlist
    }

    response_query_version = response_query_data.to_query

    case @mood
      when 'sad'
        redirect_to "https://vibelist-client.herokuapp.com//create-sad-vibelist?" + response_query_data.to_query
      when 'content'
        redirect_to "https://vibelist-client.herokuapp.com//create-content-vibelist?" + response_query_data.to_query
      when 'ecstatic'
        redirect_to "https://vibelist-client.herokuapp.com//create-ecstatic-vibelist?" + response_query_data.to_query
    end

  end

  def create_playlist

    @playlist_uris_string = search_params[:playlist_uris_string]


    current_mood = search_params[:mood]

    @spotify_user_id = @current_user["username"]

    url = "https://api.spotify.com/v1/users/#{@spotify_user_id}/playlists"

    header = {
      Authorization: "Bearer #{@current_user["access_token"]}",
      "Content-Type": "application/json"
    }

    case current_mood
      when 'sad'
        mood_word = 'sad'
      when 'content'
        mood_word = 'happy'
      when 'ecstatic'
        mood_word = 'super happy'
    end

    body = {
      name: "my #{mood_word} vibelist",
      description: "A playlist of #{mood_word} songs made with the vibelist app."
    }

    create_playlist_response = RestClient.post(url, body.to_json, header)

    playlist_data = JSON.parse(create_playlist_response.body)

    @playlist_uri = playlist_data["uri"]

    mood_list_id = @current_user.moods.last.mood_list_id

    Mood.where(mood_list_id: mood_list_id).update_all("playlist_uri = '#{@playlist_uri}'")
    Mood.where(mood_list_id: mood_list_id).update_all("saved = true")

    case current_mood
      when 'sad'
        mood_word = 'sad'
      when 'content'
        mood_word = 'happy'
      when 'ecstatic'
        mood_word = 'super happy'
    end

    playlist_id = playlist_data["id"]

    add_songs_url = "https://api.spotify.com/v1/playlists/" + playlist_id +"/tracks"

    playlist_uri_array = @playlist_uris_string.split(", ")

    add_songs_body = {
      uris: playlist_uri_array
    }

    add_songs_to_playlist_response = RestClient.post(add_songs_url, add_songs_body.to_json, header)

    playlist_data = JSON.parse(add_songs_to_playlist_response.body)


    case current_mood
      when 'sad'
        redirect_to "https://vibelist-client.herokuapp.com//create-sad-vibelist?mood=" + current_mood +
        "&uri=" + @playlist_uri
      when 'content'
        redirect_to "https://vibelist-client.herokuapp.com//create-content-vibelist?mood=" + current_mood + "&uri=" + @playlist_uri
      when 'ecstatic'
        redirect_to "https://vibelist-client.herokuapp.com//create-ecstatic-vibelist?mood=" + current_mood + "&uri=" + @playlist_uri
    end

  end

  def refresh_token

    url = "https://accounts.spotify.com/api/token"

    if @current_user.access_token_expired?
    #Request a new access token using refresh token
    #Create body of request
    refresh_token = @current_user['refresh_token']

    stringToEncode = ENV['CLIENT_ID'] + ":" + ENV["CLIENT_SECRET"]

    enc = Base64.strict_encode64(stringToEncode)

    header = {
      'Authorization': "Basic #{enc}",
      'Content-Type': 'application/x-www-form-urlencoded'
    }

    body = {
      'grant_type': "refresh_token",
      'refresh_token': refresh_token
    }

    auth_response = RestClient.post(url, body, header)

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
    params.permit(:mood, :jwt, :genreone, :genretwo, :genrethree, :playlist_uris_string)
  end

end
