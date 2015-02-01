class DaysController < ApplicationController
	def index
		@days = [ ]

		date = params[:date] ? Date.parse(params[:date]) : Date.today

		params[:before_days].to_i.times do |i|
			offset = i + 1
			day = Day.find_or_create_by(date: date - offset.day)
			@days.unshift(day)
		end

		@days << Day.find_or_create_by(date: date)

		params[:after_days].to_i.times do |i|
			offset = i + 1
			@days << Day.find_or_create_by(date: date + offset.day)
		end

		render json: @days
	end

	def show
		if params[:date] == "undated"
			params[:date] = nil
		end
		@day = Day.find_or_create_by(date: params[:date])
		render json: @day
	end
end
