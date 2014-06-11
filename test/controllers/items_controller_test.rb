require 'test_helper'

class ItemsControllerTest < ActionController::TestCase
    test "should get index" do
        get :index
        assert_response :success
    end

     test "index view includes appropriate items" do
        get :index
        body = JSON.parse(response.body)
        assert_equal 2, body['items'].length
    end

    test "can create new items" do
        assert_difference 'Item.count' do
            post :create, item: { date: Date.today, event: "New event", location: "New Location", start: '1200', end: '1400' }
        end
    end

    test "all values are assigned to newly-created items" do
        new_item_params = { date: Date.today, event: "New event", location: "New location", start: '1200', end: '1400' }
        post :create, item: new_item_params
        item = assigns(:item)
        assert_equal new_item_params[:date], item.date
        assert_equal new_item_params[:event], item.event
        assert_equal new_item_params[:location], item.location
        assert_equal new_item_params[:start], item.start
        assert_equal new_item_params[:end], item.end
    end

    test "returns data for a single item" do
        get :show, id: items(:past)
        assert_response :success
        body = JSON.parse(response.body)
        assert_equal body['item']['id'], items(:past).id
    end
end
