class ItemsController < ApplicationController
	def index
		render json: Item.all
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
		params.required(:item).permit(:event, :done, :day_id)
	end
end
