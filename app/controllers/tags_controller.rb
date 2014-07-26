class TagsController < ApplicationController
	def index
		render json: Tag.all
	end

	def update
		@tag = Tag.find(params[:id])
		@tag.update tag_params

		render json: @tag, location: @tag
	end

	private

	def tag_params
		params.required(:tag).permit(:name)
	end
end