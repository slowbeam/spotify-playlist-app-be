class Api::V1::UsersController < ApplicationController

  def index
    @users = User.all
    render json: @users
  end

  def create
    if params[:error]

      puts 'LOGIN ERROR', params
      redirect_to 'http://localhost:3001'
    else
      body = {
        grant_type: "authorization_code",
        code: params[:code],
        redirect_uri: 'http://localhost:3000/api/v1/logging-in',
        client_id: 'd9dbfa9ebabf431081a7d8c7df553196',
        client_secret: 'b1744cbd42244ac681a388e02371ed63'
      }
      auth_response = RestClient.post('https://accounts.spotify.com/api/token', body)

      auth_params = JSON.parse(auth_response.body)

      header = {
        Authorization: "Bearer #{auth_params["access_token"]}"
      }
      user_response = RestClient.get("https://api.spotify.com/v1/me", header)

      user_params = JSON.parse(user_response.body)

      binding.pry

      @user = User.find_or_create_by(username: user_params["id"],
                          spotify_url: user_params["external_urls"]["spotify"],
                          href: user_params["href"],
                          uri: user_params["uri"],
                          profile_image: user_params["images"][0]["url"],
                          display_name: user_params["display_name"])
      @user.update(access_token: auth_params["access_token"], refresh_token: auth_params["refresh_token"])

      User.update_all(logged_in: false)

      @user.update(logged_in: true)

      ENV["CURRENT_USER_ID"] = @user.id.to_s

      ENV["SPOTIFY_USER_ID"] = @user.username

      redirect_to "http://localhost:3001"
    end

  end

  def logout
    User.update_all(logged_in: false)

    redirect_to "http://localhost:3001/"
  end


end
