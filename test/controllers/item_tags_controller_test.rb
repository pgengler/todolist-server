require 'test_helper'

class ItemTagsControllerTest < ActionController::TestCase
	test "has an 'index' action" do
		get :index
		assert_response :success
	end

	test "'create' action adds tag to item" do
		@item = items(:with_no_tags)
		@tag = tags(:one)
		post :create, item_tag: { item_id: @item.id, tag_id: @tag.id }

		assert_equal 1, @item.tags.count
	end

	test "'create' action adds item to tag" do
		@item = items(:with_no_tags)
		@tag = tags(:one)

		assert_difference '@tag.items.count' do
			post :create, item_tag: { item_id: @item.id, tag_id: @tag.id }
		end
	end

	test "responds with the correct HTTP status code when creating a record" do
		@item = items(:with_no_tags)
		@tag = tags(:one)
		post :create, item_tag: { item_id: @item.id, tag_id: @tag.id }
		assert_response :created
	end

	test "can retrieve data for a single record" do
		get :show, id: item_tags(:one)
		assert_response :success
	end

	test "includes the 'position' in the JSON response" do
		get :show, id: item_tags(:one)
		body = JSON.parse(response.body)
		assert_equal 1, body['item_tag']['position']
	end

	test "can update the 'position' value" do
		put :update, id: item_tags(:one), item_tag: { position: 42 }
		assert_equal 42, assigns(:item_tag).position
	end
end