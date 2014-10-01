class DaysController < ApplicationController
  def index
    render json: Day.includes(:items).sliding_window
  end
end
