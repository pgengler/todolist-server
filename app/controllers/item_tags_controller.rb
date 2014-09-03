class ItemTagsController < ApplicationController
	def index
		render json: ItemTag.all
	end

	def show
		@item_tag = ItemTag.find(params[:id])
		render json: @item_tag
	end

	def create
		@item = Item.find(params[:item_tag][:item_id])
		@tag = Tag.find(params[:item_tag][:tag_id])

		@item_tag = ItemTag.create!(item: @item, tag: @tag)

		render json: @item_tag, status: :created
	end

	def update
		item_tag_params = params.require(:item_tag).permit(:position)
		@item_tag = ItemTag.find(params[:id])
		@item_tag.update(item_tag_params)
		render json: @item_tag
	end
end