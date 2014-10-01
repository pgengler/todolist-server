class DaysController < ApplicationController
  def index
    render json: Day.includes(:tasks).sliding_window
  end
end
