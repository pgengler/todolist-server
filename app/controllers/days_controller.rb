class DaysController < ApplicationController
	def index
		if params.include?(:date)
			@date = Date.parse(params[:date])
		else
			@date = DateTime.now
		end
		if request.headers.include?('HTTP_X_CLIENT_TIMEZONE_OFFSET')
			offset = request.headers['HTTP_X_CLIENT_TIMEZONE_OFFSET'].to_i
			@date = @date + offset.minutes
		end
		@days = Day.includes(:tasks).window(@date)
		render json: @days
	end
end
