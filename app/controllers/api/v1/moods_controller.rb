class Api::V1::MoodsController < ApplicationController

  def index
      @moods = Mood.all
      render json: @moods
  end

end
