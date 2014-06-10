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
            post :create, item: { date: Date.today, event: "New event", location: "New Location", start: 1.hour.ago, end: 1.hour.from_now }
        end
    end
end
