class ItemsController < ApplicationController
    def index
        render json: Item.all
    end

    def create
        Item.create! item_params
    end

    private

    def item_params
        params.required(:item).permit(:event, :location)
    end
end
