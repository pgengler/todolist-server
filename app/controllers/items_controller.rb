class ItemsController < ApplicationController
    def index
        render json: Item.all
    end

    def create
        @item = Item.create!(item_params)
    end

    def show
        @item = Item.find(params[:id])
        render json: @item
    end

    private

    def item_params
        params.required(:item).permit(:date, :event, :location, :start, :end)
    end
end
