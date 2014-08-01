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

		@item_tag = ItemTag.create!(item: @item, tag: @tag, position: next_position(@item, @tag))

		render json: @item_tag, status: :created
	end

	private

	def next_position(item, tag)
		last_item_tag = ItemTag.where(item_id: item.id, tag_id: tag.id).order('position DESC').first
		if last_item_tag
			last_item_tag.position + 1
		else
			1
		end
	end
end