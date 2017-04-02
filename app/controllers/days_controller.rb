class DaysController < ApplicationController
	def index
		@days = [ ]

		if params[:date] == 'undated'
			date = nil
		elsif params[:date]
			date = Date.parse(params[:date])
		else
			date = Date.today
		end

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

		render json: (@days.length == 1 ? @days.first : @days)
	end

	def show
		render json: Day.find(params[:id])
	end
end
