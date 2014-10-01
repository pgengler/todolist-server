class DaysController < ApplicationController
  def index
    render json: Day.includes(:items).all
  end
end
