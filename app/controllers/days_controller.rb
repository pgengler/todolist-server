class DaysController < ApplicationController
  def index
    render json: Day.includes(:tasks).window
  end
end
