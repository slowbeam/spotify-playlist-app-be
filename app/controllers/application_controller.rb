class ApplicationController < ActionController::API
  before_action :authorized

  ENV['SECRET'] = 'p4nd4_f0r_S4l3'

  ENV['CLIENT_ID'] = 'd9dbfa9ebabf431081a7d8c7df553196'

  ENV['CLIENT_SECRET'] = 'b1744cbd42244ac681a388e02371ed63'

  def encode_token(payload)
    JWT.encode(payload, ENV['SECRET'])
  end

  def auth_header
    request.headers["Authorization"]
  end

  def decoded_token
    if auth_header
      token = auth_header.split(' ')[1]
      begin
        JWT.decode(token, ENV['SECRET'], true, algorithm: 'HS256')
      rescue JWT::DecodeError
        [{}]
      end
    end
  end

  def current_user
    if decoded_token
      user_id = decoded_token[0]['user_id']
      @user = User.find_by(id: user_id)
    end
  end

  def logged_in?
    !!current_user
  end

  def authorized
    render json: { message: 'Please log in'},
    status: 401 unless logged_in?
  end
end
