class ItemsController < ApplicationController
	def index
		render json: Item.includes(:item_tags, :tags).all
	end

	def create
		@item = Item.create!(item_params)
		render json: @item, status: :created, location: @item
	end

	def show
		@item = Item.find(params[:id])
		render json: @item
	end

	def update
		@item = Item.find(params[:id])
		@item.update(item_params)
		render json: @item, location: @item
	end

	private

	def item_params
		params.required(:item).permit(:date, :event, :done)
	end
end
