class DaysController < ApplicationController
	def index
		if params.include?(:date)
			@date = Date.parse(params[:date])
			@days = Day.includes(:tasks).window(@date)
		else
			@days = Day.includes(:tasks).window
		end
		render json: @days
	end
end
