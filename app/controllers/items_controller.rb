class ItemsController < ApplicationController
    def index
        render json: Item.all
    end

    def create
        @item = Item.create!(item_params)
    end

    private

    def item_params
        params.required(:item).permit(:date, :event, :location, :start, :end)
    end
end
