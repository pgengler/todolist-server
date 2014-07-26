require 'test_helper'

class ItemsControllerTest < ActionController::TestCase
	test "should get index" do
		get :index
		assert_response :success
	end

	test "index view includes appropriate items" do
		get :index
		body = JSON.parse(response.body)
		assert_equal Item.count, body['items'].length
	end

	test "can create new items" do
		assert_difference 'Item.count' do
			post :create, item: {date: Date.today, event: "New event"}
		end
	end

	test "all values are assigned to newly-created items" do
		new_item_params = {date: Date.today, event: "New event"}
		post :create, item: new_item_params
		item = assigns(:item)
		assert_equal new_item_params[:date], item.date
		assert_equal new_item_params[:event], item.event
	end

	test "create action returns 'created' HTTP status code after creating item" do
		new_item_params = {date: Date.today, event: "New event"}
		post :create, item: new_item_params
		assert_response :created
	end

	test "returns data for a single item" do
		get :show, id: items(:past)
		assert_response :success
		body = JSON.parse(response.body)
		assert_equal body['item']['id'], items(:past).id
	end

	test "updates the 'done' property" do
		item = items(:past)
		post :update, id: item, item: { done: true }
		assert_response :success
		assert_equal true, assigns(:item).done
	end
end
