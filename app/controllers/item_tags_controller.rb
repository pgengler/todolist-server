class ItemTagsController < ApplicationController
	def index
		render json: ItemTag.all
	end

	def create
		@item = Item.find(params[:item_tag][:item_id])
		@tag = Tag.find(params[:item_tag][:tag_id])

		@item_tag = ItemTag.create!(item: @item, tag: @tag)

		render json: @item_tag, status: :created
	end
end