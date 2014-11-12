class DaysController < ApplicationController
	def index
		if params.include?(:date)
			@date = Date.parse(params[:date])
		else
			@date = DateTime.now
		end
		if request.headers.include?('HTTP_CLIENT_TIMEZONE')
			offset = request.headers['HTTP_CLIENT_TIMEZONE'].to_i
			@date = @date + offset.minutes
		end
		@days = Day.includes(:tasks).window(@date)
		render json: @days
	end
end
