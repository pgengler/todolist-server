class ItemTagsController < ApplicationController
	def index
		render json: ItemTag.all
	end
end